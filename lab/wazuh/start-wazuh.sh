#!/usr/bin/env bash
# Starts the official Wazuh single-node stack, installs the Lagune rules and
# waits until the manager API gives a real token. Used by the control tests.
set -u
WAZUH_TAG=v4.12.0
HERE="$PWD"
API_USER='wazuh-wui'
API_PASS='MyS3cr37P450r.*-'
MANAGER=single-node-wazuh.manager-1

jwt () { curl -sk -u "$API_USER:$API_PASS" -X POST 'https://localhost:55000/security/user/authenticate?raw=true'; }
is_jwt () { [[ "$1" =~ ^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]]; }
wait_api () {
  for i in $(seq 1 60); do T=$(jwt); is_jwt "$T" && { echo "Manager API ready ($1) after $((i*5)) s"; return 0; }; sleep 5; done
  echo "Manager API not ready ($1) after 5 minutes"; return 1
}

sudo sysctl -w vm.max_map_count=262144 > /dev/null
git clone -q --depth 1 --branch "$WAZUH_TAG" https://github.com/wazuh/wazuh-docker.git /tmp/wazuh-docker || exit 1
cd /tmp/wazuh-docker/single-node
docker compose -f generate-indexer-certs.yml run --rm generator > /tmp/certs.log 2>&1 || { tail -20 /tmp/certs.log; exit 1; }
docker compose up -d || exit 1
wait_api "first start" || { docker compose logs --tail=80 wazuh.manager; exit 1; }

docker cp "$HERE/rules/lagune_rules.xml" "$MANAGER:/var/ossec/etc/rules/lagune_rules.xml" || exit 1
docker exec "$MANAGER" chown wazuh:wazuh /var/ossec/etc/rules/lagune_rules.xml
docker exec "$MANAGER" chmod 660 /var/ossec/etc/rules/lagune_rules.xml
docker exec "$MANAGER" /var/ossec/bin/wazuh-control restart > /tmp/restart.log 2>&1 || { cat /tmp/restart.log; exit 1; }
sleep 10
wait_api "after loading Lagune rules" || { docker compose logs --tail=80 wazuh.manager; exit 1; }
