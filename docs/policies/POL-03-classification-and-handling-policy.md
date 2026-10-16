# POL-03 Information classification and handling policy

| Item | Value |
|---|---|
| Owner | ISMS manager |
| Approver | CEO |
| Classification | Internal |
| Version | 1.0 |
| Applies to | All staff, interns and contractors; all information in the ISMS scope, in any form |
| SoA controls | 5.10, 5.12, 5.13, 5.14, 7.10, 7.14, 8.10, 8.24 |
| Risks | R03, R06, R08 |
| Actions in the risk treatment plan | A07, A13, A16 |

## 1. Purpose

This policy sets how information is classified and what each class allows, so that payroll and personal data are not stored or sent where they can leak.

## 2. Classes

| Class | Meaning | Examples |
|---|---|---|
| Public | Can be given to anyone | Website content, the information security policy, published job offers |
| Internal | For staff and contractors; limited harm if disclosed | Procedures, meeting notes, internal planning |
| Confidential | Serious harm to people or to the company if disclosed or altered | Customer payroll data and exports, employee identity and bank data, credentials and keys, source code, security reports, contracts |

When in doubt, the higher class applies. Information that contains personal data is Confidential.

## 3. Classifying and labelling

1. The person who creates or receives the information classifies it.
2. Documents show their class in the footer. Nextcloud folders that hold Confidential information have "CONFIDENTIAL" at the start of their name.
3. Data in Lagune Pay is Confidential by default and is not labelled item by item.

## 4. Handling rules

| Action | Public | Internal | Confidential |
|---|---|---|---|
| Storage | Anywhere | Company tools | Lagune Pay, or Nextcloud with server-side encryption. Never on a laptop disk, a USB drive or a personal phone |
| Sharing inside the company | Free | Free | Only with people who need it (POL-01) |
| Public link in Nextcloud | Allowed | Password required, expires after at most 7 days | Password required, expires after at most 7 days; password sent by another channel than the link |
| Email | Free | Company email only | Not as an attachment. Send a Nextcloud link with a password instead |
| Personal email, messaging apps | Allowed | Not allowed | Not allowed |
| Printing | Free | Allowed | Avoid; collect at once; shred after use |
| Disposal | Normal | Delete | Delete from Nextcloud and empty the trash; equipment is wiped with a record (7.14) |

## 5. Customer data at the end of a contract

Customer data is deleted within the period set in the register of legal and contractual requirements (action A16), and the deletion is recorded (8.10).

## 6. Breaches

A Confidential file sent or stored against this policy is reported at once as a security event, as section 6 of the information security policy requires (incident procedure: action A12). Reporting a mistake you made yourself is not punished.

## 7. Review of this policy

At least once a year.

| Version | Date | Author | Change |
|---|---|---|---|
| 0.1 | 2026-10 | ISMS manager | First draft, written ahead of the dates in the risk treatment plan |
| 1.0 | 2026-10-16 | CEO | Approved at the ISMS kick-off meeting |

Status: approved, version 1.0, at the ISMS kick-off meeting on 2026-10-16. See the [approval register](../clause-07-support/7.5-documented-information.md).
