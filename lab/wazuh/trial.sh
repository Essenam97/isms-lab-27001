#!/usr/bin/env bash
# Feasibility trial for Wazuh on a GitHub-hosted runner (action A11).
# Starts the official single-node stack and measures start time and memory.
# This is not a control test: it only answers "can Wazuh run here?".
set -u

WAZUH_TAG=v4.12.0
REPORT="$PWD/trial-report.md"
LIMIT=900   # give up after 15 minutes

ready () { # name; returns 0 when the component answers
  case $1 in
    indexer)   curl -sk -u admin:SecretPassword https://localhost:9200/_cluster/health | grep -Eq '"status":"(green|yellow)"' ;;
    manager)   curl -sk -u 'wazuh-wui:MyS3cr37P450r.*-' -X POST 'https://localhost:55000/security/user/authenticate?raw=true' | grep -q '\.' ;;
    dashboard) [ "$(curl -sk -o /dev/null -w '%{http_code}' https://localhost/app/login)" = "200" ] ;;
  esac
}

{
  echo "# Wazuh feasibility trial (lab run)"
  echo
  echo "| Item | Value |"
  echo "|---|---|"
  echo "| Date (UTC) | $(date -u '+%Y-%m-%d %H:%M:%S') |"
  echo "| Commit | ${GITHUB_SHA:-local} |"
  echo "| Run | ${GITHUB_SERVER_URL:-}/${GITHUB_REPOSITORY:-}/actions/runs/${GITHUB_RUN_ID:-local} |"
  echo "| Wazuh docker tag | $WAZUH_TAG |"
  echo "| Runner CPUs | $(nproc) |"
  echo "| Runner memory before start (MiB) | $(free -m | awk '/Mem:/ {print "total " $2 ", used " $3 ", available " $7}') |"
  echo
  echo "Default Wazuh passwords are used: the runner is private to this run and destroyed afterwards. A real setup changes them first."
} > "$REPORT"

sudo sysctl -w vm.max_map_count=262144 > /dev/null
git clone -q --depth 1 --branch "$WAZUH_TAG" https://github.com/wazuh/wazuh-docker.git /tmp/wazuh-docker \
  || { echo "| Clone of wazuh-docker $WAZUH_TAG | failed |" >> "$REPORT"; exit 1; }
cd /tmp/wazuh-docker/single-node
docker compose -f generate-indexer-certs.yml run --rm generator > /tmp/certs.log 2>&1 \
  || { echo; echo "Certificate generation failed." >> "$REPORT"; tail -20 /tmp/certs.log; exit 1; }

docker compose pull -q
START=$(date +%s)
docker compose up -d

declare -A T
while :; do
  NOW=$(( $(date +%s) - START ))
  for c in indexer manager dashboard; do
    [ -z "${T[$c]:-}" ] && ready "$c" && T[$c]=$NOW && echo "$c ready after ${NOW}s"
  done
  [ -n "${T[indexer]:-}" ] && [ -n "${T[manager]:-}" ] && [ -n "${T[dashboard]:-}" ] && break
  [ "$NOW" -ge "$LIMIT" ] && break
  sleep 10
done

{
  echo
  echo "## Start time (images already pulled)"
  echo
  echo "| Component | Ready after |"
  echo "|---|---|"
  for c in indexer manager dashboard; do echo "| $c | ${T[$c]:-not ready within ${LIMIT} s} $( [ -n "${T[$c]:-}" ] && echo s) |"; done
  echo
  echo "## Memory once started"
  echo
  echo "| Container | Memory use |"
  echo "|---|---|"
  docker stats --no-stream --format '| {{.Name}} | {{.MemUsage}} |'
  echo
  echo "Runner memory after start (MiB): $(free -m | awk '/Mem:/ {print "total " $2 ", used " $3 ", available " $7}')"
} >> "$REPORT"

OK=0
for c in indexer manager dashboard; do [ -n "${T[$c]:-}" ] || OK=1; done
echo >> "$REPORT"
if [ $OK -eq 0 ]; then echo "Result: all three components started." >> "$REPORT"; else echo "Result: at least one component did not start within ${LIMIT} seconds." >> "$REPORT"; docker compose logs --tail=80; fi
[ -n "${GITHUB_STEP_SUMMARY:-}" ] && cat "$REPORT" >> "$GITHUB_STEP_SUMMARY"
docker compose down -v > /dev/null 2>&1
exit $OK
