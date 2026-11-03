---
name: shadcn-admin-design-system
description: >-
  Admin backoffice and Mode Operate workspace design system distilled from
  satnaing/shadcn-admin (OKLCH tokens, 16rem collapsible sidebar, sticky blurred header,
  TanStack faceted data tables, Ctrl+K command palette, sheet drawers, Lucide icons,
  tabular-nums). Use for admin panels, backoffice CRUD, settings, and operational
  workbenches. For customer-facing landing pages, storefronts, portfolios, or
  domain-specific palettes/typography, combine with distinctive-ui-design so projects
  never look identical.
---

# Shadcn-Admin Design System (Mode Operate & Backoffice)

Standar antarmuka operasional (*Mode Operate*) berbasis `satnaing/shadcn-admin`: permukaan netral yang tenang, garis batas tipis, tipografi padat, dan ikon Lucide berukuran `16px`.

> **Penting — Cegah Tampilan Seragam Lintas Proyek:**
> Gunakan skill ini khusus untuk **panel admin, manajemen tabel data, dan ruang kerja operasional**. Untuk halaman depan pelanggan (*landing page, storefront, katalog, portofolio*) atau pemilihan palet dan pasangan font spesifik domain (seperti `swiss-grid`, `editorial-serif`, `warm-craft`, `clinical-clean`, `industrial-ops`), **wajib** pasangkan dengan skill [`distinctive-ui-design`](../distinctive-ui-design/SKILL.md).

Resources in this skill:
- `resources/theme.css` — drop-in design tokens (light + dark) + base layer.
- `resources/patterns.md` — copy-paste markup for every page pattern (React/Tailwind and plain HTML/Blade variants).

---

## 1. Workflow

1. **Detect stack.**
   - React/Vite/Next -> install Tailwind v4 + shadcn/ui (`npx shadcn@latest init`, style `new-york`, base color `slate`, CSS variables ON), `lucide-react`, `tw-animate-css`. Then add components as needed (`button card badge input tabs table dropdown-menu avatar sidebar sheet dialog command tooltip separator skeleton sonner`).
   - Laravel Blade / plain HTML -> Tailwind v4 via Vite, copy `resources/theme.css`, use Lucide via `lucide` (`<i data-lucide="...">`) or `blade-lucide-icons`. Recreate components with the exact class strings from `patterns.md`.
2. **Select domain tokens:** Use `resources/theme.css` as the structural base, and apply the domain archetype palette and font pair from `distinctive-ui-design/references/visual-archetypes.md`.
3. **Choose the right Dashboard Composition** (Section 4.1) — do **not** default to 4 identical KPI cards on every project.
4. **Verify**: both light & dark mode, mobile (sidebar -> sheet), keyboard focus rings, and `ui-sloplint.ps1`.

---

## 2. Design Tokens

### Color (OKLCH base, adaptable per domain archetype)
| Token | Light | Dark | Usage |
|---|---|---|---|
| `background` | white / warm-paper / cool-alabaster | `oklch(0.129 0.042 264.7)` deep slate | page |
| `foreground` | slate-950 | slate-50 | text |
| `card` | white | `oklch(0.14 0.04 259.2)` (1 step lighter than bg) | cards |
| `primary` | domain primary (or slate-900) | slate-200 / domain signal | primary buttons |
| `secondary/muted/accent` | slate-100 | slate-800 | hover, tabs track, chips |
| `muted-foreground` | slate-500 | slate-400 | descriptions, icons, captions |
| `border` / `input` | slate-200 | white/10% · white/15% | all lines |
| `destructive` | red-600 | red-400 | delete, errors |
| `ring` | slate-400 | slate-500 | focus at `/50` opacity, 3px |

Rules:
- Dark-mode borders are translucent white (`/10%`), never gray hex.
- Sidebar uses the same tokens as background (`--sidebar: var(--background)`).

### Status badge palette (outline badge + tint)
```text
active    -> bg-teal-100/30 text-teal-900 dark:text-teal-200 border-teal-200
inactive  -> bg-neutral-300/40 border-neutral-300
invited   -> bg-sky-200/40 text-sky-900 dark:text-sky-100 border-sky-300
suspended -> bg-destructive/10 dark:bg-destructive/50 text-destructive dark:text-primary border-destructive/10
```

### Typography
- Pair a distinct **Display face** (`--font-display`), **Body face** (`--font-sans`), and **Monospace face** (`--font-mono`) per `distinctive-ui-design`.
- **Mandatory `tabular-nums`:** Apply `tabular-nums` to all KPI figures, currency amounts, percentages, timestamps, and numeric table cells.
- Scale (tight and scannable):
  - Page title: `text-2xl font-bold tracking-tight font-display`
  - Page subtitle: `text-muted-foreground` (base size)
  - Card title: `font-semibold leading-none` (KPI card title: `text-sm font-medium`)
  - KPI value: `text-2xl font-bold tabular-nums`
  - KPI delta / captions: `text-xs text-muted-foreground tabular-nums`
  - Body / table / buttons / inputs: `text-sm` (buttons `font-medium`)
  - Sidebar group label: `text-xs font-medium text-sidebar-foreground/70`
- Mobile inputs forced to `16px` (`text-base sm:text-sm`) to prevent iOS zoom.

### Radius & Spacing (4px grid)
- `--radius: 0.625rem` (10px) default, or `0.375rem` (6px) for `swiss-grid` / `industrial-ops`.
- Main content: `px-4 py-6`, max `max-w-7xl mx-auto` on wide screens.
- Root clipping: `overflow-x: clip` on `html, body`.
- Motion: transition specific properties only (`transition-colors`, `transition-[width,height,padding] duration-200 ease-out`), never `transition-all`.

### Iconography
- **Lucide only**, stroke 2, round caps. Default size `size-4` (16px).
- Semantic icon mapping:
  - Nav: Dashboard `LayoutDashboard`, Tasks `ListChecks`, Apps `Package`, Chats `MessagesSquare`, Users `Users`, Auth `ShieldCheck`, Errors `Bug`, Settings `Settings`, Help `HelpCircle`.
  - Task status: Backlog `HelpCircle`, Queued `Circle`, In progress `Timer`, Done `CheckCircle`, Canceled `CircleOff`.
  - Priority: Low `ArrowDown`, Medium `ArrowRight`, High `ArrowUp`, Critical `AlertCircle`.

---

## 3. Layout Shell (for Admin Backoffice & Workbenches)

```text
+----------+----------------------------------------------+
| Team     | [=] | TopNav links .... [Search Ctrl+K] (user)| h-16 sticky
| switcher +----------------------------------------------+
|----------+ Workspace Title               [Primary Action]|
| General  | Main Operational Surface (see 4.1 Variants)  |
|  > items |                                              |
| Pages    |                                              |
|----------+                                              |
| NavUser  |                                              |
+----------+----------------------------------------------+
```
- **Sidebar**: width `16rem`, icon-collapsed `3rem`, mobile sheet `18rem`, toggle `Ctrl+B`.
- **Header**: `SidebarTrigger variant=outline` -> vertical `Separator h-6` -> page controls -> right cluster (`Search Ctrl+K` -> `ThemeSwitch` -> `ProfileDropdown`).

---

## 4. Page Patterns & 4 Distinct Dashboard Compositions

### 4.1 Choose One of 4 Dashboard Compositions (Avoid Repetitive 4-Card Grids)

Do **not** build every dashboard with the exact same 4 KPI cards on top + 1 bar chart on the left. Pick the composition that fits the domain:

1. **Composition A: Stat-Led Quantitative Workbench (Fintech, Mutual Funds, Executive Analytics)**
   - Top band: 1 dominant hero metric tile (`col-span-12 lg:col-span-4`, large figure + period comparison) paired directly beside the primary multi-series comparative chart (`lg:col-span-8`).
   - Bottom band: Full-width sortable ranking table with inline horizontal proportion bars and `tabular-nums`.
2. **Composition B: Live Operations Queue (Clinic Queue, Service Dispatch, Order Fulfillment)**
   - Left pane (`lg:col-span-5`): Active call card (huge queue number `text-5xl font-mono tabular-nums`, room/doctor status, next-in-line controls).
   - Right pane (`lg:col-span-7`): Real-time queue table filtered by room/status with one-click call/skip/complete actions.
3. **Composition C: High-Density Cashier / Inventory Split (POS, Retail, Warehouse)**
   - Left pane (`lg:col-span-7`): Fast searchable item grid/table with barcode/SKU filter and keyboard shortcut badges (`[F2]`, `[F4]`).
   - Right pane (`lg:col-span-5`): Sticky active transaction receipt, quantity steppers, discount/tax calculation, and bottom-anchored checkout button.
4. **Composition D: Classic SaaS Overview (General Admin Backoffice)**
   - Title row + Tabs -> 3 or 4 metric tiles -> `lg:grid-cols-7` split with primary time-series chart (`col-span-4`) and recent activity ledger (`col-span-3`).

### 4.2 Other Core Backoffice Pages (see `resources/patterns.md`)
- **Data table page**: filter input (`h-8 w-[150px] lg:w-[250px]`), faceted filters, column toggle, `rounded-md border` table with `tabular-nums`, row action dropdown, pagination, right **Sheet** drawer for Create/Edit, **ConfirmDialog** for delete.
- **Settings**: left vertical sidebar nav (`lg:w-1/5`), right content `max-w-xl` form sections.
- **Auth**: centered `max-w-[440px]` card or 2-column split with live product preview on the right; never pre-fill demo credentials in production handoff (Rule 18).

---

## 5. Micro-details

- Buttons: `h-9 px-4` default (`min-h-11` on mobile touch targets), `cursor-pointer` on enabled buttons; disabled = `opacity-50 pointer-events-none`.
- Focus: `focus-visible:ring-[3px] ring-ring/50 border-ring`.
- Toasts: **Sonner**, short formal sentence, zero emoji.
- Numbers: formatted with locale separators and `tabular-nums`.
- Empty states: clear explanation + primary recovery button inside `h-32` container.
- Skeletons (`animate-pulse rounded-md bg-accent`) while loading.
