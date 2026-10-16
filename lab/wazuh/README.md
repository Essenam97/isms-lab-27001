# Wazuh: log collection and monitoring for Lagune Payroll (action A11)

Status: control tests automated; run 1 on 2026-10-16 passed, see [evidence](../../evidence/A11/2026-10-16-wazuh-run-1.md) (WZ-05 to repeat). Runs are listed in the [evidence register](../../evidence/A11/README.md).

Wazuh has three services: an indexer (search engine for the logs), a manager (receives and analyses events) and a dashboard. A feasibility trial on 2026-10-16 showed that the official single-node stack starts on a GitHub-hosted runner and leaves about 12 GiB of memory free; Wazuh was kept.

## What this covers

| Risk | SoA controls | Design choice |
|---|---|---|
| R07 (staff account takeover after phishing) | 8.15, 8.16 | Keycloak logs are read by Wazuh; a custom rule raises an alert at each failed login, and a stronger alert after 5 failed logins within 2 minutes |
| R07, EXT-05 | 8.16 | Built-in Wazuh rules for SSH password guessing are checked as a baseline |

## How the tests work

The tests use the Wazuh logtest API: a log line is sent to the manager, which answers with the rule it triggers and its alert level, using the same rules as normal analysis. For the Keycloak tests the lines are not written by hand: the workflow starts Keycloak beside Wazuh with JSON console logs, makes 5 failed logins, and sends the lines Keycloak really wrote.

## Files

| File | Content |
|---|---|
| `rules/lagune_rules.xml` | Custom rules 100100 (one failed Keycloak login, level 5) and 100101 (5 within 2 minutes, level 10) |
| `start-wazuh.sh` | Starts Wazuh `v4.12.0`, copies the custom rules into the manager, restarts it and waits until the API returns a real token (three-part JWT) |
| `keycloak-json-logs.yml` | Compose override that starts the Keycloak of `lab/keycloak` with JSON logs |
| `tests/run-tests.sh` | Tests WZ-01 to WZ-05 |
| `trial.sh` | Feasibility trial (kept as a record; its manager check was weak and is not reused) |

## Design decisions

| Decision | Reason | Limit accepted for the lab |
|---|---|---|
| Logtest API instead of an agent | No agent to install; tests the rules directly and repeatably | Does not test log transport from Keycloak to Wazuh. A real setup would add a log collection path and a test that it delivers |
| Built-in JSON decoder | Keycloak can write JSON logs; no custom decoder to maintain | The user name stays inside the message text, so rule 100101 counts failures of all users together. A burst of failures spread over many accounts (password spraying) is caught; a slow attack on one account is not |
| Failed logins for a user that does not exist | No admin setup needed to produce real lines | Keycloak's own lockout (KC-03) does not apply to unknown users; that is tested separately in `lab/keycloak` |
| Default Wazuh passwords | Runner private to the run and destroyed afterwards | A real setup changes them before anything else |

## Test plan

| Test | Control | What the script does | Expected result |
|---|---|---|---|
| WZ-01 | 8.16 | Sends one line of an SSH login with an unknown user | Built-in rule 5710, level 5 |
| WZ-02 | 8.16 | Sends the same line 8 times in one session | Events 1 to 7: rule 5710; event 8: rule 5712, level 10 |
| WZ-03 | 8.15, 8.16 | Sends one real Keycloak `LOGIN_ERROR` line | Lagune rule 100100, level 5 |
| WZ-04 | 8.16 | Sends 5 real Keycloak `LOGIN_ERROR` lines in one session | Events 1 to 4: rule 100100; event 5: rule 100101, level 10 |
| WZ-05 | 8.16 | Sends a real Keycloak line that is not an event | Line decoded as JSON, API call successful, no Lagune rule (negative control: shows rule 100100 does not match every Keycloak line) |

Rule numbers 5710 and 5712 and their levels come from the Wazuh documentation page "Testing decoders and rules".
