# Evidence A04: Keycloak control tests, run 2

| Item | Value |
|---|---|
| Action | A04 (staff identity and access) |
| Risks | R07, R12 |
| SoA controls tested | 5.17, 5.18, 6.5, 8.5, 8.15 |
| Date (UTC) | 2026-10-16 04:18:23 |
| Commit tested | 62d0a326ccc92457549c576f037cd195d750b4d6 |
| Workflow run | https://github.com/Essenam97/isms-lab-27001/actions/runs/38849883032 |
| Keycloak image tag | 26.0 |
| Artifact | keycloak-test-report, 792 bytes, sha256:84599592381a45a70d8dab34ee6442052dec235dda8b0021f65ef0d01b914ec2 |
| Environment | GitHub-hosted runner, destroyed after the run. Lab only: Lagune Payroll is fictional and has no production system |
| Reviewed by | Repository owner, 2026-10-16 |

## Results (copied from the run summary)

| Test | Control | Expected | Observed | Result |
|---|---|---|---|---|
| KC-01 | 5.17 | 10-character password refused | HTTP 400 invalidPasswordMinLengthMessage | PASS |
| KC-02 | 8.5 | New user has CONFIGURE_TOTP; token request refused (HTTP 400) before MFA is set up | requiredActions=["CONFIGURE_TOTP"]; login HTTP 400 Account is not fully set up | PASS |
| KC-03 | 8.5, 8.15 | User temporarily disabled after 5 failures; failures logged | {"disabled":true,"numFailures":2}; LOGIN_ERROR events=6 | PASS |
| KC-04 | 5.18, 6.5 | Login HTTP 200 before, HTTP 400 after disabling | before HTTP 200; after HTTP 400 Account disabled | PASS |
| KC-05 | 8.15 | Group change recorded as admin event | add to group HTTP 204; matching admin events=1 | PASS |

## Review notes

1. Run 1 (2026-10-16 04:09:51 UTC, commit 46b8fd1) is not used as evidence. In KC-02 and KC-04 the script read an HTTP code from a previous request (204) because the login function ran in a subshell. Those two verdicts did not depend on the login result. The script was fixed in commit 62d0a32 and the tests now require HTTP 400.
2. KC-03: the user is disabled and 6 login errors are logged, but the brute force counter shows 2 failures, not 5 or 6. The cause is not known. The test criterion is met; the counter value is an open question to check against the Keycloak documentation.
3. KC-04 removes the MFA required action from its test user. This shows that MFA depends on a required action an administrator can remove. Admin events make such a change traceable; the quarterly access review (5.18) must look for it.

## What this evidence shows and does not show

It shows that the Keycloak configuration in `lab/keycloak/realm-lagune.json` enforces the password policy, requires MFA setup for new users, locks accounts after repeated failures, refuses disabled accounts and records admin changes, in the lab, on the date above.

It does not show that these controls are implemented at Lagune Payroll, which is fictional, and it does not test the Gitea and Nextcloud logins through Keycloak (not deployed yet). The SoA status of the controls is therefore not changed.
