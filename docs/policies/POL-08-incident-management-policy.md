# POL-08 Incident management policy

| Item | Value |
|---|---|
| Owner | Head of Infrastructure |
| Approver | CEO |
| Classification | Internal |
| Version | 1.0 |
| Applies to | All staff, interns and contractors; all information and systems in the ISMS scope |
| SoA controls | 5.5, 5.24, 5.25, 5.26, 5.27, 5.28, 6.8 |
| Risks | R01, R07, and any risk that occurs |
| Actions in the risk treatment plan | A12 |

## 1. Purpose

This policy sets how security events are reported, assessed and handled, and how the company learns from them.

## 2. Reporting

1. Anyone who sees a possible security event reports it at once to the security reporting channel (email alias and chat channel), even when unsure.
2. Examples: a suspicious email, a lost laptop or phone, a Confidential file sent to the wrong person, an alert from the monitoring tool, a customer reporting a bank detail they did not change.
3. Reporting a mistake you made yourself is not punished. Hiding one is.

## 3. Assessment

The ISMS manager, or the on-duty infrastructure engineer, assesses each report within 4 working hours, and within 1 hour during the payroll window, and classifies it:

| Severity | Meaning | Example |
|---|---|---|
| Low | Event with no effect on Confidential information or on the service | Phishing email reported, not clicked |
| Medium | Limited effect, contained | One staff account used by an attacker, no customer data reached |
| High | Customer data exposed or altered, or Lagune Pay unavailable inside the payroll window | Bank details changed by an attacker; database copy leaked |

An event that does not affect information security is closed and recorded.

## 4. Response

1. Medium and High incidents are handled by an incident lead named by the ISMS manager. High incidents are reported to the CEO at once.
2. The response follows the playbooks of action A12, in particular for account takeover and for bank detail fraud.
3. Evidence (logs, emails, disk copies) is kept unchanged, with a record of who collected it and when, so that it can be used in legal proceedings under Law No. 2018-026 if needed.

## 5. Notification

| Who | When |
|---|---|
| Affected customers | High incidents affecting their data: within 24 hours of confirmation, as set in customer contracts |
| IPDCP (data protection authority) | Incidents affecting personal data: within the time and in the form set by the law, as recorded in the register of legal requirements (action A16) |
| Police cybercrime unit | When a crime is suspected and the CEO decides to file a complaint |

Contacts are kept in the authority contact list (action A16).

## 6. Learning

1. Every Medium and High incident gets a written review within 10 working days: what happened, why, what worked, what to change.
2. Changes are tracked as corrective actions (clause 10.2), and the risk register is updated if the incident shows a new or larger risk.
3. A summary of incidents is presented at each management review.

## Exceptions

An exception to this policy must be written, justified, limited in time, approved by the CEO and recorded in the exception register kept by the ISMS manager.

## Review of this policy

At least once a year, and after any incident or change that shows it no longer fits.

| Version | Date | Author | Change |
|---|---|---|---|
| 0.1 | 2026-10 | ISMS manager | First draft, written ahead of the dates in the risk treatment plan |
| 1.0 | 2026-10-16 | CEO | Approved at the ISMS kick-off meeting |

Status: approved, version 1.0, at the ISMS kick-off meeting on 2026-10-16. See the [approval register](../clause-07-support/7.5-documented-information.md).
