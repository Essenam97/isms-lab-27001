# POL-01 Access control policy

| Item | Value |
|---|---|
| Owner | Head of Infrastructure |
| Approver | CEO |
| Classification | Internal |
| Version | 0.1 (draft) |
| Applies to | All staff, interns and contractors; all systems in the ISMS scope |
| SoA controls | 5.15, 5.16, 5.17, 5.18, 6.5, 8.2, 8.3, 8.5, 8.15 |
| Risks | R02, R03, R07, R12 |
| Actions in the risk treatment plan | A04, A05, A06, A07 |

## 1. Purpose

This policy sets who may access Lagune Payroll's information and systems, how they prove who they are, and how access is given, reviewed and removed.

## 2. Principles

1. Access is given on a need-to-know basis and with the least privilege needed for the task.
2. Each person has one personal identity, managed in Keycloak. Shared accounts are not allowed, except the break-glass account described in section 6.
3. Access rights belong to a role or team, not to a person: a person gets access by joining the team that needs it.

## 3. Authentication

| Rule | Requirement |
|---|---|
| Single sign-on | All internal tools (Nextcloud, Gitea, monitoring) are accessed through Keycloak. A tool that cannot use Keycloak needs an exception (section 9) |
| Password | At least 12 characters, with at least one upper-case letter and one digit; must not contain the user name or email address; must differ from the last 5 passwords |
| Multi-factor authentication | Required for every staff account, set up at first login with an authenticator app. It cannot be removed from an account except through an approved exception |
| Customer administrator accounts in Lagune Pay | Multi-factor authentication required (action A03) |
| Failed logins | After 5 failed attempts the account is locked for a delay that grows with each new failure, up to 15 minutes |
| Sessions | Closed after 30 minutes without activity and after 10 hours in any case |

Passwords and MFA codes must never be shared, written down in plain text or sent by email or chat.

## 4. Giving access

1. The manager asks for access through the IT request channel, stating the team or role.
2. The Head of Infrastructure, or a person she names, creates the account or adds it to the team.
3. Access to production systems or to customer data needs the approval of the risk owner of that area (see the risk method, section 6).

## 5. Changing and removing access

1. When a person changes team, the new manager asks for the new access and the old manager asks for the removal of the old access on the same day.
2. When a person leaves, HR starts the offboarding checklist (action A05). The Keycloak account is disabled no later than the end of the last working day, which removes access to all tools connected to Keycloak at once.
3. Accounts of contractors are created with an end date.

## 6. Privileged access

1. Administrator rights on production systems are limited to the infrastructure team, with named accounts.
2. Developers have no access to the production database. Production data needed to investigate a problem is obtained through the break-glass procedure.
3. The break-glass account is used only with the written approval of the Head of Infrastructure or the CEO, for a limited time. Each use is logged and reviewed within 2 working days.

## 7. Access to specific information

| Information | Who has access |
|---|---|
| Source code | Development team only (POL-02) |
| Customer payroll data in Lagune Pay, for support | The support agent handling an open ticket, for that customer only, with bank and ID numbers masked |
| Confidential documents in Nextcloud | People named by the owner of the folder (POL-03) |

## 8. Review and monitoring

1. Login events and administrator events in Keycloak are kept for 90 days.
2. Failed logins raise alerts in the monitoring tool; 5 failed logins within 2 minutes raise a high-level alert.
3. Every quarter, each risk owner reviews the access rights in their area. The review checks at least: people who left or changed team, accounts with administrator rights, and accounts on which multi-factor authentication is not active or was removed (using the Keycloak administrator events). The result is recorded and kept for one year.

## 9. Exceptions

An exception to this policy must be written, justified, limited in time, approved by the CEO and recorded in the exception register kept by the ISMS manager.

## 10. Review of this policy

At least once a year, and after any major change to the identity system.

| Version | Date | Author | Change |
|---|---|---|---|
| 0.1 | 2026-10 | ISMS manager | First draft, written ahead of the dates in the risk treatment plan |

Status: draft, to be approved by the CEO.
