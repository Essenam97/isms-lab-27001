#!/usr/bin/env bash
# Control tests WZ-01 to WZ-05 for detection rules (action A11).
# Uses the Wazuh logtest API: a log line goes in, the rule it triggers comes out.
# WZ-03 to WZ-05 use real log lines written by Keycloak during this run.
# Helper functions set variables in the current shell: never call them inside $(...).
set -u

REPORT="$PWD/test-report.md"
FAILED=0
API_USER='wazuh-wui'
API_PASS='MyS3cr37P450r.*-'
KC=lagune-keycloak
SSH_LINE='Oct 15 21:07:00 linux-agent sshd[29205]: Invalid user blimey from 18.18.18.18 port 48928'

{
  echo "# Wazuh control test report (lab run)"
  echo
  echo "| Item | Value |"
  echo "|---|---|"
  echo "| Date (UTC) | $(date -u '+%Y-%m-%d %H:%M:%S') |"
  echo "| Commit | ${GITHUB_SHA:-local} |"
  echo "| Run | ${GITHUB_SERVER_URL:-}/${GITHUB_REPOSITORY:-}/actions/runs/${GITHUB_RUN_ID:-local} |"
  echo "| Wazuh docker tag | v4.12.0 |"
  echo
  echo "This is a test of the lab, not of a production system. Lagune Payroll is fictional. Default Wazuh passwords are used on a runner destroyed after the run."
  echo
  echo "| Test | Control | Expected | Observed | Result |"
  echo "|---|---|---|---|---|"
} > "$REPORT"

result () { local r="PASS"; [ "$5" -eq 0 ] || { r="FAIL"; FAILED=1; }; echo "| $1 | $2 | $3 | $4 | $r |" >> "$REPORT"; echo "$1 $r: $4"; }
setup_fail () { echo "| setup | n/a | $1 | $2 | FAIL |" >> "$REPORT"; echo "Setup failed: $1: $2"; [ -n "${GITHUB_STEP_SUMMARY:-}" ] && cat "$REPORT" >> "$GITHUB_STEP_SUMMARY"; exit 1; }

TOKEN=$(curl -sk -u "$API_USER:$API_PASS" -X POST 'https://localhost:55000/security/user/authenticate?raw=true')
[[ "$TOKEN" =~ ^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]] || setup_fail "Wazuh API token" "no token"

SESSION=""
logtest () { # format event; sets RULE, LEVEL, SESSION (keeps the session if SESSION is set)
  local body
  body=$(jq -n --arg ev "$2" --arg fmt "$1" --arg tok "$SESSION" \
    '{event:$ev, log_format:$fmt, location:"lab"} + (if $tok=="" then {} else {token:$tok} end)')
  curl -sk -X PUT "https://localhost:55000/logtest" -H "Authorization: Bearer $TOKEN" \
    -H 'Content-Type: application/json' -d "$body" > /tmp/lt.json
  SESSION=$(jq -r '.data.token // empty' /tmp/lt.json)
  RULE=$(jq -r '.data.output.rule.id // "none"' /tmp/lt.json)
  LEVEL=$(jq -r '.data.output.rule.level // "none"' /tmp/lt.json)
}

# ---- WZ-01 Built-in rule: one failed SSH login (8.16)
SESSION=""; logtest syslog "$SSH_LINE"
[ "$RULE" = "5710" ] && [ "$LEVEL" = "5" ]
result WZ-01 8.16 "Built-in rule 5710, level 5" "rule $RULE, level $LEVEL" $?

# ---- WZ-02 Built-in rule: 8 failed SSH logins from one address (8.16)
SESSION=""; for i in 1 2 3 4 5 6 7; do logtest syslog "$SSH_LINE"; done; R7=$RULE
logtest syslog "$SSH_LINE"
[ "$R7" = "5710" ] && [ "$RULE" = "5712" ] && [ "$LEVEL" = "10" ]
result WZ-02 8.16 "Events 1 to 7: rule 5710; event 8: rule 5712, level 10" "event 7: rule $R7; event 8: rule $RULE, level $LEVEL" $?

# ---- Real Keycloak lines: 5 failed logins for a user that does not exist
for i in 1 2 3 4 5; do
  curl -s -o /dev/null -d grant_type=password -d client_id=admin-cli -d username=wz-probe -d password=wrong \
    http://localhost:8080/realms/lagune/protocol/openid-connect/token
done
sleep 3
docker logs "$KC" 2>&1 | grep '^{' > /tmp/kc.jsonl
jq -c 'select(.loggerName=="org.keycloak.events" and (.message|test("LOGIN_ERROR")))' /tmp/kc.jsonl > /tmp/kc-errors.jsonl 2>/dev/null
N=$(wc -l < /tmp/kc-errors.jsonl)
if [ "$N" -lt 5 ]; then
  echo "Keycloak lines (first 5):"; head -5 /tmp/kc.jsonl
  setup_fail "5 LOGIN_ERROR lines from Keycloak in JSON" "found $N; see the job log for the line format"
fi
OTHER=$(jq -c 'select(.loggerName!="org.keycloak.events")' /tmp/kc.jsonl | tail -1)
FIRST=$(head -1 /tmp/kc-errors.jsonl)
{
  echo
  echo "First real Keycloak line used (truncated to 300 characters):"
  echo
  echo '```'
  echo "${FIRST:0:300}"
  echo '```'
  echo
} > /tmp/sample.md

# ---- WZ-03 Custom rule: one real Keycloak failed login (8.15, 8.16)
SESSION=""; logtest json "$FIRST"
[ "$RULE" = "100100" ] && [ "$LEVEL" = "5" ]
result WZ-03 "8.15, 8.16" "Lagune rule 100100, level 5" "rule $RULE, level $LEVEL" $?

# ---- WZ-04 Custom rule: 5 real Keycloak failed logins (8.16, R07)
SESSION=""; i=0; R4=""
while IFS= read -r line; do
  i=$((i+1)); logtest json "$line"; [ "$i" -eq 4 ] && R4=$RULE; [ "$i" -eq 5 ] && break
done < /tmp/kc-errors.jsonl
[ "$R4" = "100100" ] && [ "$RULE" = "100101" ] && [ "$LEVEL" = "10" ]
result WZ-04 "8.16" "Events 1 to 4: rule 100100; event 5: rule 100101, level 10" "event 4: rule $R4; event 5: rule $RULE, level $LEVEL" $?

# ---- WZ-05 Negative control: a real Keycloak line that is not an event (8.16)
SESSION=""; logtest json "$OTHER"
[ "$RULE" != "100100" ] && [ "$RULE" != "100101" ]
result WZ-05 8.16 "Ordinary Keycloak log line does not trigger a Lagune rule" "rule $RULE" $?

cat /tmp/sample.md >> "$REPORT"
if [ "$FAILED" -eq 0 ]; then echo "All tests passed." >> "$REPORT"; else echo "At least one test failed. A failed test is a finding to record, not a file to fix silently." >> "$REPORT"; fi
[ -n "${GITHUB_STEP_SUMMARY:-}" ] && cat "$REPORT" >> "$GITHUB_STEP_SUMMARY"
exit $FAILED
