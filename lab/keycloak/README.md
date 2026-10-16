# Keycloak: identity and access for Lagune Payroll (action A04)

Status: tests automated; run 2 on 2026-10-16 passed, see [evidence](../../evidence/A04/2026-10-16-keycloak-run-2.md). The lab machine (1.6 GiB of RAM) cannot host the stack, so the tests run on a GitHub-hosted runner through the workflow [keycloak-controls.yml](../../.github/workflows/keycloak-controls.yml). Runs are listed in the [evidence register](../../evidence/A04/README.md). A test counts as run only when a report from a workflow run, with its date and run link, is stored in `evidence/A04/`.

## What this covers

| Risk | SoA controls | Design choice |
|---|---|---|
| R07 (staff account takeover after phishing) | 5.17, 8.5 | MFA (TOTP) required at every login, in the browser and the direct grant flows; password policy of 12 characters minimum; account locked for a growing delay after 5 failed attempts |
| R12 (departing employee keeps access) | 5.16, 5.18, 6.5 | One account per person in one place; disabling it in Keycloak cuts access to Gitea and Nextcloud at once |
| R02, R03 (access logs) | 8.15 | Login events and admin events recorded and kept 400 days |

## Files

| File | Content |
|---|---|
| `docker-compose.yml` | One Keycloak container in development mode, memory limited to 768 MB |
| `.env.example` | Names of the admin variables. The real `.env` file holds the password and is excluded from Git by `.gitignore` |
| `realm-lagune.json` | The `lagune` realm: password policy, brute force protection, MFA as default required action, event logging with 400-day retention, team groups, and two OIDC clients (Gitea and Nextcloud) |
| `apply-mfa-flows.sh` | Run after start: copies the built-in browser and direct grant flows, makes their OTP step required, and binds the copies to the realm (OBS-01 of audit IA-2026-01) |

## Design decisions

| Decision | Reason | Limit accepted for the lab |
|---|---|---|
| TOTP with an authenticator app | Free, works offline, no SMS cost | Phones are personal devices (R11); covered by the BYOD policy |
| Temporary lockout, not permanent | A permanent lockout lets an attacker block any account by guessing wrong 5 times | An attacker can try 5 passwords per wait period; MFA covers this |
| Events kept 400 days | Longer than a quarter plus the time to run the review (NC-01 of audit IA-2026-01) | Administrator event retention is set with the realm attribute `adminEventsExpiration`. KC-08 shows the value is stored; the lab does not show that Keycloak reads this attribute name, which still has to be checked in the admin console |
| OTP required in the flows, not only as a required action | Removing the required action no longer opens a password-only login (OBS-01) | The flows are set by a script after start, not in `realm-lagune.json`: importing flows in the realm file would replace the built-in flows |
| Development mode with H2 | Fits in under 1 GB of RAM | No HTTPS, data lost if the container is deleted; never for production |
| Client secrets not in the file | Keycloak generates them at import | They must be copied into Gitea and Nextcloud by hand |

## Test plan

The script [tests/run-tests.sh](tests/run-tests.sh) runs these tests through the Keycloak admin REST API. Test users are created by the script; the runner and its data are destroyed after each run.

| Test | Control | What the script does | Expected result |
|---|---|---|---|
| KC-01 | 5.17 | Creates a user and sets the password `Lagune2026` (10 characters) | Refused with HTTP 400 |
| KC-02 | 8.5 | Creates a user with a valid password, reads its required actions, tries to get a token | `CONFIGURE_TOTP` is required, and no token is issued (HTTP 400 or 401) |
| KC-03 | 8.5, 8.15 | Sends 6 wrong passwords for one user | User temporarily disabled by brute force protection; at least 5 `LOGIN_ERROR` events recorded |
| KC-04 | 5.18, 6.5 | Logs in with a user through a temporary password-only client, disables the user, logs in again | First login HTTP 200, second HTTP 400 |
| KC-05 | 8.15 | Adds a user to the `infrastructure` group | Change recorded as an admin event |
| KC-06 | 8.5 | Removes the MFA required action from a user, then logs in with the password through the temporary client and through the realm flow | Temporary client HTTP 200 (shows the password is right); realm flow refused (HTTP 400 or 401) |
| KC-07 | 8.5 | Reads the flows bound to the realm and the clients | Both flows have the OTP step REQUIRED and no conditional OTP subflow; after the temporary client is deleted, no client overrides a flow |
| KC-08 | 8.15 | Reads the event retention settings of the running realm | 34560000 seconds (400 days) for login events and for administrator events |

The temporary client of KC-04 and KC-06 uses Keycloak's built-in password-only flow. It is a deliberate weakness, created only to give a baseline, and deleted before KC-07 checks that none is left.

## Reading a result

Each run writes `test-report.md`, shown on the run summary page in the Actions tab and kept as an artifact named `keycloak-test-report`. A failed test is a finding: it is recorded in the nonconformity log (clause 10.2) with its cause, not hidden by changing the test.

## How to run it on your own machine

Requirements: Docker with the Compose plugin, about 1 GB of free RAM.

1. Copy `.env.example` to `.env` and set a strong admin password.
2. Run `docker compose up -d` in this folder.
3. Open `http://localhost:8080`, log in with the admin account, select the `lagune` realm.
4. Run `bash apply-mfa-flows.sh` with `KC_URL`, `KC_ADMIN_USER` and `KC_ADMIN_PASSWORD` set, then `bash tests/run-tests.sh`.
