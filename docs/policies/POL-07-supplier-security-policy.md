# POL-07 Supplier security policy

| Item | Value |
|---|---|
| Owner | Head of Infrastructure |
| Approver | CEO |
| Classification | Internal |
| Version | 1.0 |
| Applies to | All suppliers that host, process or can access Lagune Payroll's information, and the staff who choose and manage them |
| SoA controls | 5.19, 5.20, 5.21, 5.22, 5.23 |
| Risks | R05, R06 |
| Actions in the risk treatment plan | A09 |

## 1. Purpose

Lagune Pay runs at a cloud provider, and company email is hosted by another provider. This policy sets how such suppliers are chosen, bound by contract and followed up.

## 2. Supplier list

The ISMS manager keeps a list of suppliers with, for each: the service, the information it can reach, its security level, the contract end date and the date of the last review.

| Security level | Meaning | Example |
|---|---|---|
| High | Hosts or can access Confidential information | Production hosting provider, email provider, backup provider |
| Medium | Can access Internal information or the office network | Laptop repair supplier, internet provider |
| Low | No access to information | Office supplies |

## 3. Before signing

For a High supplier, the Head of Infrastructure checks before the contract is signed:

1. the security certifications or audit reports the supplier can show (for example ISO/IEC 27001 certificate and its scope);
2. where the data will be stored, and whether the transfer of personal data to that country is allowed under Law No. 2019-014 (action A16);
3. how the supplier reports incidents and how fast.

## 4. Contract clauses

Contracts with High suppliers include:

1. confidentiality and data protection obligations;
2. the location of data and a ban on moving it without notice;
3. notification of security incidents affecting Lagune Payroll's data, within a set time;
4. the right to receive the supplier's audit reports or certificates every year;
5. return and deletion of data at the end of the contract;
6. the shared responsibility split for cloud services: what the supplier secures and what Lagune Payroll secures.

## 5. Follow-up

1. High suppliers are reviewed once a year: certificate still valid, incidents in the year, service levels met.
2. A change of supplier, of data location or of the service is assessed for risk before it is accepted.

## 6. Open-source software

Open-source libraries and tools are part of the supply chain. Their known vulnerabilities are handled under POL-02, section 5.

## Exceptions

An exception to this policy must be written, justified, limited in time, approved by the CEO and recorded in the exception register kept by the ISMS manager.

## Review of this policy

At least once a year, and after any incident or change that shows it no longer fits.

| Version | Date | Author | Change |
|---|---|---|---|
| 0.1 | 2026-10 | ISMS manager | First draft, written ahead of the dates in the risk treatment plan |
| 1.0 | 2026-10-16 | CEO | Approved at the ISMS kick-off meeting |

Status: approved, version 1.0, at the ISMS kick-off meeting on 2026-10-16. See the [approval register](../clause-07-support/7.5-documented-information.md).
