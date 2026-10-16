# POL-05 Remote working and personal devices policy

| Item | Value |
|---|---|
| Owner | Head of Infrastructure |
| Approver | CEO |
| Classification | Internal |
| Version | 1.0 |
| Applies to | All staff who work outside the Lomé office or use a personal phone for email or MFA |
| SoA controls | 6.7, 7.9, 8.1 |
| Risks | R08, R11 |
| Actions in the risk treatment plan | A13 |

## 1. Purpose

Staff work from home and use personal phones for email and multi-factor authentication. This policy sets the conditions for doing so.

## 2. Remote working

1. Remote work is done on a company laptop. Personal computers are not used for company work.
2. On a home or public network, all company tools are reached through their HTTPS addresses only. Public computers (cybercafés, hotel business centres) are never used.
3. Confidential information is not shown on screen where others can read it (public transport, cafés).
4. Support staff who work remotely during an outage follow the fallback procedure of action A15.

## 3. Company laptops

| Requirement | Rule |
|---|---|
| Disk encryption | Full-disk encryption on all laptops |
| Screen lock | After 5 minutes without activity |
| Updates | Security updates installed within 14 days of release |
| Malware protection | Active on all laptops, Windows and Ubuntu |
| Remote wipe | Possible for all laptops; used when a laptop is reported lost or stolen |

## 4. Personal phones

A personal phone may be used for company email and for the MFA authenticator app if it meets these conditions:

1. screen lock with a PIN of at least 6 digits, a password or biometrics;
2. operating system still receiving security updates from its maker;
3. no jailbreak or root;
4. email account set up so that the company can sign it out remotely.

Customer data is never downloaded or stored on a personal phone.

## 5. Loss or theft

Loss or theft of a laptop or of a phone used for company email or MFA is reported at once (POL-08). The infrastructure team signs out the device, wipes the laptop, and resets the MFA of the account after checking the person's identity.

## 6. Privacy

The company does not read personal content on personal phones. Remote sign-out removes company email only.

## Exceptions

An exception to this policy must be written, justified, limited in time, approved by the CEO and recorded in the exception register kept by the ISMS manager.

## Review of this policy

At least once a year, and after any incident or change that shows it no longer fits.

| Version | Date | Author | Change |
|---|---|---|---|
| 0.1 | 2026-10 | ISMS manager | First draft, written ahead of the dates in the risk treatment plan |
| 1.0 | 2026-10-16 | CEO | Approved at the ISMS kick-off meeting |

Status: approved, version 1.0, at the ISMS kick-off meeting on 2026-10-16. See the [approval register](../clause-07-support/7.5-documented-information.md).
