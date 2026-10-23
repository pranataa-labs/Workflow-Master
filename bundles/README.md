# Consolidated Engineering Prompt Bundles

Direktori ini menyediakan **paket gabungan monolitik (*All-in-One Prompt Bundles*)** yang dirancang khusus untuk skenario di mana pengguna ingin menyalin satu file teks lengkap ke dalam antarmuka obrolan AI (seperti ChatGPT web, Claude web UI, Project Knowledge base, atau Custom GPT Instructions) tanpa perlu melampirkan banyak file modular satu per satu.

---

## 1. Daftar Dokumen Bundle

| File Bundle | Cakupan | Ukuran | Kapan Digunakan |
|---|---|---|---|
| [`master-engineering-fullstack-bundle.md`](./master-engineering-fullstack-bundle.md) | Frontend + Backend + Database + QA/Testing + Global Instructions | ~83 KB | Proyek Full-Stack lengkap di mana AI menangani antarmuka (FE), API (BE), skema data (DB), dan pengujian otomatis (QA). |
| [`master-engineering-backend-database-bundle.md`](./master-engineering-backend-database-bundle.md) | Backend + Database + Persistence + Integrasi Transaksi | ~37 KB | Proyek API murni, microservices, backend monolith, atau perancangan skema database relasional. |
| [`engineering-rules-pack-bundle.md`](./engineering-rules-pack-bundle.md) | Rules 05 s/d 12 (Security, Quality, Architecture, DevOps, SRE, Performance, Docs, Git) | ~57 KB | Standar tata kelola lintas lapisan untuk memperkuat pipeline, arsitektur, keamanan, dan keandalan sistem. |

---

## 2. Kapan Menggunakan Bundle vs Modular Rules?

- **Gunakan Bundles (`bundles/`):**
  - Mengisi formulir *Custom Instructions* atau *System Prompt* pada ChatGPT / Claude Web.
  - Memasukkan prompt ke dalam alat AI yang tidak memiliki fitur membaca file lokal di repository.
  - Memulai inisiasi arsitektur proyek baru secara menyeluruh dalam satu sesi diskusi awal.

- **Gunakan Modular Rules (`rules/`):**
  - Lingkungan AI IDE modern (Cursor, Windsurf, Claude Code, GitHub Copilot, Antigravity) yang dapat membaca konteks file secara otomatis.
  - Menghemat token jendela konteks (*context window efficiency*) dengan hanya menyertakan aturan yang relevan dengan tugas spesifik.
  - Mencegah kebingungan instruksi (*instruction diluting*) pada tugas-tugas terfokus (misal: hanya styling UI, hanya membuat query SQL).
