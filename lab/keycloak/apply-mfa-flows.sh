#!/usr/bin/env bash
# Makes the one-time code required at every login in the lagune realm (OBS-01).
# Copies the built-in "browser" and "direct grant" flows, changes their
# conditional OTP subflow to REQUIRED (other conditional subflows are not
# touched), and binds the copies to the realm.
# The built-in flows are left unchanged.
# Needs: curl, jq, KC_URL, KC_ADMIN_USER, KC_ADMIN_PASSWORD.
set -u
REALM=lagune

token () {
  curl -s -d grant_type=password -d client_id=admin-cli \
    --data-urlencode "username=$KC_ADMIN_USER" --data-urlencode "password=$KC_ADMIN_PASSWORD" \
    "$KC_URL/realms/master/protocol/openid-connect/token" | jq -r .access_token
}
api () { # method path [json]; body in /tmp/body, sets CODE
  local t; t=$(token)
  if [ -n "${3:-}" ]; then
    CODE=$(curl -s -o /tmp/body -w '%{http_code}' -X "$1" -H "Authorization: Bearer $t" -H 'Content-Type: application/json' -d "$3" "$KC_URL/admin/realms/$REALM$2")
  else
    CODE=$(curl -s -o /tmp/body -w '%{http_code}' -X "$1" -H "Authorization: Bearer $t" "$KC_URL/admin/realms/$REALM$2")
  fi
}
enc () { jq -rn --arg s "$1" '$s|@uri'; }

force_otp () { # source-flow new-flow
  api POST "/authentication/flows/$(enc "$1")/copy" "{\"newName\":\"$2\"}"
  [ "$CODE" = "201" ] || { echo "Copy of flow '$1' failed: HTTP $CODE"; cat /tmp/body; exit 1; }
  api GET "/authentication/flows/$(enc "$2")/executions"
  jq -c '.[] | select(.authenticationFlow==true and .requirement=="CONDITIONAL" and (.displayName|test("OTP")))' /tmp/body > /tmp/cond.jsonl
  [ -s /tmp/cond.jsonl ] || { echo "No conditional subflow found in '$2'"; jq -c '.[] | {displayName,requirement,level}' /tmp/body; exit 1; }
  while IFS= read -r ex; do
    upd=$(echo "$ex" | jq -c '.requirement="REQUIRED"')
    api PUT "/authentication/flows/$(enc "$2")/executions" "$upd"
    case "$CODE" in 202|204) echo "Flow '$2': $(echo "$ex" | jq -r .displayName) set to REQUIRED";; *) echo "Update failed: HTTP $CODE"; cat /tmp/body; exit 1;; esac
  done < /tmp/cond.jsonl
}

force_otp "browser" "lagune browser"
force_otp "direct grant" "lagune direct grant"
api PUT "" '{"browserFlow":"lagune browser","directGrantFlow":"lagune direct grant"}'
[ "$CODE" = "204" ] || { echo "Binding the flows failed: HTTP $CODE"; cat /tmp/body; exit 1; }
echo "Flows bound to realm $REALM"
