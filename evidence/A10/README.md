# Evidence register: A10 (Gitea)

Every workflow run of [Gitea control tests (A10)](../../.github/workflows/gitea-controls.yml) that was reviewed is listed here. This register is kept in `evidence/`, outside the folders watched by the workflow, so updating it does not start a new run.

| Run | Date (UTC) | Commit | Result | Used as evidence | Note |
|---|---|---|---|---|---|
| 1 | 2026-10-16 04:31:52 | 228133a | 6 PASS | Yes: [evidence file](2026-10-16-gitea-run-1.md) | GT-04 returned HTTP 405 |
| 2 | 2026-10-16 04:37:05 | c2adc2b | 6 PASS | No (same results as run 1) | Started by the commit of the evidence file; shows the test is repeatable |
| 3 | 2026-10-16 04:47:34 | d862577 | 6 PASS | Yes, for GT-04 only | First run with GT-04 requiring HTTP 405: merge HTTP 405, merged=false. Artifact sha256:4535f0fc0b8aebd33c3c87e319259876dc6d5fb29b311be902c13c2d92c9ba1f |

Since run 3, GT-04 requires HTTP 405 exactly instead of any refusal.

Runs not listed (later pushes and the Monday schedule) are visible in the Actions tab. A failed scheduled run must be added here with its cause.
