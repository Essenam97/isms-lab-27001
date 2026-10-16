# Company profile: Lagune Payroll SARL (fictional)

| Item | Value |
|---|---|
| Legal form | SARL (limited liability company) under Togolese law |
| Location | One office in Lomé, Togo |
| Staff | 42 (see breakdown below) |
| Founded | 2019 |
| Product | "Lagune Pay", a web application for payroll and HR management |
| Customers | About 180 Togolese SMEs, 3 to 250 employees each |
| Annual revenue | 410 million XOF |

## Staff breakdown

| Team | Headcount |
|---|---|
| Management | 3 |
| Software development | 14 |
| Infrastructure and operations | 4 |
| Customer support | 9 |
| Sales and marketing | 6 |
| Finance and administration | 4 |
| HR | 2 |

There is no full-time security person. The Head of Infrastructure has been named ISMS manager and spends about 40% of her time on it.

## Information handled

Lagune Pay stores, for each employee of each customer: full name, date of birth, national ID or passport number, address, phone number, job title, salary, bank account number (IBAN or mobile money number), social security number, and payslips.

That is personal data under Togolese Law No. 2019-014 of 29 October 2019 on the protection of personal data. Some customers also record sick leave, which is health data.

## IT environment

- Production: Lagune Pay runs on rented virtual servers at a cloud provider whose data centre is outside Togo (fictional provider "NimbusHost", data centre in Europe).
- Internal tools: Keycloak (SSO), Nextcloud (files), Gitea (source code), Wazuh (monitoring). In this project they run in my lab.
- Workstations: 38 laptops (Windows and Ubuntu), plus personal phones used for email and MFA.
- Office network: one fibre link, one 4G backup router, Wi-Fi for staff and a separate guest Wi-Fi.

## Why the company wants ISO/IEC 27001

Two of its five largest customers (a bank subsidiary and a telecom distributor) asked in 2026 tender documents for proof of an information security management system. Management set a target of certification within 12 months.
