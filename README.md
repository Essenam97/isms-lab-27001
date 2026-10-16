# ISMS lab: ISO/IEC 27001:2022 on a fictional company

This repository is a self-directed training project. It builds a complete information security management system (ISMS) for a fictional company, Lagune Payroll SARL, following ISO/IEC 27001:2022 and its Amendment 1 (2024).

The company does not exist. All names, figures and incidents are invented. The technical part runs on a lab I host myself with open-source software, so every control can be tested without touching third-party systems.

## Why this project

I hold the ISO/IEC 27001 Foundation certificate. This project applies what the Foundation course covers to a full ISMS cycle: context, risk assessment, Statement of Applicability, policies, technical controls, internal audit and management review.

## Fictional company in one paragraph

Lagune Payroll SARL is a 42-person software company in Lomé, Togo. It sells a web payroll and HR application to Togolese small and medium businesses. The application stores employee identity data, salaries and bank account numbers. See [docs/00-company-profile.md](docs/00-company-profile.md).

## Repository structure

```
docs/
  00-company-profile.md
  clause-04-context/      4.1 issues, 4.2 interested parties, 4.3 scope
  clause-05-leadership/   (planned) policy, roles
  clause-06-planning/     (planned) risk method, risk register, SoA, objectives
  clause-07-support/      (planned) competence, awareness, documented information
  clause-08-operation/    (planned) risk treatment plan
  clause-09-evaluation/   (planned) internal audit, management review
  clause-10-improvement/  (planned) nonconformities, corrective actions
  policies/               (planned) topic-specific policies
lab/                      (planned) Docker Compose files for the lab
evidence/                 (planned) screenshots and exports proving controls work
```

## Lab stack (planned)

| Component | Role in the fictional company | Related Annex A controls |
|---|---|---|
| Keycloak | Single sign-on and MFA for all internal tools | 5.15, 5.17, 5.18, 8.5 |
| Nextcloud | Internal file sharing | 5.12, 5.14, 8.24 |
| Gitea | Source code hosting | 8.4, 8.25, 8.28 |
| Wazuh | Log collection and security monitoring | 8.15, 8.16 |

## Roadmap

- [x] Clause 4: context, interested parties, scope
- [ ] Clause 6.1: risk assessment method and risk register
- [ ] Statement of Applicability (93 controls)
- [ ] Clause 5: information security policy, roles
- [ ] Topic-specific policies
- [ ] Lab deployment and technical evidence
- [ ] Clause 9: internal audit report and management review minutes
- [ ] Clause 10: nonconformity and corrective action log

## Copyright note

ISO/IEC 27001 and ISO/IEC 27002 are copyrighted by ISO and IEC. This repository references clause and control numbers and paraphrases their intent. It does not reproduce the text of the standards.
