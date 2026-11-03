# Pattern Library (copy-paste)

All snippets use the tokens from `theme.css`. React versions assume shadcn/ui
components; HTML/Blade versions use raw Tailwind classes equivalent to them.

---

## Raw class recipes (for non-React stacks)

```txt
button.default   inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all h-9 px-4 py-2 bg-primary text-primary-foreground shadow-xs hover:bg-primary/90 focus-visible:ring-[3px] focus-visible:ring-ring/50 outline-none disabled:opacity-50 disabled:pointer-events-none
button.outline   ...same base... border bg-background shadow-xs hover:bg-accent hover:text-accent-foreground dark:bg-input/30 dark:border-input dark:hover:bg-input/50
button.ghost     ...same base... hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50
button.destructive ...base... bg-destructive text-white shadow-xs hover:bg-destructive/90 dark:bg-destructive/60
button.sm        h-8 gap-1.5 px-3     button.icon  size-9
card             flex flex-col gap-6 rounded-xl border bg-card py-6 text-card-foreground shadow-sm
card.header      grid auto-rows-min items-start gap-1.5 px-6
card.title       leading-none font-semibold
card.description text-sm text-muted-foreground
card.content     px-6
input            h-9 w-full min-w-0 rounded-md border border-input bg-transparent px-3 py-1 text-base md:text-sm shadow-xs placeholder:text-muted-foreground dark:bg-input/30 focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 outline-none
badge            inline-flex items-center justify-center rounded-md border px-2 py-0.5 text-xs font-medium w-fit whitespace-nowrap gap-1 [&>svg]:size-3
badge.outline    text-foreground
badge.secondary  border-transparent bg-secondary text-secondary-foreground
tabs.list        inline-flex h-9 w-fit items-center justify-center rounded-lg bg-muted p-[3px] text-muted-foreground
tabs.trigger     inline-flex h-[calc(100%-1px)] flex-1 items-center justify-center gap-1.5 rounded-md border border-transparent px-2 py-1 text-sm font-medium whitespace-nowrap data-[state=active]:bg-background data-[state=active]:text-foreground data-[state=active]:shadow-sm dark:data-[state=active]:bg-input/30 dark:data-[state=active]:border-input
table.wrap       rounded-md border overflow-hidden
table            w-full caption-bottom text-sm
th               h-10 px-2 text-start align-middle font-medium text-foreground whitespace-nowrap
tr               border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted
td               p-2 align-middle whitespace-nowrap
kbd              pointer-events-none inline-flex h-5 select-none items-center gap-1 rounded border bg-muted px-1.5 font-mono text-[10px] font-medium opacity-100
separator        shrink-0 bg-border h-px w-full   (vertical: w-px h-6)
avatar           relative flex size-8 shrink-0 overflow-hidden rounded-full  (fallback: bg-muted flex items-center justify-center)
skeleton         animate-pulse rounded-md bg-accent
```

---

## 1. App shell (HTML / Blade)

```html
<html lang="en" class="font-inter"><!-- add class="dark" for dark mode -->
<body class="min-h-svh bg-background text-foreground">
<a href="#content" class="sr-only focus:not-sr-only focus:fixed focus:top-4 focus:start-4 focus:z-[999] focus:rounded-md focus:bg-primary focus:px-4 focus:py-2 focus:text-primary-foreground">Skip to Main</a>
<div class="flex min-h-svh w-full">
  <!-- Sidebar -->
  <aside class="hidden md:flex w-64 shrink-0 flex-col border-e bg-sidebar text-sidebar-foreground sticky top-0 h-svh">
    <!-- Team switcher -->
    <div class="p-2">
      <button class="flex w-full items-center gap-2 rounded-md p-2 text-start hover:bg-sidebar-accent">
        <div class="flex aspect-square size-8 items-center justify-center rounded-lg bg-sidebar-primary text-sidebar-primary-foreground"><i data-lucide="command" class="size-4"></i></div>
        <div class="grid flex-1 text-sm leading-tight"><span class="truncate font-semibold">Pranataa Labs</span><span class="truncate text-xs">Laravel + Tailwind</span></div>
        <i data-lucide="chevrons-up-down" class="ms-auto size-4"></i>
      </button>
    </div>
    <!-- Nav group -->
    <nav class="flex-1 overflow-y-auto p-2">
      <p class="flex h-8 items-center px-2 text-xs font-medium text-sidebar-foreground/70">General</p>
      <ul class="flex flex-col gap-1">
        <li><a href="/" class="flex h-8 items-center gap-2 rounded-md px-2 text-sm bg-sidebar-accent font-medium text-sidebar-accent-foreground"><i data-lucide="layout-dashboard" class="size-4"></i>Dashboard</a></li>
        <li><a href="/tasks" class="flex h-8 items-center gap-2 rounded-md px-2 text-sm hover:bg-sidebar-accent"><i data-lucide="list-todo" class="size-4"></i>Tasks</a></li>
        <li><a href="/chats" class="flex h-8 items-center gap-2 rounded-md px-2 text-sm hover:bg-sidebar-accent"><i data-lucide="messages-square" class="size-4"></i>Chats<span class="ms-auto rounded-full bg-primary px-1.5 py-0.5 text-xs text-primary-foreground">3</span></a></li>
      </ul>
    </nav>
    <!-- NavUser -->
    <div class="p-2">
      <button class="flex w-full items-center gap-2 rounded-md p-2 text-start hover:bg-sidebar-accent">
        <span class="flex size-8 items-center justify-center rounded-lg bg-muted text-xs">PL</span>
        <div class="grid flex-1 text-sm leading-tight"><span class="truncate font-semibold">pranataa</span><span class="truncate text-xs">you@mail.com</span></div>
        <i data-lucide="chevrons-up-down" class="ms-auto size-4"></i>
      </button>
    </div>
  </aside>

  <div class="flex min-w-0 flex-1 flex-col">
    <!-- Header (add JS: when scrollY>10 add 'shadow' + blurred bg) -->
    <header id="hdr" class="sticky top-0 z-50 h-16">
      <div class="relative flex h-full items-center gap-3 p-4 sm:gap-4">
        <button class="[button.outline] size-7"><i data-lucide="panel-left" class="size-4"></i></button>
        <div class="h-6 w-px bg-border"></div>
        <nav class="me-auto hidden md:flex items-center gap-4 lg:gap-6 text-sm font-medium">
          <a class="text-primary">Overview</a><a class="text-muted-foreground hover:text-primary">Customers</a>
        </nav>
        <button class="relative inline-flex h-8 w-full sm:w-40 lg:w-56 items-center justify-start rounded-md border bg-muted/25 px-3 text-sm text-muted-foreground shadow-none hover:bg-accent">
          <i data-lucide="search" class="me-2 size-4"></i>Search
          <kbd class="absolute end-[0.3rem] top-[0.3rem] hidden sm:inline-flex h-5 items-center gap-1 rounded border bg-muted px-1.5 font-mono text-[10px] font-medium"><span class="text-xs">⌘</span>K</kbd>
        </button>
        <button class="[button.ghost] size-9 rounded-full"><i data-lucide="sun" class="size-[1.2rem]"></i></button>
        <button class="[button.ghost] size-9 rounded-full"><i data-lucide="settings" class="size-[1.2rem]"></i></button>
        <span class="flex size-8 items-center justify-center rounded-full bg-muted text-xs">PL</span>
      </div>
    </header>
    <main id="content" class="px-4 py-6 mx-auto w-full max-w-7xl"> ... </main>
  </div>
</div>
```

---

## 2. Dashboard (React)

```tsx
<Main>
  <div className='mb-2 flex items-center justify-between space-y-2'>
    <h1 className='text-2xl font-bold tracking-tight'>Dashboard</h1>
    <Button>Download</Button>
  </div>
  <Tabs defaultValue='overview' className='space-y-4'>
    <div className='w-full overflow-x-auto pb-2'>
      <TabsList>
        <TabsTrigger value='overview'>Overview</TabsTrigger>
        <TabsTrigger value='analytics'>Analytics</TabsTrigger>
        <TabsTrigger value='reports' disabled>Reports</TabsTrigger>
      </TabsList>
    </div>
    <TabsContent value='overview' className='space-y-4'>
      <div className='grid gap-4 sm:grid-cols-2 lg:grid-cols-4'>
        {kpis.map(k => (
          <Card key={k.title}>
            <CardHeader className='flex flex-row items-center justify-between space-y-0 pb-2'>
              <CardTitle className='text-sm font-medium'>{k.title}</CardTitle>
              <k.icon className='h-4 w-4 text-muted-foreground' />
            </CardHeader>
            <CardContent>
              <div className='text-2xl font-bold'>{k.value}</div>
              <p className='text-xs text-muted-foreground'>{k.delta}</p>
            </CardContent>
          </Card>
        ))}
      </div>
      <div className='grid grid-cols-1 gap-4 lg:grid-cols-7'>
        <Card className='col-span-1 lg:col-span-4'>
          <CardHeader><CardTitle>Overview</CardTitle></CardHeader>
          <CardContent className='ps-2'>
            <ResponsiveContainer width='100%' height={350}>
              <BarChart data={data}>
                <XAxis dataKey='name' stroke='#888888' fontSize={12} tickLine={false} axisLine={false} />
                <YAxis stroke='#888888' fontSize={12} tickLine={false} axisLine={false} tickFormatter={v => `$${v}`} />
                <Bar dataKey='total' fill='currentColor' radius={[4, 4, 0, 0]} className='fill-primary' />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
        <Card className='col-span-1 lg:col-span-3'>
          <CardHeader>
            <CardTitle>Recent Sales</CardTitle>
            <CardDescription>You made 265 sales this month.</CardDescription>
          </CardHeader>
          <CardContent>
            <div className='space-y-8'>
              <div className='flex items-center gap-4'>
                <Avatar className='h-9 w-9'><AvatarFallback>OM</AvatarFallback></Avatar>
                <div className='flex flex-1 flex-wrap items-center justify-between'>
                  <div className='space-y-1'>
                    <p className='text-sm leading-none font-medium'>Olivia Martin</p>
                    <p className='text-sm text-muted-foreground'>olivia.martin@email.com</p>
                  </div>
                  <div className='font-medium'>+$1,999.00</div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </TabsContent>
  </Tabs>
</Main>
```

---

## 3. Data-table page header

```tsx
<div className='flex flex-wrap items-end justify-between gap-2'>
  <div>
    <h2 className='text-2xl font-bold tracking-tight'>Tasks</h2>
    <p className='text-muted-foreground'>Here&apos;s a list of your tasks for this month!</p>
  </div>
  <div className='flex gap-2'>
    <Button variant='outline' className='space-x-1'><span>Import</span><Download size={18} /></Button>
    <Button className='space-x-1'><span>Create</span><Plus size={18} /></Button>
  </div>
</div>
<div className='-mx-4 flex-1 overflow-auto px-4 py-1'>{/* DataTable */}</div>
```

Toolbar:
```tsx
<div className='flex items-center justify-between'>
  <div className='flex flex-1 flex-col-reverse items-start gap-y-2 sm:flex-row sm:items-center sm:space-x-2'>
    <Input placeholder='Filter tasks...' className='h-8 w-[150px] lg:w-[250px]' />
    <Button variant='outline' size='sm' className='h-8 border-dashed'><PlusCircle className='size-4' />Status</Button>
    <Button variant='ghost' className='h-8 px-2 lg:px-3'>Reset<X className='ms-2 h-4 w-4' /></Button>
  </div>
  <Button variant='outline' size='sm' className='ms-auto hidden h-8 lg:flex'><Settings2 className='size-4' />View</Button>
</div>
```

Status cell: `<div className='flex w-[100px] items-center gap-2'><Icon className='size-4 text-muted-foreground' /><span>{label}</span></div>`

Title cell: `<div className='flex space-x-2'><Badge variant='outline'>{label}</Badge><span className='max-w-32 truncate font-medium sm:max-w-72 md:max-w-[31rem]'>{title}</span></div>`

Pagination row: `flex items-center justify-between overflow-clip px-2` · left `text-sm text-muted-foreground` · nav buttons `variant=outline className='size-8 p-0'`.

---

## 4. Settings layout

```tsx
<div className='space-y-0.5'>
  <h1 className='text-2xl font-bold tracking-tight md:text-3xl'>Settings</h1>
  <p className='text-muted-foreground'>Manage your account settings and set e-mail preferences.</p>
</div>
<Separator className='my-4 lg:my-6' />
<div className='flex flex-1 flex-col space-y-2 overflow-hidden md:space-y-2 lg:flex-row lg:space-y-0 lg:space-x-12'>
  <aside className='top-0 lg:sticky lg:w-1/5'>{/* nav: ghost buttons, active bg-muted hover:bg-accent, justify-start */}</aside>
  <div className='flex w-full overflow-y-hidden p-1'>
    <div className='flex flex-1 flex-col'>
      <div className='flex-none'>
        <h3 className='text-lg font-medium'>Profile</h3>
        <p className='text-sm text-muted-foreground'>This is how others will see you on the site.</p>
      </div>
      <Separator className='my-4 flex-none' />
      <div className='faded-bottom h-full w-full overflow-y-auto scroll-smooth pe-4 pb-12'>
        <div className='-mx-1 px-1.5 lg:max-w-xl'>{/* form space-y-8 */}</div>
      </div>
    </div>
  </div>
</div>
```

---

## 5. Error page

```tsx
<div className='h-svh'>
  <div className='m-auto flex h-full w-full flex-col items-center justify-center gap-2'>
    <h1 className='text-[7rem] leading-tight font-bold'>404</h1>
    <span className='font-medium'>Oops! Page Not Found!</span>
    <p className='text-center text-muted-foreground'>It seems like the page you're looking for <br /> does not exist or might have been removed.</p>
    <div className='mt-6 flex gap-4'>
      <Button variant='outline'>Go Back</Button>
      <Button>Back to Home</Button>
    </div>
  </div>
</div>
```

---

## 6. Auth card

```tsx
<div className='container grid h-svh max-w-none items-center justify-center'>
  <div className='mx-auto flex w-full flex-col justify-center space-y-2 py-8 sm:w-[480px] sm:p-8'>
    <div className='mb-4 flex items-center justify-center'>
      <Logo className='me-2' /><h1 className='text-xl font-medium'>Shadcn Admin</h1>
    </div>
    <Card className='gap-4'>
      <CardHeader>
        <CardTitle className='text-lg tracking-tight'>Sign in</CardTitle>
        <CardDescription>Enter your email and password below <br /> to log into your account</CardDescription>
      </CardHeader>
      <CardContent>{/* form grid gap-3; full-width Button mt-2; divider "Or continue with" */}</CardContent>
      <CardFooter><p className='px-8 text-center text-sm text-muted-foreground'>By clicking sign in, you agree to our Terms of Service and Privacy Policy.</p></CardFooter>
    </Card>
  </div>
</div>
```

Divider: `<div className='relative my-2'><div className='absolute inset-0 flex items-center'><span className='w-full border-t' /></div><div className='relative flex justify-center text-xs uppercase'><span className='bg-background px-2 text-muted-foreground'>Or continue with</span></div></div>`

---

## 7. Apps grid card

```html
<li class="rounded-lg border p-4 hover:shadow-md">
  <div class="mb-8 flex items-center justify-between">
    <div class="flex size-10 items-center justify-center rounded-lg bg-muted p-2"><!-- logo --></div>
    <button class="[button.outline] h-8 px-3 text-sm border-blue-300 bg-blue-50 hover:bg-blue-100 dark:border-blue-700 dark:bg-blue-950 dark:hover:bg-blue-900">Connected</button>
  </div>
  <h2 class="mb-1 font-semibold">Notion</h2>
  <p class="line-clamp-2 text-gray-500">Effortlessly sync Notion pages for seamless collaboration.</p>
</li>
```

---

## 8. Theme Switcher (Light / Dark / System 3-Way Mode)

### A. React Implementation (`ThemeSwitch.tsx` + `ThemeProvider.tsx`)

The iconic smooth rotating Sun/Moon toggle with Dropdown menu:

```tsx
// components/theme-switch.tsx
import { useEffect } from 'react'
import { Check, Moon, Sun } from 'lucide-react'
import { cn } from '@/lib/utils'
import { useTheme } from '@/context/theme-provider'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'

export function ThemeSwitch() {
  const { theme, setTheme } = useTheme()

  // Sync mobile browser status bar / theme-color
  useEffect(() => {
    const themeColor = theme === 'dark' ? '#020817' : '#fff'
    const meta = document.querySelector("meta[name='theme-color']")
    if (meta) meta.setAttribute('content', themeColor)
  }, [theme])

  return (
    <DropdownMenu modal={false}>
      <DropdownMenuTrigger asChild>
        <Button variant='ghost' size='icon' className='scale-95 rounded-full'>
          <Sun className='size-[1.2rem] scale-100 rotate-0 transition-all dark:scale-0 dark:-rotate-90' />
          <Moon className='absolute size-[1.2rem] scale-0 rotate-90 transition-all dark:scale-100 dark:rotate-0' />
          <span className='sr-only'>Toggle theme</span>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align='end'>
        <DropdownMenuItem onClick={() => setTheme('light')}>
          Light <Check size={14} className={cn('ms-auto', theme !== 'light' && 'hidden')} />
        </DropdownMenuItem>
        <DropdownMenuItem onClick={() => setTheme('dark')}>
          Dark <Check size={14} className={cn('ms-auto', theme !== 'dark' && 'hidden')} />
        </DropdownMenuItem>
        <DropdownMenuItem onClick={() => setTheme('system')}>
          System <Check size={14} className={cn('ms-auto', theme !== 'system' && 'hidden')} />
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
```

```tsx
// context/theme-provider.tsx (Cookie or localStorage based)
import { createContext, useContext, useEffect, useState, useMemo } from 'react'

type Theme = 'dark' | 'light' | 'system'
type ResolvedTheme = 'dark' | 'light'

type ThemeProviderState = {
  theme: Theme
  resolvedTheme: ResolvedTheme
  setTheme: (theme: Theme) => void
}

const ThemeContext = createContext<ThemeProviderState>({
  theme: 'system',
  resolvedTheme: 'light',
  setTheme: () => null,
})

export function ThemeProvider({ children, storageKey = 'vite-ui-theme', defaultTheme = 'system' }: { children: React.ReactNode, storageKey?: string, defaultTheme?: Theme }) {
  const [theme, setThemeState] = useState<Theme>(
    () => (localStorage.getItem(storageKey) as Theme) || defaultTheme
  )

  const resolvedTheme = useMemo<ResolvedTheme>(() => {
    if (theme === 'system') {
      return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
    }
    return theme as ResolvedTheme
  }, [theme])

  useEffect(() => {
    const root = window.document.documentElement
    root.classList.remove('light', 'dark')
    root.classList.add(resolvedTheme)

    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    const handleChange = () => {
      if (theme === 'system') {
        const next = mediaQuery.matches ? 'dark' : 'light'
        root.classList.remove('light', 'dark')
        root.classList.add(next)
      }
    }
    mediaQuery.addEventListener('change', handleChange)
    return () => mediaQuery.removeEventListener('change', handleChange)
  }, [theme, resolvedTheme])

  const setTheme = (nextTheme: Theme) => {
    localStorage.setItem(storageKey, nextTheme)
    setThemeState(nextTheme)
  }

  return (
    <ThemeContext.Provider value={{ theme, resolvedTheme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  )
}

export const useTheme = () => useContext(ThemeContext)
```

---

### B. Vanilla JS / Laravel Blade Implementation

Place this in the `<head>` of your Blade/HTML layout to prevent FOUC (Flash of Unstyled Content):

```html
<script>
  (function() {
    const t = localStorage.getItem('theme') || 'system';
    const isDark = t === 'dark' || (t === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches);
    document.documentElement.classList.toggle('dark', isDark);
  })();

  function setTheme(mode) {
    localStorage.setItem('theme', mode);
    const isDark = mode === 'dark' || (mode === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches);
    document.documentElement.classList.toggle('dark', isDark);
    const meta = document.querySelector("meta[name='theme-color']");
    if (meta) meta.setAttribute('content', isDark ? '#020817' : '#ffffff');
  }

  // Header scroll blur effect
  addEventListener('scroll', () => {
    const h = document.getElementById('hdr');
    if (!h) return;
    const on = window.scrollY > 10;
    h.classList.toggle('shadow', on);
    if (h.firstElementChild) {
      h.firstElementChild.classList.toggle('backdrop-blur-lg', on);
      h.firstElementChild.classList.toggle('bg-background/20', on);
    }
  }, { passive: true });
</script>
```
