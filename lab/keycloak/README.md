# Keycloak: identity and access for Lagune Payroll (action A04)

Status: tests automated; run 2 on 2026-10-16 passed, see [evidence](../../evidence/A04/2026-10-16-keycloak-run-2.md). The lab machine (1.6 GiB of RAM) cannot host the stack, so the tests run on a GitHub-hosted runner through the workflow [keycloak-controls.yml](../../.github/workflows/keycloak-controls.yml). A test counts as run only when a report from a workflow run, with its date and run link, is stored in `evidence/A04/`.

| Run | Date (UTC) | Result | Used as evidence |
|---|---|---|---|
| 1 | 2026-10-16 04:09:51 | 5 PASS, but KC-02 and KC-04 verdicts invalid (script defect) | No |
| 2 | 2026-10-16 04:18:23 | 5 PASS | Yes |

## What this covers

| Risk | SoA controls | Design choice |
|---|---|---|
| R07 (staff account takeover after phishing) | 5.17, 8.5 | MFA (TOTP) required for every user at first login; password policy of 12 characters minimum; account locked for a growing delay after 5 failed attempts |
| R12 (departing employee keeps access) | 5.16, 5.18, 6.5 | One account per person in one place; disabling it in Keycloak cuts access to Gitea and Nextcloud at once |
| R02, R03 (access logs) | 8.15 | Login events and admin events recorded and kept 90 days |

## Files

| File | Content |
|---|---|
| `docker-compose.yml` | One Keycloak container in development mode, memory limited to 768 MB |
| `.env.example` | Names of the admin variables. The real `.env` file holds the password and is excluded from Git by `.gitignore` |
| `realm-lagune.json` | The `lagune` realm: password policy, brute force protection, MFA as default required action, event logging, team groups, and two OIDC clients (Gitea and Nextcloud) |

## Design decisions

| Decision | Reason | Limit accepted for the lab |
|---|---|---|
| TOTP with an authenticator app | Free, works offline, no SMS cost | Phones are personal devices (R11); covered by the BYOD policy |
| Temporary lockout, not permanent | A permanent lockout lets an attacker block any account by guessing wrong 5 times | An attacker can try 5 passwords per wait period; MFA covers this |
| Events kept 90 days | Enough for a quarterly access review | Wazuh would keep logs longer; not deployed in this lab |
| Development mode with H2 | Fits in under 1 GB of RAM | No HTTPS, data lost if the container is deleted; never for production |
| Client secrets not in the file | Keycloak generates them at import | They must be copied into Gitea and Nextcloud by hand |

## Test plan

The script [tests/run-tests.sh](tests/run-tests.sh) runs these tests through the Keycloak admin REST API. Test users are created by the script; the runner and its data are destroyed after each run.

| Test | Control | What the script does | Expected result |
|---|---|---|---|
| KC-01 | 5.17 | Creates a user and sets the password `Lagune2026` (10 characters) | Refused with HTTP 400 |
| KC-02 | 8.5 | Creates a user with a valid password, reads its required actions, tries to get a token | `CONFIGURE_TOTP` is required, and no token is issued before MFA is set up |
| KC-03 | 8.5, 8.15 | Sends 6 wrong passwords for one user | User temporarily disabled by brute force protection; at least 5 `LOGIN_ERROR` events recorded |
| KC-04 | 5.18, 6.5 | Logs in with a user, disables the user, logs in again | First login works, second is refused |
| KC-05 | 8.15 | Adds a user to the `infrastructure` group | Change recorded as an admin event |

KC-04 removes the MFA required action from its test user to check that disabling an account works on its own. This also shows a limit of the design: MFA depends on a required action that an administrator can remove. Admin events (KC-05) make such a removal traceable; the quarterly access review must check it.

## Reading a result

Each run writes `test-report.md`, shown on the run summary page in the Actions tab and kept as an artifact named `keycloak-test-report`. A failed test is a finding: it is recorded in the nonconformity log (clause 10.2) with its cause, not hidden by changing the test.

## How to run it on your own machine

Requirements: Docker with the Compose plugin, about 1 GB of free RAM.

1. Copy `.env.example` to `.env` and set a strong admin password.
2. Run `docker compose up -d` in this folder.
3. Open `http://localhost:8080`, log in with the admin account, select the `lagune` realm.
4. Run tests KC-01 to KC-05 and record each result with date and screenshot.
