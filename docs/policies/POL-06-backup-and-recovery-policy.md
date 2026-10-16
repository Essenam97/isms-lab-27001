# POL-06 Backup and recovery policy

| Item | Value |
|---|---|
| Owner | Head of Infrastructure |
| Approver | CEO |
| Classification | Internal |
| Version | 0.1 (draft) |
| Applies to | Lagune Pay production, internal tools and their data |
| SoA controls | 5.29, 5.30, 8.13, 8.14 |
| Risks | R04, R05 |
| Actions in the risk treatment plan | A08 |

## 1. Purpose

Customers pay their staff through Lagune Pay. This policy sets how data is backed up and how fast the service must come back after a loss, in particular during the payroll window (25th of each month to the 5th of the next).

## 2. Recovery targets

| System | Maximum data loss (RPO) | Maximum time to restore (RTO) |
|---|---|---|
| Lagune Pay database, inside the payroll window | 4 hours | 4 hours |
| Lagune Pay database, outside the payroll window | 24 hours | 24 hours |
| Internal tools (Keycloak, Nextcloud, Gitea, monitoring) | 24 hours | 2 working days |

## 3. Backups

1. The Lagune Pay database is backed up every day, and every 4 hours during the payroll window.
2. Each backup is encrypted before it leaves the server.
3. A copy of each backup is kept at a second provider, separate from the production provider, in an account the production administrators cannot delete from.
4. Retention: daily backups for 30 days, one backup per month for 12 months, unless the register of legal requirements sets another period (action A16).
5. A failed backup raises an alert to the infrastructure team the same day.

## 4. Restore tests

1. A full restore of the Lagune Pay database from the second provider is tested every quarter, in a separate environment.
2. The test measures the time taken and checks the restored data against the source (row counts and a sample of records).
3. The result is written in a test report with date, backup used, time taken and any problem found. A test that misses the RTO is recorded as a nonconformity.

## 5. Recovery from loss of the production provider

The recovery plan to the second provider (action A08) is kept current and tested once a year. It names who decides to start it and who does each step.

## 6. Responsibilities

The infrastructure team runs backups and restore tests. The Head of Infrastructure reviews each restore test report and reports the results to the management review.

## Exceptions

An exception to this policy must be written, justified, limited in time, approved by the CEO and recorded in the exception register kept by the ISMS manager.

## Review of this policy

At least once a year, and after any incident or change that shows it no longer fits.

| Version | Date | Author | Change |
|---|---|---|---|
| 0.1 | 2026-10 | ISMS manager | First draft, written ahead of the dates in the risk treatment plan |

Status: draft, to be approved by the CEO.
