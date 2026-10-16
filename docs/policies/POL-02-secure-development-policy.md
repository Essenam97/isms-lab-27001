# POL-02 Secure development policy

| Item | Value |
|---|---|
| Owner | Head of Development |
| Approver | CEO |
| Classification | Internal |
| Version | 0.1 (draft) |
| Applies to | Everyone who writes, reviews or deploys code for Lagune Pay and its supporting tools |
| SoA controls | 5.3, 5.8, 8.4, 8.8, 8.25, 8.26, 8.28, 8.29, 8.31, 8.32, 8.33 |
| Risks | R02, R09 |
| Actions in the risk treatment plan | A06, A10 |

## 1. Purpose

Lagune Pay changes about 3 times a week. This policy sets the rules that keep each change from weakening the security of customer payroll data, without stopping that pace.

## 2. Security requirements

1. Every user story that touches payroll data, bank details, identity data or authentication includes its security requirements before development starts. Example: a change of bank details is applied after 48 hours and notified to the employee (action A03).
2. New projects use the security checklist in the project template (control 5.8).

## 3. Source code

1. Source code is stored only in the company's Gitea, in private repositories.
2. Only the development team has access (POL-01).
3. Secrets (passwords, keys, tokens) are never committed. They are kept in environment files excluded from version control, or in the deployment system.

## 4. Review before merge

| Rule | Requirement |
|---|---|
| Protected main branch | No one pushes directly to `main` |
| Pull request | Every change reaches `main` through a pull request |
| Approval | At least 1 approval from another developer with write access. The author cannot approve their own change |
| New commits | Approvals given before new commits are cancelled |
| Rejection | A pull request with a rejecting review cannot be merged |

## 5. Automated checks

1. Before merge, the pipeline runs automated security tests on the code and scans third-party libraries for known vulnerabilities.
2. A pull request with a failed security check is not merged unless the Head of Development accepts the risk in writing on the pull request.
3. Known vulnerabilities in libraries used in production are fixed within 7 days when critical and 30 days when high, counted from their publication.

## 6. Environments and test data

1. Development, test and production are separate environments.
2. Test environments use fake data only. Copying production data into test is forbidden.

## 7. Release and change

1. Only the deployment pipeline installs code in production. The merged pull request, with its approval, is the change record.
2. An emergency change may be deployed with the approval of the Head of Development alone. It must be reviewed by a second developer within 1 working day, and the review recorded on the change.

## 8. Training

Developers attend a secure coding session at least once a year.

## 9. Exceptions

As in POL-01, section 9.

## 10. Review of this policy

At least once a year, and after a security incident caused by a change.

| Version | Date | Author | Change |
|---|---|---|---|
| 0.1 | 2026-10 | ISMS manager | First draft, written ahead of the dates in the risk treatment plan |

Status: draft, to be approved by the CEO.
