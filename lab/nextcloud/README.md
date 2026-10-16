# Nextcloud: file sharing and storage for Lagune Payroll (actions A07, A13)

Status: tests automated, not yet run. The tests run on a GitHub-hosted runner through the workflow [nextcloud-controls.yml](../../.github/workflows/nextcloud-controls.yml). Runs and their status are listed in the [evidence register](../../evidence/A13/README.md).

## What this covers

| Risk | SoA controls | Design choice |
|---|---|---|
| R03 (support staff see data they should not), R08 (lost laptop with customer exports) | 5.14 | Public links need a password and expire after at most 7 days |
| R08 | 8.24 | Server-side encryption: files are stored encrypted on the server's disk |
| R03 | 8.3 | Each user's files are private unless shared |
| R07 | 5.17 | Passwords of 12 characters minimum |

## Files

| File | Content |
|---|---|
| `docker-compose.yml` | One Nextcloud container with SQLite, memory limited to 1 GB, installed automatically at first start |
| `.env.example` | Names of the admin variables. The real `.env` is excluded from Git |
| `tests/run-tests.sh` | Sets the policies with `occ`, turns on encryption, creates two users and one file, then runs the tests |

## Design decisions

| Decision | Reason | Limit accepted for the lab |
|---|---|---|
| Policies set by the test script with `occ` | The settings are part of what is tested and are documented as code | In a real setup they are set once; the test does not check who can change them |
| Server-side encryption with the default master key | Protects files if the disk or a backup copy is taken | The key is on the same server: it does not protect against someone with full access to the running server |
| Expiry of 7 days for links | Customer exports should not stay reachable | Users can still send files by other channels; the acceptable use policy (5.10) covers this |
| Local accounts | SSO through Keycloak needs both tools running together | MFA is not tested here |

## Test plan

| Test | Control | What the script does | Expected result |
|---|---|---|---|
| NC-01 | 5.17 | Admin creates a user with the password `Lagune2026` (10 characters) | User not created |
| NC-02 | 5.14 | `user1` creates a public link to a file without a password | Refused; no share exists on the file |
| NC-03 | 5.14 | `user1` creates a public link with a password | Created, with an expiry date no later than 7 days from today |
| NC-04 | 8.24 | Reads the stored file directly from the server's disk, then downloads it as `user1` | On disk: starts with `HBEGIN`, no plaintext. Download: plaintext (positive control) |
| NC-05 | 8.3 | `user2` tries to download `user1`'s file | Refused; no content returned |

## Reading a result

Each run writes `test-report.md`, shown on the run summary page and kept as the artifact `nextcloud-test-report`. A failed test is a finding: it is recorded with its cause, not hidden by changing the test.
