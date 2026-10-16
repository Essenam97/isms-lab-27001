# ISMS lab: ISO/IEC 27001:2022 on a fictional company

This repository is a self-directed training project. It builds a complete information security management system (ISMS) for a fictional company, Lagune Payroll SARL, following ISO/IEC 27001:2022 and its Amendment 1 (2024).

The company does not exist. All names, figures and incidents are invented. The technical part is designed for a lab of open-source software that I host myself, so every control can be tested without touching third-party systems.

## Why this project

I hold the ISO/IEC 27001 Foundation certificate. This project applies what the Foundation course covers to a full ISMS cycle: context, risk assessment, Statement of Applicability, policies, technical controls, internal audit and management review.

## Fictional company in one paragraph

Lagune Payroll SARL is a 42-person software company in Lomé, Togo. It sells a web payroll and HR application to Togolese small and medium businesses. The application stores employee identity data, salaries and bank account numbers. See [docs/00-company-profile.md](docs/00-company-profile.md).

## Repository structure

```
docs/
  00-company-profile.md
  clause-04-context/      4.1 issues, 4.2 interested parties, 4.3 scope
  clause-05-leadership/   leadership, information security policy, roles
  clause-06-planning/     risk method, risk register, SoA, risk treatment plan (objectives planned)
  clause-07-support/      (planned) competence, awareness, documented information
  clause-08-operation/    (planned) records of risk assessments and treatment results (8.1 to 8.3)
  clause-09-evaluation/   (planned) internal audit, management review
  clause-10-improvement/  (planned) nonconformities, corrective actions
  policies/               (planned) topic-specific policies
lab/                      lab design files (Keycloak done; not deployed)
evidence/                 (planned) screenshots and exports proving controls work
```

## Lab: design, not deployed

The lab machine has 1.6 GiB of RAM, which is not enough to run the four tools below. The lab is therefore written as design files (Docker Compose, configuration exports, test plans) that can be run later on a larger machine. No test result in this repository comes from a running system unless it has a date and a screenshot in `evidence/`.

| Component | Role in the fictional company | Related Annex A controls | Status |
|---|---|---|---|
| Keycloak | Single sign-on and MFA for all internal tools | 5.16, 5.17, 5.18, 8.5, 8.15 | Design written: [lab/keycloak](lab/keycloak/README.md) |
| Nextcloud | Internal file sharing | 5.12, 5.14, 8.24 | Planned |
| Gitea | Source code hosting | 8.4, 8.25, 8.28 | Planned |
| Wazuh | Log collection and security monitoring | 8.15, 8.16 | Planned |

## Roadmap

- [x] Clause 4: context, interested parties, scope
- [x] Clause 6.1.2: risk assessment method and risk register
- [x] Statement of Applicability (93 controls)
- [x] Clause 6.1.3: risk treatment plan and residual risk acceptance
- [x] Clause 5: leadership, information security policy, roles
- [ ] Topic-specific policies
- [ ] Lab design files (Keycloak done; Nextcloud, Gitea, Wazuh to do)
- [ ] Lab deployment and technical evidence (needs a machine with more RAM)
- [ ] Clause 9: internal audit report and management review minutes
- [ ] Clause 10: nonconformity and corrective action log

## Copyright note

ISO/IEC 27001 and ISO/IEC 27002 are copyrighted by ISO and IEC. This repository references clause and control numbers and paraphrases their intent. It does not reproduce the text of the standards.
