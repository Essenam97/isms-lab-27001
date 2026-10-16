#!/usr/bin/env bash
# Control tests NC-01 to NC-05 for file sharing and storage (actions A07, A13).
# Needs: curl, jq, docker, and NC_URL, NC_ADMIN_USER, NC_ADMIN_PASSWORD.
# Helper functions set CODE in the current shell: never call them inside $(...).
set -u

REPORT="$PWD/test-report.md"
FAILED=0
PW='Lagune-Lab-2026x'
SHARE_PW='Share-Pass-2026x'
MARKER='LAGUNE-PLAINTEXT-MARKER'
C_NAME=lagune-nextcloud

occ () { docker exec -u www-data "$C_NAME" php occ "$@"; }

{
  echo "# Nextcloud control test report (lab run)"
  echo
  echo "| Item | Value |"
  echo "|---|---|"
  echo "| Date (UTC) | $(date -u '+%Y-%m-%d %H:%M:%S') |"
  echo "| Commit | ${GITHUB_SHA:-local} |"
  echo "| Run | ${GITHUB_SERVER_URL:-}/${GITHUB_REPOSITORY:-}/actions/runs/${GITHUB_RUN_ID:-local} |"
  echo "| Nextcloud | $(curl -s "$NC_URL/status.php" | jq -r '.versionstring // "unknown"') |"
  echo
  echo "This is a test of the lab, not of a production system. Lagune Payroll is fictional."
  echo
  echo "| Test | Control | Expected | Observed | Result |"
  echo "|---|---|---|---|---|"
} > "$REPORT"

result () { # id control expected observed pass(0/1)
  local r="PASS"; [ "$5" -eq 0 ] || { r="FAIL"; FAILED=1; }
  echo "| $1 | $2 | $3 | $4 | $r |" >> "$REPORT"
  echo "$1 $r: $4"
}

ocs () { # user password method path [curl data args...]; body in /tmp/body, sets CODE
  local u=$1 p=$2 m=$3 path=$4; shift 4
  CODE=$(curl -s -o /tmp/body -w '%{http_code}' -u "$u:$p" -X "$m" -H 'OCS-APIRequest: true' \
    "$@" "$NC_URL/ocs/v2.php$path")
}

setup_fail () { echo "| setup | n/a | $1 | $2 | FAIL |" >> "$REPORT"; echo "Setup failed: $1: $2"; exit 1; }

# ---- Setup: policies, encryption, users, one file
occ config:app:set password_policy minLength --value=12 > /dev/null || setup_fail "password policy" "occ error"
occ config:app:set core shareapi_enforce_links_password --value=yes > /dev/null || setup_fail "link password" "occ error"
occ config:app:set core shareapi_default_expire_date --value=yes > /dev/null
occ config:app:set core shareapi_enforce_expire_date --value=yes > /dev/null
occ config:app:set core shareapi_expire_after_n_days --value=7 > /dev/null
occ app:enable encryption > /dev/null || setup_fail "enable encryption app" "occ error"
occ encryption:enable > /dev/null || setup_fail "enable server-side encryption" "occ error"
for u in user1 user2; do
  docker exec -u www-data -e OC_PASS="$PW" "$C_NAME" php occ user:add --password-from-env "$u" > /dev/null \
    || setup_fail "create $u" "occ error"
done
echo "Payroll export for tests. $MARKER" > /tmp/report.txt
CODE=$(curl -s -o /dev/null -w '%{http_code}' -u "user1:$PW" -T /tmp/report.txt "$NC_URL/remote.php/dav/files/user1/report.txt")
[ "$CODE" = "201" ] || [ "$CODE" = "204" ] || setup_fail "upload report.txt as user1" "HTTP $CODE"

# ---- NC-01 Password policy (5.17)
ocs "$NC_ADMIN_USER" "$NC_ADMIN_PASSWORD" POST /cloud/users -d userid=weak1 -d 'password=Lagune2026'; C=$CODE
MSG=$(jq -r '.ocs.meta.message // empty' /tmp/body 2>/dev/null | head -c 80)
ocs "$NC_ADMIN_USER" "$NC_ADMIN_PASSWORD" GET /cloud/users/weak1; EXISTS=$CODE
[ "$C" != "200" ] && [ "$EXISTS" = "404" ]
result NC-01 5.17 "User with a 10-character password not created" "create HTTP $C ${MSG}; lookup HTTP $EXISTS" $?

# ---- NC-02 Public link without password is refused (5.14)
ocs user1 "$PW" POST "/apps/files_sharing/api/v1/shares?format=json" -d path=/report.txt -d shareType=3; C=$CODE
MSG=$(jq -r '.ocs.meta.message // empty' /tmp/body 2>/dev/null | head -c 80)
ocs user1 "$PW" GET "/apps/files_sharing/api/v1/shares?format=json&path=/report.txt"; N=$(jq '.ocs.data | length' /tmp/body)
[ "$C" != "200" ] && [ "$N" = "0" ]
result NC-02 5.14 "Link share without password refused; no share exists" "create HTTP $C ${MSG}; shares on file=$N" $?

# ---- NC-03 Public link with password gets an expiry date within 7 days (5.14)
ocs user1 "$PW" POST "/apps/files_sharing/api/v1/shares?format=json" -d path=/report.txt -d shareType=3 -d "password=$SHARE_PW"; C=$CODE
EXP=$(jq -r '.ocs.data.expiration // empty' /tmp/body | cut -c1-10)
LIMIT=$(date -u -d '+7 days' '+%Y-%m-%d')
[ "$C" = "200" ] && [ -n "$EXP" ] && [[ ! "$EXP" > "$LIMIT" ]]
result NC-03 5.14 "Share created with an expiry date no later than $LIMIT" "create HTTP $C; expiration=${EXP:-none}" $?

# ---- NC-04 File stored encrypted on disk (8.24)
RAW=$(docker exec "$C_NAME" head -c 40 /var/www/html/data/user1/files/report.txt 2>&1)
docker exec "$C_NAME" grep -q "$MARKER" /var/www/html/data/user1/files/report.txt; PLAIN_ON_DISK=$?
DL=$(curl -s -u "user1:$PW" "$NC_URL/remote.php/dav/files/user1/report.txt")
echo "$DL" | grep -q "$MARKER"; READ_OK=$?
HEADER=$(echo "$RAW" | cut -c1-6)
[ "$HEADER" = "HBEGIN" ] && [ "$PLAIN_ON_DISK" -ne 0 ] && [ "$READ_OK" -eq 0 ]
result NC-04 8.24 "File on disk starts with HBEGIN and has no plaintext; user1 still reads it" "disk header=$HEADER; marker on disk: $([ $PLAIN_ON_DISK -eq 0 ] && echo yes || echo no); marker via WebDAV: $([ $READ_OK -eq 0 ] && echo yes || echo no)" $?

# ---- NC-05 Another user cannot read the file without a share (8.3)
C=$(curl -s -o /tmp/other -w '%{http_code}' -u "user2:$PW" "$NC_URL/remote.php/dav/files/user1/report.txt")
grep -q "$MARKER" /tmp/other; LEAK=$?
[ "$C" != "200" ] && [ "$LEAK" -ne 0 ]
result NC-05 8.3 "user2 cannot read user1's file" "HTTP $C; content leaked: $([ $LEAK -eq 0 ] && echo yes || echo no)" $?

echo >> "$REPORT"
if [ "$FAILED" -eq 0 ]; then echo "All tests passed." >> "$REPORT"; else echo "At least one test failed. A failed test is a finding to record, not a file to fix silently." >> "$REPORT"; fi
[ -n "${GITHUB_STEP_SUMMARY:-}" ] && cat "$REPORT" >> "$GITHUB_STEP_SUMMARY"
exit $FAILED
