# Gitea: source code protection for Lagune Payroll (action A10)

Status: tests automated, not yet run. The tests run on a GitHub-hosted runner through the workflow [gitea-controls.yml](../../.github/workflows/gitea-controls.yml). A test counts as run only when its report, with date and run link, is stored in `evidence/A10/`.

## What this covers

| Risk | SoA controls | Design choice |
|---|---|---|
| R09 (vulnerable change reaches production) | 8.25, 8.28, 8.32 | Branch `main` is protected: no direct push, one approval required, stale approvals dismissed when new commits arrive, merge blocked if a reviewer rejects |
| R09, R02 | 5.3 | The author of a change cannot approve it; a second developer must |
| R03 (support staff over-access) | 8.4 | Repositories are private; only the `development` team has access; the `support` team has none |

## Files

| File | Content |
|---|---|
| `docker-compose.yml` | One Gitea container with SQLite, no SSH, memory limited to 512 MB. Registration disabled, sign-in required to view anything, new repositories private by default, passwords of 12 characters minimum with lower case, upper case and a digit |
| `tests/run-tests.sh` | Creates users, the `lagune` organization, the two teams, the private `lagune-pay` repository and the branch protection rule, then runs the tests |

## Design decisions

| Decision | Reason | Limit accepted for the lab |
|---|---|---|
| Protection rule created by the test script | The rule is part of what is tested; creating it in the script documents it as code | In a real setup the rule is created once and changes to it must be reviewed; the test does not check who can change it |
| Login to Gitea with local accounts | Keycloak SSO for Gitea needs both tools running together; done later | MFA from Keycloak (A04) is not tested here |
| One approval required | 14 developers; two would slow 3 releases a week (INT-04) | One reviewer can miss a flaw; automated security tests (8.29) are the second line, still planned |

## Test plan

| Test | Control | What the script does | Expected result |
|---|---|---|---|
| GT-01 | 8.4 | `support1` asks for the repository | HTTP 404: the repository is invisible |
| GT-02 | 8.4 | `dev1` asks for the repository | HTTP 200 (positive control: shows GT-01 is not a broken setup) |
| GT-03 | 8.28, 8.32 | `dev1` commits on `main` and runs `git push` | Push refused by the protection rule |
| GT-04 | 8.25, 8.28 | `dev1` opens a pull request and tries to merge it at once | Merge refused; pull request still not merged |
| GT-05 | 5.3 | `dev1` tries to approve their own pull request | HTTP 422: refused |
| GT-06 | 8.25, 5.3 | `dev2` approves, then `dev1` merges | Approval HTTP 200, merge HTTP 200, pull request merged (positive control) |

## Reading a result

Each run writes `test-report.md`, shown on the run summary page and kept as the artifact `gitea-test-report`. A failed test is a finding: it is recorded with its cause, not hidden by changing the test.
