<div align="center">

# ⚡ Workflow Master: AI Engineering Operating System

**Production-Ready Software Engineering Operating System & AI Standards**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![Standard: Production Ready](https://img.shields.io/badge/Standard-Production--Ready-emerald.svg)](#)
[![AI Assistants](https://img.shields.io/badge/AI%20Compatible-Cursor%20%7C%20Claude%20%7C%20Windsurf%20%7C%20Copilot-8A2BE2.svg)](#)
[![Version](https://img.shields.io/badge/Version-2.0.0-orange.svg)](#)

*A comprehensive suite of engineering standards (Frontend, Backend, Database, QA, Security, Architecture, DevOps, SRE, Performance, Docs, Git) and structured workflows designed to maximize the capabilities of AI Coding Assistants without compromising security, data integrity, or architectural elegance.*

---

</div>

## 📌 Why Workflow Master Is Essential

Modern AI models (such as Claude 3.7 Sonnet, Gemini 2.5 Flash/Pro, and GPT-4o) generate code at unprecedented speeds. However, without rigorous architectural boundaries, AI agents frequently:
1. Introduce unnecessary abstractions and overengineering.
2. Rely on frontend assumptions and neglect robust server-side validation.
3. Write brittle, flaky automated tests or falsely claim test passage without execution.
4. Hardcode secrets, leak environment credentials, or corrupt live database schemas.

**Workflow Master** serves as an operational governance framework that elevates AI from an unpredictable code generator into a disciplined **Principal / Staff Software Engineer** strictly adhering to global industry standards.

---

## 🏗️ Repository Architecture

```text
workflow-master/
├── .gitignore
├── LICENSE
├── CONTRIBUTING.md
├── README.md                                         # Main documentation hub
│
├── workflows/                                        # Orchestration prompts & AI workflows
│   ├── README.md                                     # AI lifecycle guidelines
│   ├── 00-engineering-workflow-ai-coding.md          # 9-stage engineering lifecycle & risk matrix
│   └── 01-master-prompt-and-workflow-fullstack.md    # Full-Stack master orchestrator prompt
│
├── rules/                                            # 12 Modular Rule Packages (Production-Ready)
│   ├── README.md                                     # Catalog & rule selection guide
│   ├── 01-frontend-engineering-rules.md              # UI/UX, Component design, a11y (WCAG 2.2 AA), Core Web Vitals
│   ├── 02-backend-engineering-rules.md               # Clean architecture, RESTful API, Auth, Boundary control
│   ├── 03-database-engineering-rules.md              # MySQL 8+ / InnoDB, 3NF, Indexing, Concurrency control
│   ├── 04-testing-qa-rules.md                        # SDET methodology, AAA pattern, Strict assertions
│   ├── 05-security-engineering-rules.md              # OWASP ASVS/Top 10, Threat modeling, Route obfuscation
│   ├── 06-system-architecture-rules.md               # Monolith, Modular, Microservices, Event-driven
│   ├── 07-devops-infrastructure-rules.md             # Docker, CI/CD pipelines, Zero-downtime deployments
│   ├── 08-sre-observability-rules.md                 # Structured logging, Metrics, SLO/SLA management
│   ├── 09-performance-optimization-rules.md          # Database query tuning, Caching, Bundle sizing
│   ├── 10-documentation-standards.md                 # ADRs, API specifications (OpenAPI), Runbooks
│   ├── 11-git-version-control-rules.md               # Conventional commits, Branching hygiene, PR reviews
│   └── 12-ai-agent-collaboration-rules.md            # Multi-agent coordination & context management
│
└── templates/                                        # Ready-to-use production scaffolding
    ├── pr-template.md                                # Pull request verification template
    ├── adr-template.md                               # Architecture Decision Record template
    └── incident-report-template.md                   # Post-mortem & RCA template
```

---

## 🚀 The 9-Stage Engineering Discipline

All engineering tasks orchestrated by Workflow Master follow a strict nine-phase verification cycle:

1. **Triage:** Define task scope, categorize domain requirements, and assign risk levels (Low, Medium, High).
2. **Discover:** Perform read-only exploration of contracts, configuration files, and dependencies before modifying code.
3. **Design:** Establish explicit acceptance criteria, edge-case definitions, and rollback contingency plans.
4. **Plan:** Sequence minimal, modular, and non-breaking file modifications.
5. **Implement:** Author clean, type-safe, maintainable code adhering to project conventions.
6. **Verify:** Execute local test suites, linters, and typecheckers, reporting truth-telling verification metrics.
7. **Review:** Inspect git diffs, ensure zero secrets or sensitive keys are exposed, and enforce access authorization.
8. **Release:** Validate deployment readiness and health check verifications.
9. **Report:** Deliver transparent post-implementation summaries and test outputs to stakeholders.

---

## 🔒 Security Baseline & Admin Route Obfuscation

Workflow Master mandates enterprise security defenses across all software systems:
- **Admin Route Obfuscation:** Standard administrative routes (`/admin`) must never be statically exposed in production. Endpoints must be dynamically configured via environment variables (e.g. `ADMIN_PREFIX`), responding with **HTTP 404 Not Found** on default paths to eliminate automated reconnaissance.
- **Strict Role-Based Access Control:** Zero-trust authorization enforced at the server layer with clear flash security notifications upon permission denial.
- **Cryptographic & Input Boundaries:** Strict parameter binding, anti-CSRF token defense, and HTML sanitization on all input streams.

---

## 📄 License & Attribution

This repository is distributed under the [MIT License](./LICENSE). Designed and curated by **[pranataa-labs](https://github.com/pranataa-labs)**.
