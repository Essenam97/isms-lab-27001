#!/usr/bin/env bash
# Control tests KC-01 to KC-08 for the lagune realm (action A04).
# Since run 4: KC-04 uses a temporary password-only client as baseline,
# KC-06 to KC-08 added for OBS-01 and NC-01 of audit IA-2026-01.
# Since run 5: Keycloak error lines are copied into the report when a test fails.
# Since run 6: direct grant is off for all realm clients; user logins in the
# tests go through the temporary baseline client, created before KC-02.
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

user_login () { # username password [client]; writes body to /tmp/login, sets CODE
  # Not called inside $(...): a subshell would lose CODE (bug found in run 1).
  CODE=$(curl -s -o /tmp/login -w '%{http_code}' -d grant_type=password -d "client_id=${3:-admin-cli}" \
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

# Baseline client: a temporary client that uses the built-in password-only
# "direct grant" flow. It exists only during the tests and is deleted at the
# end; KC-07 checks that no client with a flow override is left.
DG_ID=$(api GET "/authentication/flows" | jq -r '.[] | select(.alias=="direct grant") | .id')
api POST /clients "{\"clientId\":\"kc-test-baseline\",\"publicClient\":true,\"standardFlowEnabled\":false,\"directAccessGrantsEnabled\":true,\"authenticationFlowBindingOverrides\":{\"direct_grant\":\"$DG_ID\"}}" > /dev/null
BASE_CODE=$CODE
BASE_ID=$(api GET "/clients?clientId=kc-test-baseline" | jq -r '.[0].id')
[ "$BASE_CODE" = "201" ] && [ -n "$DG_ID" ] || { echo "| setup | n/a | Temporary baseline client | HTTP $BASE_CODE, flow id ${DG_ID:-none} | FAIL |" >> "$REPORT"; exit 1; }

# KC-02 MFA required for a new user (8.5)
set_password "$U1" "$GOOD_PASS"
RA=$(api GET "/users/$U1" | jq -c '.requiredActions')
user_login kc-test-1 "$GOOD_PASS" kc-test-baseline; C2=$CODE
DESC=$(jq -r '.error_description // empty' /tmp/login)
echo "$RA" | grep -q CONFIGURE_TOTP && [ "$C2" = "400" ]
result KC-02 8.5 "New user has CONFIGURE_TOTP; even the password-only baseline client refuses a token (HTTP 400) before MFA is set up" "requiredActions=$RA; login HTTP $C2 ${DESC}" $?

# KC-03 Brute force protection and login error events (8.5, 8.15)
U2=$(create_user kc-test-2)
set_password "$U2" "$GOOD_PASS"
# Since run 6: one attempt every 1.5 s. Run 5's log showed the account locked
# after 2 failures sent 40 ms apart, which matches Keycloak's quick login check
# (failures less than 1 s apart), not the 5-failure rule of POL-01.
for i in 1 2 3 4 5 6; do user_login kc-test-2 'wrong-password' kc-test-baseline > /dev/null; sleep 1.5; done
BF=$(api GET "/attack-detection/brute-force/users/$U2" | jq -c '{disabled, numFailures}')
NERR=$(api GET "/events?type=LOGIN_ERROR&user=$U2&max=50" | jq 'length')
echo "$BF" | jq -e '.disabled == true and .numFailures >= 5' > /dev/null && [ "${NERR:-0}" -ge 5 ]
result KC-03 "8.5, 8.15" "Attempts 1.5 s apart: user temporarily disabled with at least 5 failures counted; failures logged" "$BF; LOGIN_ERROR events=$NERR" $?

# KC-04 Disabled account cannot log in (5.18, 6.5)
U3=$(create_user kc-test-3)
set_password "$U3" "$GOOD_PASS"
update_user "$U3" '.requiredActions = []'
user_login kc-test-3 "$GOOD_PASS" kc-test-baseline; BEFORE=$CODE
update_user "$U3" '.enabled = false'
user_login kc-test-3 "$GOOD_PASS" kc-test-baseline; AFTER=$CODE
[ "$BEFORE" = "200" ] && [ "$AFTER" = "400" ]
result KC-04 "5.18, 6.5" "Login HTTP 200 before, HTTP 400 after disabling (baseline client)" "before HTTP $BEFORE; after HTTP $AFTER $(jq -r '.error_description // empty' /tmp/login)" $?

# KC-05 Admin events for group changes (8.15)
GID=$(api GET "/groups?search=infrastructure" | jq -r '.[] | select(.name=="infrastructure") | .id')
api PUT "/users/$U2/groups/$GID" > /dev/null; C5=$CODE
NADM=$(api GET "/admin-events?resourceTypes=GROUP_MEMBERSHIP&max=50" | jq --arg u "$U2" '[.[] | select(.resourcePath | contains($u))] | length')
[ "$C5" = "204" ] && [ "${NADM:-0}" -ge 1 ]
result KC-05 8.15 "Group change recorded as admin event" "add to group HTTP $C5; matching admin events=$NADM" $?

# KC-06 No password-only API login through realm clients (8.5, OBS-01)
U4=$(create_user kc-test-4)
set_password "$U4" "$GOOD_PASS"
update_user "$U4" '.requiredActions = []'
user_login kc-test-4 "$GOOD_PASS" kc-test-baseline; C6B=$CODE
user_login kc-test-4 "$GOOD_PASS"; C6=$CODE; E6=$(jq -r '.error // empty' /tmp/login)
[ "$C6B" = "200" ] && [ "$C6" = "400" ] && [ "$E6" = "unauthorized_client" ]
result KC-06 "8.5" "Required action removed: password works on the baseline client (HTTP 200); admin-cli of the realm refuses the direct grant (HTTP 400 unauthorized_client)" "baseline HTTP $C6B; admin-cli HTTP $C6 $E6 $(jq -r '.error_description // empty' /tmp/login)" $?

# Remove the baseline client before checking the configuration
api DELETE "/clients/$BASE_ID" > /dev/null; CDEL=$CODE

# KC-07 Realm flows require the one-time code; no client overrides them (8.5)
REALM_REP=$(api GET "")
BF=$(echo "$REALM_REP" | jq -r .browserFlow); DF=$(echo "$REALM_REP" | jq -r .directGrantFlow)
BOTP=$(api GET "/authentication/flows/$(jq -rn --arg s "$BF" '$s|@uri')/executions" | jq -r '[.[] | select(.providerId=="auth-otp-form")][0].requirement // "none"')
BCOND=$(api GET "/authentication/flows/$(jq -rn --arg s "$BF" '$s|@uri')/executions" | jq '[.[] | select(.authenticationFlow==true and .requirement=="CONDITIONAL" and (.displayName|test("OTP")))] | length')
DOTP=$(api GET "/authentication/flows/$(jq -rn --arg s "$DF" '$s|@uri')/executions" | jq -r '[.[] | select(.providerId=="direct-grant-validate-otp")][0].requirement // "none"')
DCOND=$(api GET "/authentication/flows/$(jq -rn --arg s "$DF" '$s|@uri')/executions" | jq '[.[] | select(.authenticationFlow==true and .requirement=="CONDITIONAL" and (.displayName|test("OTP")))] | length')
NOVR=$(api GET "/clients" | jq '[.[] | select((.authenticationFlowBindingOverrides // {}) | length > 0)] | length')
NDG=$(api GET "/clients" | jq '[.[] | select(.directAccessGrantsEnabled==true)] | length')
[ "$BF" = "lagune browser" ] && [ "$DF" = "lagune direct grant" ] && [ "$BOTP" = "REQUIRED" ] && [ "$DOTP" = "REQUIRED" ] && [ "$BCOND" = "0" ] && [ "$DCOND" = "0" ] && [ "$NOVR" = "0" ] && [ "$NDG" = "0" ] && [ "$CDEL" = "204" ]
result KC-07 "8.5" "Both realm flows have the OTP step REQUIRED and no conditional OTP subflow; no client overrides a flow or accepts the direct grant" "browser=$BF (OTP $BOTP, conditional OTP subflows $BCOND); direct grant=$DF (OTP $DOTP, conditional OTP subflows $DCOND); clients with overrides=$NOVR; clients with direct grant=$NDG; baseline client delete HTTP $CDEL" $?

# KC-08 Retention of login and administrator events (8.15, NC-01)
EE=$(echo "$REALM_REP" | jq -r '.eventsExpiration // "none"')
AE=$(echo "$REALM_REP" | jq -r '.attributes.adminEventsExpiration // "none"')
[ "$EE" = "34560000" ] && [ "$AE" = "34560000" ]
result KC-08 "8.15" "Login and administrator events kept 400 days (34560000 s)" "eventsExpiration=$EE; attributes.adminEventsExpiration=$AE" $?

# Since run 5: when a test fails, copy Keycloak's own error lines into the
# report, so that the cause is in the report and not only in the job log.
if [ "$FAILED" -ne 0 ]; then
  {
    echo
    echo "## Keycloak server errors (first 3, 25 lines each, from the container log)"
    echo
    echo '```'
    docker logs lagune-keycloak 2>&1 | grep -A 25 -m 3 -E 'ERROR|Exception' | cut -c1-300 | head -90
    echo '```'
  } >> "$REPORT"
fi

echo >> "$REPORT"
if [ "$FAILED" -eq 0 ]; then echo "All tests passed." >> "$REPORT"; else echo "At least one test failed. A failed test is a finding to record, not a file to fix silently." >> "$REPORT"; fi
[ -n "${GITHUB_STEP_SUMMARY:-}" ] && cat "$REPORT" >> "$GITHUB_STEP_SUMMARY"
exit $FAILED
