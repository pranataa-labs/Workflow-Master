# AI Assistant Configuration Templates

Folder ini menyediakan file konfigurasi siap pakai (*drop-in templates*) untuk berbagai editor dan platform AI coding assistant populer, agar AI langsung mematuhi standar rekayasa perangkat lunak dalam repository ini.

---

## 1. Daftar Template yang Tersedia

| File | Target Tool / IDE | Lokasi Penempatan di Proyek Anda |
|---|---|---|
| [`.cursorrules`](./.cursorrules) | **Cursor IDE** | Letakkan di root direktori proyek: `./.cursorrules` |
| [`claude-code-prompt.md`](./claude-code-prompt.md) | **Claude Code / Anthropic API** | Salin isinya ke `CLAUDE.md` atau jadikan system prompt |
| [`windsurf-rules.md`](./windsurf-rules.md) | **Windsurf (Codeium)** | Letakkan di `./.windsurfrules` atau global rules |
| [`copilot-instructions.md`](./copilot-instructions.md) | **GitHub Copilot** | Letakkan di `./.github/copilot-instructions.md` |

---

## 2. Cara Mengaktifkan di Proyek Baru

1. Salin template yang relevan ke dalam repository proyek target Anda.
2. Pastikan file referensi (folder `rules/` atau `bundles/`) dapat diakses atau di-clone sebagai sub-module / submodule git, atau salin folder `rules/` ke dalam proyek Anda.
3. Jalankan AI coding assistant; AI akan secara otomatis mematuhi alur kerja 9 tahap dan standar penulisan kode siap produksi.
