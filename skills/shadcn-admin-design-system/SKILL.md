---
name: shadcn-admin-design-system
description: >-
  Pranataa's personal UI/UX design system, distilled from satnaing/shadcn-admin
  (slate oklch palette, Inter/Manrope, 0.625rem radius, 16rem collapsible sidebar,
  sticky blurred header, KPI cards, TanStack data tables, Cmd+K palette, config drawer,
  Lucide icons). Use whenever building or restyling ANY UI for the user — dashboards,
  admin panels, landing pages, web apps, Laravel Blade views, React/Next/Vite apps —
  unless the user explicitly asks for a different visual style.
---

# Shadcn-Admin Design System (Pranataa Edition)

The user loves the exact look & feel of `satnaing/shadcn-admin`: calm slate
neutrals, quiet borders, tight typography, generous-but-consistent spacing, and
small, muted Lucide icons. Reproduce it faithfully. **Restraint is the style** —
no gradients, no glow, no loud colors outside charts and status badges.

Reference implementation (if present locally):
`C:\Users\User\Desktop\pranataa-lab\shadcn-admin`

Resources in this skill:
- `resources/theme.css` — drop-in design tokens (light + dark) + base layer.
- `resources/patterns.md` — copy-paste markup for every page pattern
  (React/Tailwind **and** plain HTML/Blade variants).

---

## 1. Workflow

1. **Detect stack.**
   - React/Vite/Next → install Tailwind v4 + shadcn/ui (`npx shadcn@latest init`,
     style `new-york`, base color `slate`, CSS variables ON), `lucide-react`,
     `tw-animate-css`. Then add components as needed
     (`button card badge input tabs table dropdown-menu avatar sidebar sheet dialog command tooltip separator skeleton sonner`).
   - Laravel Blade / plain HTML → Tailwind v4 via Vite, copy `resources/theme.css`,
     use Lucide via `lucide` (`<i data-lucide="...">`) or `blade-lucide-icons`.
     Recreate components with the exact class strings from `patterns.md`.
2. **Install tokens** from `resources/theme.css` (never invent new hex colors).
3. **Build the shell first** (sidebar + header + main), then pages.
4. **Verify**: both light & dark mode, mobile (sidebar → sheet), keyboard focus rings.

---

## 2. Design Tokens

### Color (oklch, Tailwind "slate" family)
| Token | Light | Dark | Usage |
|---|---|---|---|
| `background` | white | `oklch(0.129 0.042 264.7)` deep navy-slate | page |
| `foreground` | slate-950 | slate-50 | text |
| `card` | white | `oklch(0.14 0.04 259.2)` (1 step lighter than bg) | cards |
| `primary` | slate-900 | slate-200 | primary buttons (inverts per mode!) |
| `secondary/muted/accent` | slate-100 | slate-800 | hover, tabs track, chips |
| `muted-foreground` | slate-500 | slate-400 | descriptions, icons, captions |
| `border` / `input` | slate-200 | white/10% · white/15% | all lines |
| `destructive` | red-600 | red-400 | delete, errors |
| `ring` | slate-400 | slate-500 | focus at `/50` opacity, 3px |

Rules:
- Primary is **monochrome** (near-black / near-white). Color appears only in
  charts (`chart-1..5`) and semantic status badges.
- Dark-mode borders are translucent white (`/10%`), never gray hex.
- Sidebar uses the same tokens as background (`--sidebar: var(--background)`).

### Status badge palette (outline badge + tint)
```
active    → bg-teal-100/30 text-teal-900 dark:text-teal-200 border-teal-200
inactive  → bg-neutral-300/40 border-neutral-300
invited   → bg-sky-200/40 text-sky-900 dark:text-sky-100 border-sky-300
suspended → bg-destructive/10 dark:bg-destructive/50 text-destructive dark:text-primary border-destructive/10
```
Extend the same recipe (`bg-{c}-100/30 text-{c}-900 dark:text-{c}-200 border-{c}-200`) for new states.

### Typography
- Font: **Inter** (default), **Manrope** alt, `system` fallback; user-switchable
  via `font-inter | font-manrope` class on `<html>`.
- Scale (keep it small and tight):
  - Page title: `text-2xl font-bold tracking-tight`
  - Page subtitle: `text-muted-foreground` (base size)
  - Card title: `font-semibold leading-none` (KPI card title: `text-sm font-medium`)
  - KPI value: `text-2xl font-bold`
  - KPI delta / captions: `text-xs text-muted-foreground`
  - Body / table / buttons / inputs: `text-sm` (buttons `font-medium`)
  - Sidebar group label: `text-xs font-medium text-sidebar-foreground/70`
- Mobile inputs forced to `16px` to prevent iOS zoom.

### Radius
`--radius: 0.625rem` (10px). `sm = r-4px`, `md = r-2px` (buttons, inputs),
`lg = r`, `xl = r+4px` (**cards: `rounded-xl`**). Badges `rounded-md`.

### Spacing rhythm (4px grid)
- Main content: `px-4 py-6`, max `max-w-7xl mx-auto` on wide screens (unless fluid).
- Header: `h-16`, inner `p-4 gap-3 sm:gap-4`.
- Section gaps: `space-y-4` / `gap-4` everywhere (grids, tabs, stacks).
- Card: `py-6 gap-6`, header/content `px-6`, header internal `gap-1.5`.
- KPI card header: `flex-row items-center justify-between space-y-0 pb-2`.
- Title row: `mb-2 flex items-center justify-between space-y-2` (or
  `flex flex-wrap items-end justify-between gap-2` with subtitle).
- Lists (recent sales): `space-y-8`, rows `flex items-center gap-4`, avatar `h-9 w-9`.

### Elevation & effects
- Cards `shadow-sm`; buttons/inputs `shadow-xs`; nothing heavier at rest.
- Sticky header gains `shadow` + `bg-background/20 backdrop-blur-lg` only
  after scroll > 10px.
- Thin scrollbars: `scrollbar-width: thin; scrollbar-color: var(--border) transparent`.
- Motion: `transition-all`, collapsibles 300ms ease-out slide, `tw-animate-css`
  for dialog/dropdown fade-zoom. Top route loading bar (thin, `react-top-loading-bar`).

### Iconography
- **Lucide only**, stroke 2, round caps. Default size `size-4` (16px).
- KPI icons: `h-4 w-4 text-muted-foreground`, top-right of card.
- Icons in buttons inherit `size-4`, `gap-2` to text.
- Semantic icon mapping (reuse consistently):
  - Nav: Dashboard `LayoutDashboard`, Tasks `ListTodo`, Apps `Package`,
    Chats `MessagesSquare`, Users `Users`, Auth `ShieldCheck`, Errors `Bug`,
    Settings `Settings`, Help `HelpCircle`, Profile `UserCog`, Account `Wrench`,
    Appearance `Palette`, Notifications `Bell`, Display `Monitor`.
  - Errors: 401 `Lock`, 403 `UserX`, 404 `FileX`, 500 `ServerOff`, maintenance `Construction`.
  - Task status: Backlog `HelpCircle`, Todo `Circle`, In progress `Timer`,
    Done `CheckCircle`, Canceled `CircleOff`.
  - Priority: Low `ArrowDown`, Medium `ArrowRight`, High `ArrowUp`, Critical `AlertCircle`.
  - Roles: Superadmin `Shield`, Admin `UserCheck`, Manager `Users`, Cashier `CreditCard`.
  - KPI: revenue `DollarSign`, subscriptions `Users`, sales `CreditCard`, active `Activity`.
  - Team logos: `Command`, `GalleryVerticalEnd`, `AudioWaveform`.

---

## 3. Layout Shell (mandatory for app/dashboard projects)

```
┌──────────┬──────────────────────────────────────────────┐
│ Team     │ [≡] │ TopNav links ···· [Search ⌘K] ☀ ⚙ (avatar)│ h-16 sticky
│ switcher ├──────────────────────────────────────────────┤
│──────────│ Dashboard                          [Download]│
│ General  │ [Overview|Analytics|Reports|Notifications]   │
│  ▸ items │ ┌KPI┐┌KPI┐┌KPI┐┌KPI┐   grid sm:2 lg:4 gap-4   │
│ Pages    │ ┌── Chart (col 4/7) ──┐┌─ List (col 3/7) ─┐  │
│ Other    │ └─────────────────────┘└──────────────────┘  │
│──────────│                                              │
│ NavUser  │                                              │
└──────────┴──────────────────────────────────────────────┘
```
- **Sidebar**: width `16rem`, icon-collapsed `3rem`, mobile sheet `18rem`,
  toggle `Ctrl/⌘+B`, state persisted in cookie. Header = team switcher
  (logo tile + name + plan), body = grouped nav (`General / Pages / Other`)
  with collapsible sub-items (chevron rotates 90°) and optional count badge
  (e.g. Chats `3`), footer = `NavUser` (avatar, name, email, dropdown).
  Variants: `inset` (default look), `floating`, `sidebar`; collapsible: `icon | offcanvas`.
- **Header**: `SidebarTrigger variant=outline` → vertical `Separator h-6` →
  page controls. Right cluster order: **Search → ThemeSwitch → ConfigDrawer → ProfileDropdown**.
- **Search** looks like an input (`text-muted-foreground`, placeholder
  "Search", trailing `<kbd>⌘K</kbd>`), opens the **Command Menu** (cmdk) listing
  every nav route grouped like the sidebar + Theme (Light/Dark/System).
- **ConfigDrawer** (sheet from right): theme, sidebar variant, layout
  (default / compact / full), direction (LTR/RTL), reset button.
- Accessibility: `SkipToMain` link, focus-visible rings, aria labels, RTL-safe
  logical classes (`ms-/me-/ps-/pe-/start-/end-`, never `ml/mr` in new code).

---

## 4. Page Patterns (see `resources/patterns.md` for full markup)

1. **Dashboard** — title row + Tabs (some `disabled` as roadmap) → 4 KPI cards →
   `lg:grid-cols-7` with chart card (`col-span-4`, content `ps-2`) and list card
   (`col-span-3`, with `CardDescription` like "You made 265 sales this month.").
   Charts: Recharts `BarChart`, bars `fill="currentColor" className="fill-primary"`
   `radius={[4,4,0,0]}`, axes `stroke="#888888" fontSize={12} tickLine={false} axisLine={false}`.
2. **Data table page** (Tasks/Users) — title + subtitle left, primary buttons right
   (`Import` outline + `Create` default, each with icon). Toolbar: filter input
   (`h-8 w-[150px] lg:w-[250px]`), faceted filters (dashed outline button with
   `PlusCircle`, selected count badges), "Reset ✕" ghost, "View" column toggle
   right. Table inside `rounded-md border`. Row: checkbox, ID mono-ish, label
   `Badge variant=outline` + title truncated, status/priority = icon + text
   (`text-muted-foreground` icon `size-4`), row actions `⋯` (`DotsHorizontal`)
   dropdown. Pagination: "x of y row(s) selected", rows-per-page select,
   "Page n of m", first/prev/next/last icon buttons (`size-8`). Floating bulk
   action bar when rows selected. Create/Edit = right **Sheet** drawer; delete =
   **ConfirmDialog** (destructive, type-to-confirm for dangerous ops).
3. **Settings** — title + `Separator my-4 lg:my-6`, left vertical sidebar nav
   (`lg:w-1/5`, ghost links, active = `bg-muted`), right content `max-w-xl`,
   each section = `h3 text-lg font-medium` + `text-sm text-muted-foreground` +
   separator + form (`space-y-8`), single submit button at bottom.
4. **Apps / integrations grid** — search + filter select + sort toggle, grid
   `md:grid-cols-2 lg:grid-cols-3 gap-4`, `li.rounded-lg.border.p-4 hover:shadow-md`,
   logo tile `size-10 rounded-lg bg-muted p-2`, button "Connected"/"Connect"
   (`variant=outline size=sm`, connected = blue tint).
5. **Chats** — two-pane: conversation list (search, avatars, last message
   truncated) + thread (bubbles: mine `bg-primary/90 text-primary-foreground
   rounded-[16px_16px_0_16px]`, theirs `bg-muted rounded-[16px_16px_16px_0]`,
   timestamps `text-xs`), composer with icon buttons + send.
6. **Auth** — centered `max-w-[480px]` card, logo + app name above; 2-column
   variant with screenshot on the right. Forms: label above input, `PasswordInput`
   with eye toggle, "Forgot password?" `text-sm text-muted-foreground` link,
   full-width primary button, "Or continue with" divider, GitHub/Facebook outline buttons.
   OTP uses 6-slot `InputOTP`.
7. **Errors** — centered, huge code `text-[7rem] font-bold leading-tight`,
   `font-medium` headline, muted explanation with `<br/>`, buttons
   "Go Back" (outline) + "Back to Home".
8. **Coming soon** — centered `Telescope` icon `size-[72px]` + title + muted text.

---

## 5. Micro-details that make it feel "right"

- Buttons: `h-9 px-4` default, `h-8 px-3` sm, `size-9` icon; `cursor-pointer`
  on all enabled buttons; disabled = `opacity-50 pointer-events-none`.
- Focus: `focus-visible:ring-[3px] ring-ring/50 border-ring`; invalid →
  `aria-invalid:border-destructive ring-destructive/20`.
- Tabs list: `bg-muted rounded-lg p-[3px] h-9`; active trigger
  `bg-background shadow-sm` (dark: `bg-input/30`).
- Toasts: **Sonner**, top-right/bottom-right, short sentence, no emoji.
- Numbers: currency with `$` + thousands separator, deltas prefixed `+`.
- Truncate long text with `truncate` / `LongText` + tooltip.
- Empty states: "No results." centered in table body `h-24`.
- Skeletons (`animate-pulse rounded-md bg-accent`) while loading.
- Copy tone: short, sentence case, friendly-professional
  ("Here's a list of your tasks for this month!").
- Never mix accent colors into chrome; never use pure `#000`/`#fff` borders;
  never exceed `shadow-sm` on cards at rest.

---

## 6. Adapting to Other Projects

- **Brand color needed?** Change only `--primary` / `--primary-foreground`
  (and `--ring`) — keep everything else slate. Optionally tint `--sidebar-primary`.
- **Landing pages**: reuse tokens, Inter, `rounded-xl` cards, muted text,
  `max-w-7xl px-4`, section spacing `py-16 md:py-24`, monochrome primary CTA +
  outline secondary CTA.
- **Laravel Blade**: make Blade components mirroring shadcn names
  (`<x-ui.button variant="outline">`, `<x-ui.card>`), toggle dark mode with
  `.dark` on `<html>` stored in `localStorage`.
- Always deliver both light and dark mode.
