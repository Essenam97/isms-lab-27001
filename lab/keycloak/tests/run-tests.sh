#!/usr/bin/env bash
# Control tests KC-01 to KC-05 for the lagune realm (action A04).
# Needs: curl, jq, and the variables KC_URL, KC_ADMIN_USER, KC_ADMIN_PASSWORD.
set -u

REALM=lagune
REPORT=test-report.md
FAILED=0
GOOD_PASS='Lagune-Lab-2026x'

{
  echo "# Keycloak control test report (lab run)"
  echo
  echo "| Item | Value |"
  echo "|---|---|"
  echo "| Date (UTC) | $(date -u '+%Y-%m-%d %H:%M:%S') |"
  echo "| Commit | ${GITHUB_SHA:-local} |"
  echo "| Run | ${GITHUB_SERVER_URL:-}/${GITHUB_REPOSITORY:-}/actions/runs/${GITHUB_RUN_ID:-local} |"
  echo "| Keycloak | $(docker compose images keycloak --format json 2>/dev/null | jq -r '.[0].Tag // "unknown"' 2>/dev/null) |"
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

token () {
  curl -s -d grant_type=password -d client_id=admin-cli \
    --data-urlencode "username=$KC_ADMIN_USER" --data-urlencode "password=$KC_ADMIN_PASSWORD" \
    "$KC_URL/realms/master/protocol/openid-connect/token" | jq -r .access_token
}

api () { # method path [json]; prints body, sets CODE
  local m=$1 p=$2 d=${3:-}
  local t; t=$(token)
  if [ -n "$d" ]; then
    CODE=$(curl -s -o /tmp/body -w '%{http_code}' -X "$m" -H "Authorization: Bearer $t" \
      -H 'Content-Type: application/json' -d "$d" "$KC_URL/admin/realms/$REALM$p")
  else
    CODE=$(curl -s -o /tmp/body -w '%{http_code}' -X "$m" -H "Authorization: Bearer $t" \
      "$KC_URL/admin/realms/$REALM$p")
  fi
  cat /tmp/body
}

user_login () { # username password; writes body to /tmp/login, sets CODE
  # Not called inside $(...): a subshell would lose CODE (bug found in run 1).
  CODE=$(curl -s -o /tmp/login -w '%{http_code}' -d grant_type=password -d client_id=admin-cli \
    --data-urlencode "username=$1" --data-urlencode "password=$2" \
    "$KC_URL/realms/$REALM/protocol/openid-connect/token")
}

create_user () { # username; prints id
  api POST /users "{\"username\":\"$1\",\"email\":\"$1@lagune.example\",\"firstName\":\"Test\",\"lastName\":\"$1\",\"enabled\":true}" > /dev/null
  api GET "/users?username=$1&exact=true" | jq -r '.[0].id'
}

update_user () { # id jq-filter; reads the full user, changes it, writes it back; sets CODE
  local rep; rep=$(api GET "/users/$1" | jq -c "$2")
  api PUT "/users/$1" "$rep" > /dev/null
}

set_password () { # id password; sets CODE
  api PUT "/users/$1/reset-password" "{\"type\":\"password\",\"value\":\"$2\",\"temporary\":false}" > /dev/null
}

if [ -z "$(token)" ] || [ "$(token)" = "null" ]; then
  echo "Cannot get an admin token"; echo "| setup | n/a | Admin token | No token | FAIL |" >> "$REPORT"; exit 1
fi

# KC-01 Password policy (5.17)
U1=$(create_user kc-test-1)
set_password "$U1" 'Lagune2026'
C1=$CODE
MSG=$(jq -r '.error // .errorMessage // empty' /tmp/body)
[ "$C1" = "400" ]; result KC-01 5.17 "10-character password refused" "HTTP $C1 ${MSG}" $?

# KC-02 MFA required for a new user (8.5)
set_password "$U1" "$GOOD_PASS"
RA=$(api GET "/users/$U1" | jq -c '.requiredActions')
user_login kc-test-1 "$GOOD_PASS"; C2=$CODE
DESC=$(jq -r '.error_description // empty' /tmp/login)
echo "$RA" | grep -q CONFIGURE_TOTP && [ "$C2" = "400" ]
result KC-02 8.5 "New user has CONFIGURE_TOTP; token request refused (HTTP 400) before MFA is set up" "requiredActions=$RA; login HTTP $C2 ${DESC}" $?

# KC-03 Brute force protection and login error events (8.5, 8.15)
U2=$(create_user kc-test-2)
set_password "$U2" "$GOOD_PASS"
for i in 1 2 3 4 5 6; do user_login kc-test-2 'wrong-password' > /dev/null; done
BF=$(api GET "/attack-detection/brute-force/users/$U2" | jq -c '{disabled, numFailures}')
NERR=$(api GET "/events?type=LOGIN_ERROR&user=$U2&max=50" | jq 'length')
echo "$BF" | jq -e '.disabled == true' > /dev/null && [ "${NERR:-0}" -ge 5 ]
result KC-03 "8.5, 8.15" "User temporarily disabled after 5 failures; failures logged" "$BF; LOGIN_ERROR events=$NERR" $?

# KC-04 Disabled account cannot log in (5.18, 6.5)
U3=$(create_user kc-test-3)
set_password "$U3" "$GOOD_PASS"
update_user "$U3" '.requiredActions = []'
user_login kc-test-3 "$GOOD_PASS" > /dev/null; BEFORE=$CODE
update_user "$U3" '.enabled = false'
user_login kc-test-3 "$GOOD_PASS"; AFTER=$CODE
[ "$BEFORE" = "200" ] && [ "$AFTER" = "400" ]
result KC-04 "5.18, 6.5" "Login HTTP 200 before, HTTP 400 after disabling" "before HTTP $BEFORE; after HTTP $AFTER $(jq -r '.error_description // empty' /tmp/login)" $?

# KC-05 Admin events for group changes (8.15)
GID=$(api GET "/groups?search=infrastructure" | jq -r '.[] | select(.name=="infrastructure") | .id')
api PUT "/users/$U2/groups/$GID" > /dev/null; C5=$CODE
NADM=$(api GET "/admin-events?resourceTypes=GROUP_MEMBERSHIP&max=50" | jq --arg u "$U2" '[.[] | select(.resourcePath | contains($u))] | length')
[ "$C5" = "204" ] && [ "${NADM:-0}" -ge 1 ]
result KC-05 8.15 "Group change recorded as admin event" "add to group HTTP $C5; matching admin events=$NADM" $?

echo >> "$REPORT"
if [ "$FAILED" -eq 0 ]; then echo "All tests passed." >> "$REPORT"; else echo "At least one test failed. A failed test is a finding to record, not a file to fix silently." >> "$REPORT"; fi
[ -n "${GITHUB_STEP_SUMMARY:-}" ] && cat "$REPORT" >> "$GITHUB_STEP_SUMMARY"
exit $FAILED
