# Evidence register: A07 and A13 (Nextcloud)

Every workflow run of [Nextcloud control tests (A07, A13)](../../.github/workflows/nextcloud-controls.yml) that was reviewed is listed here. This register is kept in `evidence/`, outside the folders watched by the workflow, so updating it does not start a new run.

| Run | Date (UTC) | Commit | Result | Used as evidence | Note |
|---|---|---|---|---|---|
| 1 | 2026-10-16 04:48:05 | d862577 | 5 PASS | Yes, except NC-01: [evidence file](2026-10-16-nextcloud-run-1.md) | NC-01 did not show why the user was refused; test changed |
| 2 | 2026-10-16 04:57:26 | c43b7c4 | 5 PASS | Yes, for NC-01 only | Valid password HTTP 200; short password HTTP 400 "Password needs to be at least 12 characters long."; lookup HTTP 404. Run https://github.com/Essenam97/isms-lab-27001/actions/runs/38853209656, artifact sha256:d0645fed1d2e32b5f03b4bd6d1102f57a02f499a16c821251d061a7d5bfc691f |

Runs not listed (later pushes and the Monday schedule) are visible in the Actions tab. A failed scheduled run must be added here with its cause.
