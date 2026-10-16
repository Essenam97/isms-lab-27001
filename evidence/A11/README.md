# Evidence register: A11 (logging and monitoring)

Feasibility trials are records of the tool choice, not control evidence.

| Run | Date (UTC) | Commit | Type | Result | Note |
|---|---|---|---|---|---|
| 1 | 2026-10-16 05:07:02 | 6a524fb | Feasibility trial | All three components started | Run https://github.com/Essenam97/isms-lab-27001/actions/runs/38854084669, artifact sha256:fd2626753ff9bb50d68491d4772144f5ae87d51bcf56fe07ebbb05baa6faf6e9 |

## Trial 1: measurements

| Item | Value |
|---|---|
| Wazuh docker tag | v4.12.0 |
| Runner | 4 CPUs, 15 989 MiB of memory |
| Ready after (images already pulled) | Indexer, manager and dashboard all reported ready at the check made 21 s after start |
| Memory per container | Indexer 1.387 GiB, manager 548.1 MiB, dashboard 217.3 MiB |
| Runner memory available | 14 483 MiB before start, 12 593 MiB after |

## Review notes

1. The three components show the same time because the script checks every 10 seconds. The real start times are somewhere between the previous check and 21 s; the trial does not measure them more precisely.
2. The readiness check of the indexer requires a cluster status of green or yellow. The check of the manager only looks for a dot in the answer to an authentication request, which an error message could also contain. It must be replaced, before any control test, by a check that the answer is a token.
3. The stack used about 1.9 GiB of the runner's memory, leaving about 12.3 GiB. That is enough to run Keycloak beside it.

## Decision

Wazuh is kept as the logging and monitoring tool of the lab. Control tests for A11 are the next step.
