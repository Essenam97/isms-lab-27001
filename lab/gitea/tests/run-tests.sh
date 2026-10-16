#!/usr/bin/env bash
# Control tests GT-01 to GT-06 for source code protection (action A10).
# Needs: curl, jq, git, and GT_URL, GT_ADMIN_USER, GT_ADMIN_PASSWORD.
# Helper functions set CODE in the current shell: never call them inside $(...).
set -u

REPORT="$PWD/test-report.md"   # absolute: the script changes directory for git
FAILED=0
PW='Lagune-Lab-2026x'
ORG=lagune
REPO=lagune-pay
HOST=${GT_URL#http://}

{
  echo "# Gitea control test report (lab run)"
  echo
  echo "| Item | Value |"
  echo "|---|---|"
  echo "| Date (UTC) | $(date -u '+%Y-%m-%d %H:%M:%S') |"
  echo "| Commit | ${GITHUB_SHA:-local} |"
  echo "| Run | ${GITHUB_SERVER_URL:-}/${GITHUB_REPOSITORY:-}/actions/runs/${GITHUB_RUN_ID:-local} |"
  echo "| Gitea | $(curl -s -u "$GT_ADMIN_USER:$GT_ADMIN_PASSWORD" "$GT_URL/api/v1/version" | jq -r '.version // "unknown"') |"
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

api () { # user password method path [json]; body in /tmp/body, sets CODE
  local u=$1 p=$2 m=$3 path=$4 d=${5:-}
  if [ -n "$d" ]; then
    CODE=$(curl -s -o /tmp/body -w '%{http_code}' -u "$u:$p" -X "$m" \
      -H 'Content-Type: application/json' -d "$d" "$GT_URL/api/v1$path")
  else
    CODE=$(curl -s -o /tmp/body -w '%{http_code}' -u "$u:$p" -X "$m" "$GT_URL/api/v1$path")
  fi
}

admin () { api "$GT_ADMIN_USER" "$GT_ADMIN_PASSWORD" "$@"; }

setup_fail () { echo "| setup | n/a | $1 | HTTP $CODE $(head -c 200 /tmp/body) | FAIL |" >> "$REPORT"; echo "Setup failed: $1 (HTTP $CODE)"; cat /tmp/body; exit 1; }

# ---- Setup: users, organization, teams, private repository, branch protection
for u in dev1 dev2 support1; do
  admin POST /admin/users "{\"username\":\"$u\",\"email\":\"$u@lagune.example\",\"password\":\"$PW\",\"must_change_password\":false}"
  [ "$CODE" = "201" ] || setup_fail "create user $u"
done
admin POST /orgs "{\"username\":\"$ORG\",\"visibility\":\"private\"}"
[ "$CODE" = "201" ] || setup_fail "create organization"
admin POST "/orgs/$ORG/teams" '{"name":"development","permission":"write","includes_all_repositories":true,"units":["repo.code","repo.pulls","repo.issues"]}'
[ "$CODE" = "201" ] || setup_fail "create team development"
DEV_TEAM=$(jq -r .id /tmp/body)
admin POST "/orgs/$ORG/teams" '{"name":"support","permission":"read","includes_all_repositories":false,"units":["repo.issues"]}'
[ "$CODE" = "201" ] || setup_fail "create team support"
SUP_TEAM=$(jq -r .id /tmp/body)
for u in dev1 dev2; do admin PUT "/teams/$DEV_TEAM/members/$u"; [ "$CODE" = "204" ] || setup_fail "add $u to development"; done
admin PUT "/teams/$SUP_TEAM/members/support1"; [ "$CODE" = "204" ] || setup_fail "add support1 to support"
admin POST "/orgs/$ORG/repos" "{\"name\":\"$REPO\",\"private\":true,\"auto_init\":true,\"readme\":\"Default\",\"default_branch\":\"main\"}"
[ "$CODE" = "201" ] || setup_fail "create repository"
admin POST "/repos/$ORG/$REPO/branch_protections" '{"rule_name":"main","enable_push":false,"required_approvals":1,"block_on_rejected_reviews":true,"dismiss_stale_approvals":true}'
[ "$CODE" = "201" ] || setup_fail "protect branch main"

# ---- GT-01 Support staff cannot read source code (8.4)
api support1 "$PW" GET "/repos/$ORG/$REPO"; C=$CODE
[ "$C" = "404" ]; result GT-01 8.4 "support1 cannot see the repository (HTTP 404)" "HTTP $C" $?

# ---- GT-02 Developers can read source code (8.4, positive control)
api dev1 "$PW" GET "/repos/$ORG/$REPO"; C=$CODE
[ "$C" = "200" ]; result GT-02 8.4 "dev1 can see the repository (HTTP 200)" "HTTP $C" $?

# ---- GT-03 Direct push to main is refused (8.28, 8.32)
rm -rf /tmp/clone
git clone -q "http://dev1:$PW@$HOST/$ORG/$REPO.git" /tmp/clone || { CODE=git; echo "clone failed" > /tmp/body; setup_fail "clone repository as dev1"; }
cd /tmp/clone
git config user.name dev1; git config user.email dev1@lagune.example
echo "direct change" > direct.txt; git add direct.txt; git commit -qm "Direct change to main"
git push -q origin main > /tmp/push.log 2>&1; P=$?
MSG=$(grep -io 'protected[^"]*' /tmp/push.log | head -1)
[ "$P" -ne 0 ]; result GT-03 "8.28, 8.32" "git push to main refused" "git exit code $P; ${MSG:-no message}" $?

# ---- Feature branch and pull request
git reset -q --hard origin/main
git checkout -qb feature-1
echo "reviewed change" > feature.txt; git add feature.txt; git commit -qm "Change through review"
git push -q origin feature-1 > /tmp/push2.log 2>&1 || { CODE=git; echo "push feature failed" > /tmp/body; setup_fail "push feature branch"; }
cd - > /dev/null
api dev1 "$PW" POST "/repos/$ORG/$REPO/pulls" '{"head":"feature-1","base":"main","title":"Change through review"}'
[ "$CODE" = "201" ] || setup_fail "open pull request"
PR=$(jq -r .number /tmp/body)

# ---- GT-04 Merge without approval is blocked (8.25, 8.28)
api dev1 "$PW" POST "/repos/$ORG/$REPO/pulls/$PR/merge" '{"Do":"merge"}'; C=$CODE
api dev1 "$PW" GET "/repos/$ORG/$REPO/pulls/$PR"; MERGED=$(jq -r .merged /tmp/body)
[ "$C" != "200" ] && [ "$MERGED" = "false" ]
result GT-04 "8.25, 8.28" "Merge refused and pull request still not merged" "merge HTTP $C; merged=$MERGED" $?

# ---- GT-05 Author cannot approve own pull request (5.3)
api dev1 "$PW" POST "/repos/$ORG/$REPO/pulls/$PR/reviews" '{"event":"APPROVED","body":"self approval"}'; C=$CODE
[ "$C" = "422" ]; result GT-05 5.3 "Self-approval refused (HTTP 422)" "HTTP $C $(jq -r '.message // empty' /tmp/body | head -c 80)" $?

# ---- GT-06 Merge works after approval by another developer (positive control)
api dev2 "$PW" POST "/repos/$ORG/$REPO/pulls/$PR/reviews" '{"event":"APPROVED","body":"Reviewed"}'; CA=$CODE
api dev1 "$PW" POST "/repos/$ORG/$REPO/pulls/$PR/merge" '{"Do":"merge"}'; CM=$CODE
api dev1 "$PW" GET "/repos/$ORG/$REPO/pulls/$PR"; MERGED=$(jq -r .merged /tmp/body)
[ "$CA" = "200" ] && [ "$CM" = "200" ] && [ "$MERGED" = "true" ]
result GT-06 "8.25, 5.3" "dev2 approves, then merge succeeds" "approve HTTP $CA; merge HTTP $CM; merged=$MERGED" $?

echo >> "$REPORT"
if [ "$FAILED" -eq 0 ]; then echo "All tests passed." >> "$REPORT"; else echo "At least one test failed. A failed test is a finding to record, not a file to fix silently." >> "$REPORT"; fi
[ -n "${GITHUB_STEP_SUMMARY:-}" ] && cat "$REPORT" >> "$GITHUB_STEP_SUMMARY"
exit $FAILED
