# Evidence register: A07 and A13 (Nextcloud)

Every workflow run of [Nextcloud control tests (A07, A13)](../../.github/workflows/nextcloud-controls.yml) that was reviewed is listed here. This register is kept in `evidence/`, outside the folders watched by the workflow, so updating it does not start a new run.

| Run | Date (UTC) | Commit | Result | Used as evidence | Note |
|---|---|---|---|---|---|
| 1 | 2026-10-16 04:48:05 | d862577 | 5 PASS | Yes, except NC-01: [evidence file](2026-10-16-nextcloud-run-1.md) | NC-01 did not show why the user was refused; test changed |

Runs not listed (later pushes and the Monday schedule) are visible in the Actions tab. A failed scheduled run must be added here with its cause.
