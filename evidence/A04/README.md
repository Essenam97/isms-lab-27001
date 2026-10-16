# Evidence register: A04 (Keycloak)

Every workflow run of [Keycloak control tests (A04)](../../.github/workflows/keycloak-controls.yml) that was reviewed is listed here, under its GitHub run number. This register is kept in `evidence/`, outside the folders watched by the workflow, so updating it does not start a new run.

| Run | Date (UTC) | Commit | Result | Used as evidence | Note |
|---|---|---|---|---|---|
| #1 | 2026-10-16 04:09:51 | 46b8fd1 | 5 PASS, KC-02 and KC-04 verdicts invalid | No | Script defect: HTTP code lost in a subshell |
| #2 | 2026-10-16 04:18:23 | 62d0a32 | 5 PASS | Yes: [evidence file](2026-10-16-keycloak-run-2.md) | |
| #3 | 2026-10-16 | Commit of the evidence file | Not reviewed | No | Started by the change to `lab/keycloak/README.md`; its report was not copied |
| #4 | 2026-10-16 04:47:54 | d862577 | 5 PASS | No (same results as #2) | Started by a README change; numFailures again 2 |
| #5 | 2026-10-16 06:17:08 | 561fce0 | 6 PASS, 2 FAIL | No: finding | First run with the OTP required in the realm flows. KC-02 and KC-06 got HTTP 500. Keycloak log: `AuthenticationFlowException: authenticator: direct-grant-validate-otp`, uncaught, in the direct grant flow, for users who had not set up OTP. Cause: a required OTP step in the direct grant flow cannot offer OTP setup, and Keycloak 26.0.8 answers with a server error instead of a refusal. Correction: direct grant turned off for all realm clients (`apply-mfa-flows.sh`, since run 6). The same log shows KC-03's user locked after 2 failures sent about 40 ms apart, which explains numFailures=2 in #2 and #4 (Keycloak's quick login check); KC-03 now spaces attempts by 1.5 s. Run https://github.com/Essenam97/isms-lab-27001/actions/runs/38860281743; artifact digest begins sha256:e55d5fdf83fbad9a561351b5f858bbab6f (rest not copied) |

Earlier versions of this register numbered runs #3 and #4 as "run 3"; the GitHub run numbers above are the reference.

Runs not listed (later pushes and the Monday schedule) are visible in the Actions tab. A failed scheduled run must be added here with its cause.
