# Evidence register: A04 (Keycloak)

Every workflow run of [Keycloak control tests (A04)](../../.github/workflows/keycloak-controls.yml) that was reviewed is listed here. This register is kept in `evidence/`, outside the folders watched by the workflow, so updating it does not start a new run.

| Run | Date (UTC) | Commit | Result | Used as evidence | Note |
|---|---|---|---|---|---|
| 1 | 2026-10-16 04:09:51 | 46b8fd1 | 5 PASS, KC-02 and KC-04 verdicts invalid | No | Script defect: HTTP code lost in a subshell |
| 2 | 2026-10-16 04:18:23 | 62d0a32 | 5 PASS | Yes: [evidence file](2026-10-16-keycloak-run-2.md) | |
| 3 | 2026-10-16 04:47:54 | d862577 | 5 PASS | No (same results as run 2) | Started by the README change; numFailures again 2 |

Runs not listed (later pushes and the Monday schedule) are visible in the Actions tab. A failed scheduled run must be added here with its cause.
