# Engineering Rules Pack — Production-Ready AI Standards

**Versi:** 2.0  
**Bahasa:** Indonesia  
**Tujuan:** Katalog lengkap 15 aturan rekayasa perangkat lunak (*Engineering Rules*) berstandar industri untuk memandu AI Agent (Cursor, Claude Code, Windsurf, Copilot, Antigravity, dll.) maupun software engineer dalam merancang, mengimplementasikan, mereview, menguji, dan merilis sistem siap produksi.

---

## 1. Cara Menggunakan

1. **Modular & Terarah:** Jangan menyalin seluruh file sekaligus jika tugas Anda kecil. Muat atau sertakan aturan spesifik yang relevan dengan tugas yang sedang dikerjakan.
2. **Kombinasi Rekomendasi:**
   - **Frontend UI/UX:** Aturan `01` + `04` + `06`
   - **Backend API & Data:** Aturan `02` + `03` + `04` + `05`
   - **Full-Stack Feature:** Aturan `01` + `02` + `03` + `04` + `05` + `06`
   - **Refactoring & Code Review:** Aturan `06` + `07` + `12`
   - **DevOps, Infra & CI/CD:** Aturan `08` + `09` + `12`
   - **Optimization & Scale:** Aturan `03` + `10` + `09`
   - **AI Agentic Systems & LLM:** Aturan `12` + `13` + `05`
   - **System Architecture & Major Decision:** Aturan `07` + `14` + `11`
   - **Data Engineering & Pipelines:** Aturan `03` + `15` + `09`
3. **Hierarki Penegakan:**
   - **WAJIB:** Default *non-negotiable*. Pengecualian hanya sah jika ada persetujuan eksplisit dari lead engineer/owner dan risiko terdokumentasi.
   - **KONDISIONAL:** Berlaku ketika fitur, teknologi, ancaman, atau konteks terkait digunakan dalam proyek.
   - **REKOMENDASI:** Praktik terbaik yang disesuaikan dengan skala dan biaya proyek.
   - **JANGAN:** Tindakan antipola terlarang yang membahayakan keamanan, integritas data, atau stabilitas sistem.

---

## 2. Katalog 15 Engineering Rules

| Kode | Nama Dokumen | Fokus Utama | Kapan Digunakan |
|---|---|---|---|
| **01** | [`01-frontend-engineering-rules.md`](./01-frontend-engineering-rules.md) | Component architecture, responsive design, state management, a11y (WCAG 2.2 AA), Core Web Vitals | Perancangan, implementasi, styling, dan optimasi UI/UX web |
| **02** | [`02-backend-engineering-rules.md`](./02-backend-engineering-rules.md) | Clean architecture, RESTful API contract, auth, modular monolith, transactional boundary | Pembangunan endpoint API, logika bisnis, integrasi service |
| **03** | [`03-database-engineering-rules.md`](./03-database-engineering-rules.md) | Relational schema (3NF), indexing, data integrity, InnoDB/MySQL 8+, concurrency, migrations | Desain skema tabel, optimasi query SQL, migrasi database |
| **04** | [`04-testing-qa-rules.md`](./04-testing-qa-rules.md) | AAA pattern, test isolation, strict assertions, mocks, test fixtures, unit/integration/E2E | Penulisan automated tests, QA audit, dan verifikasi CI |
| **05** | [`05-security-engineering-rules.md`](./05-security-engineering-rules.md) | Threat modeling (STRIDE), OWASP Top 10, ASVS, zero-trust, input sanitization, secret management | Semua perubahan yang menyentuh input data, auth, dan attack surface |
| **06** | [`06-code-quality-review-rules.md`](./06-code-quality-review-rules.md) | SOLID, KISS, DRY, YAGNI, naming conventions, error handling, refactoring hygiene | Implementasi fitur baru, pembersihan kode, dan PR code review |
| **07** | [`07-system-architecture-design-rules.md`](./07-system-architecture-design-rules.md) | System boundaries, loose coupling, C4 model, ADR (Architecture Decision Records) | Fitur lintas modul, integrasi microservices/third-party, arsitektur baru |
| **08** | [`08-devops-ci-cd-deployment-rules.md`](./08-devops-ci-cd-deployment-rules.md) | CI/CD pipeline, environment parity, 12-Factor App, blue-green/canary, zero-downtime | Konfigurasi pipeline build, dockerization, deploy, dan rilis |
| **09** | [`09-reliability-observability-incident-rules.md`](./09-reliability-observability-incident-rules.md) | OpenTelemetry, SLO/SLA, structured logging, distributed tracing, incident runbooks | Produksi, sistem kritis, alerting, pemulihan insiden |
| **10** | [`10-performance-scalability-rules.md`](./10-performance-scalability-rules.md) | Performance budgets, profiling, caching strategies, horizontal scaling, query tuning | Latency spikes, throughput bottlenecks, high traffic readiness |
| **11** | [`11-documentation-api-contract-rules.md`](./11-documentation-api-contract-rules.md) | OpenAPI/Swagger specs, versioning strategy, README standards, operational runbooks | Publikasi API, dokumentasi arsitektur, developer onboarding |
| **12** | [`12-git-ai-change-management-rules.md`](./12-git-ai-change-management-rules.md) | Conventional Commits, atomic diffs, truthful verification reporting, safe AI agent operations | Semua aktivitas AI coding assistant yang memodifikasi repository |
| **13** | [`13-ai-agent-prompt-engineering-rules.md`](./13-ai-agent-prompt-engineering-rules.md) | Structured outputs (Zod/JSON Schema), anti-hallucination, prompt injection defense, token budgeting | Perancangan prompt, autonomous agents, tool/function calling, LLM apps |
| **14** | [`14-architecture-decision-records-adr.md`](./14-architecture-decision-records-adr.md) | Standar dokumen ADR/RFC formal, status lifecycle, decision drivers, trade-off matrix | Keputusan arsitektur besar, pemilihan teknologi inti, migrasi struktural |
| **15** | [`15-data-engineering-pipeline-governance-rules.md`](./15-data-engineering-pipeline-governance-rules.md) | Medallion architecture, idempotency, data quality assertions, schema evolution, PII governance | Pembangunan pipeline ETL/ELT, data warehouse/lakehouse, audit kepatuhan |

---

## 3. Matriks Rekomendasi Urutan Adopsi

Untuk tim atau repository baru yang ingin mengadopsi standar secara bertahap:
1. **Fondasi Dasar (Wajib Pertama Kali):**
   - `05-security-engineering-rules.md` (Keamanan & pencegahan celah)
   - `06-code-quality-review-rules.md` (Kualitas & keterbacaan kode)
   - `12-git-ai-change-management-rules.md` (Disiplin perubahan Git & AI)
2. **Lapisan Aplikasi & Bisnis:**
   - `01-frontend-engineering-rules.md` (UI/UX & Accessibility)
   - `02-backend-engineering-rules.md` (Logika Bisnis & API)
   - `03-database-engineering-rules.md` (Integritas Data & Persistence)
   - `04-testing-qa-rules.md` (Automated Testing & Verifikasi)
3. **Skala & Operasional Produksi:**
   - `07-system-architecture-design-rules.md` (Arsitektur & ADR)
   - `08-devops-ci-cd-deployment-rules.md` (CI/CD & Otomasi Rilis)
   - `09-reliability-observability-incident-rules.md` (Telemetry & SRE)
   - `10-performance-scalability-rules.md` (Skalabilitas & Optimasi)
   - `11-documentation-api-contract-rules.md` (API Spec & Runbook)

---

## 4. Referensi Standar Internasional

Aturan-aturan dalam paket ini diselaraskan dengan standar industri global:
- **Security:** [OWASP ASVS](https://asvs.owasp.org/) & [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- **Software Quality:** [NIST SSDF](https://csrc.nist.gov/Projects/ssdf) & [Clean Architecture](https://blog.cleancoder.com/)
- **Architecture & Decisions:** [C4 Model](https://c4model.com/) & [ADR (Architecture Decision Records)](https://adr.github.io/)
- **Observability:** [OpenTelemetry Standards](https://opentelemetry.io/docs/) & [Google SRE Framework](https://sre.google/sre-book/)
- **API Standards:** [OpenAPI Specification v3+](https://spec.openapis.org/oas/latest.html) & [REST API Guidelines](https://restfulapi.net/)
- **Frontend Performance:** [Web Vitals (Google Chrome Team)](https://web.dev/articles/vitals)
- **Accessibility:** [W3C WCAG 2.2 Level AA](https://www.w3.org/WAI/standards-guidelines/wcag/)
