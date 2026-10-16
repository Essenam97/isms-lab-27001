# Evidence A07 and A13: Nextcloud control tests, run 1

| Item | Value |
|---|---|
| Actions | A07 (support access), A13 (endpoints and information handling) |
| Risks | R03, R07, R08 |
| SoA controls tested | 5.14, 5.17, 8.3, 8.24 |
| Date (UTC) | 2026-10-16 04:48:05 |
| Commit tested | d862577feb50b55bd45fd080eec3b7e4b97cbfd1 |
| Workflow run | https://github.com/Essenam97/isms-lab-27001/actions/runs/38852408447 |
| Nextcloud version | 31.0.14 |
| Artifact | nextcloud-test-report, 755 bytes, sha256:29728059085e3f81a1a9f6688fd4427ee8b334fd43d99d805c367db72b60b165 |
| Environment | GitHub-hosted runner, destroyed after the run. Lab only: Lagune Payroll is fictional and has no production system |
| Reviewed by | Repository owner, 2026-10-16 |

## Results (copied from the run summary)

| Test | Control | Expected | Observed | Result |
|---|---|---|---|---|
| NC-01 | 5.17 | User with a 10-character password not created | create HTTP 400 ; lookup HTTP 404 | PASS |
| NC-02 | 5.14 | Link share without password refused; no share exists | create HTTP 403 Passwords are enforced for link and mail shares; shares on file=0 | PASS |
| NC-03 | 5.14 | Share created with an expiry date no later than 2026-10-23 | create HTTP 200; expiration=2026-10-23 | PASS |
| NC-04 | 8.24 | File on disk starts with HBEGIN and has no plaintext; user1 still reads it | disk header=HBEGIN; marker on disk: no; marker via WebDAV: yes | PASS |
| NC-05 | 8.3 | user2 cannot read user1's file | HTTP 404; content leaked: no | PASS |

## Review notes

1. NC-01 is weak evidence. The user was not created, but the error message is empty, so the run does not show that the password was the reason: any other validation error would give the same result. Cause of the empty message: the request did not ask for JSON, Nextcloud answered in XML, and the script read it as JSON. The test was changed after this run: it asks for JSON and first creates a user with a valid password as a positive control. NC-01 counts as evidence only from the next run that passes.
2. NC-02: the refusal message names the policy ("Passwords are enforced for link and mail shares"), so the cause is shown.
3. NC-03: Nextcloud did not refuse a link without an expiry date; it set one, exactly 7 days after the run date.
4. NC-04 reads the file on the server's disk, outside Nextcloud. The file starts with the encryption header and the test marker is not readable; the same file downloaded by its owner contains the marker.
5. NC-05: Nextcloud answers 404 to another user, so it does not reveal that the file exists.

## What this evidence shows and does not show

It shows that, in the lab on the date above, Nextcloud refuses public links without a password, limits their life to 7 days, stores files encrypted on disk and keeps each user's files private. NC-01 is not accepted from this run (note 1).

It does not show protection against someone with full access to the running server, since the encryption key is stored on that server. It does not test login through Keycloak. The SoA status of the controls is not changed, because Lagune Payroll is fictional.
