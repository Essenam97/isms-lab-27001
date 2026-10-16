# Wazuh: log collection and monitoring for Lagune Payroll (action A11)

Status: feasibility trial, no control test yet.

Wazuh is made of three services: an indexer (search engine for the logs), a manager (receives and analyses events) and a dashboard. The indexer needs much more memory than the other lab tools. Before writing control tests, the workflow [wazuh-trial.yml](../../.github/workflows/wazuh-trial.yml) checks whether the official single-node stack starts on a GitHub-hosted runner, how long it takes and how much memory it uses.

| File | Content |
|---|---|
| `trial.sh` | Downloads the official `wazuh-docker` files at tag `v4.12.0`, generates the certificates, starts the stack, waits up to 15 minutes for each component and writes `trial-report.md` |

## Decision after the trial

| Trial result | Next step |
|---|---|
| All components start, with time and memory to spare | Write control tests for A11 (for example: repeated failed logins raise an alert; a log source that stops sending is detected) |
| Wazuh does not start, or leaves too little memory to run another tool beside it | Record the result and choose a lighter tool for logs; the choice and its limits are documented here |

The trial report is not control evidence. It is kept in [evidence/A11](../../evidence/A11/README.md) as the record of the tool choice.
