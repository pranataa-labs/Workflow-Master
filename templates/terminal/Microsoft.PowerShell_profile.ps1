# ==============================================================================
# NCCA & PRANATAA LABS — POWERSHELL TERMINAL PROFILE (v2.2.0)
# Terintegrasi dengan Workflow Master (16 Agent Skills & 20 Engineering Rules)
# ==============================================================================

$script:WorkflowMasterRoot = "C:\Users\User\Desktop\pranataa-lab\workflow-master"
$script:GlobalSkillsDir    = "$HOME\.gemini\config\skills"

function Get-TerminalWidth {
    $w = 104
    try {
        if ($Host.UI.RawUI.WindowSize.Width -gt 40) {
            $w = $Host.UI.RawUI.WindowSize.Width
        }
    } catch { }
    return [Math]::Min(114, [Math]::Max(84, $w - 4))
}

function Wrap-TextLines {
    param(
        [string]$Text,
        [int]$MaxWidth
    )
    if ([string]::IsNullOrEmpty($Text)) { return @("") }
    if ($MaxWidth -lt 20) { $MaxWidth = 20 }

    $words = $Text -split '\s+'
    $lines = New-Object System.Collections.Generic.List[string]
    $current = ""

    foreach ($word in $words) {
        if ($current.Length -eq 0) {
            $current = $word
        } elseif (($current.Length + 1 + $word.Length) -le $MaxWidth) {
            $current += " $word"
        } else {
            $lines.Add($current)
            $current = $word
        }
    }
    if ($current.Length -gt 0) {
        $lines.Add($current)
    }
    return $lines.ToArray()
}

# ------------------------------------------------------------------------------
# PROMPT TERMINAL MODERN (NCCA + Path Ringkas + Status Git)
# ------------------------------------------------------------------------------
function prompt {
    $lastOk = $?
    $loc = (Get-Location).Path
    $homePath = $HOME
    if ($loc.StartsWith($homePath, [System.StringComparison]::OrdinalIgnoreCase)) {
        $loc = "~" + $loc.Substring($homePath.Length)
    }
    $loc = $loc -replace '\\', '/'

    $gitBranch = ""
    $gitDirty  = ""
    try {
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($LASTEXITCODE -eq 0 -and $branch) {
            $gitBranch = $branch.Trim()
            $status = git status --porcelain 2>$null
            if ($status) { $gitDirty = "*" }
        }
    } catch { }

    Write-Host ""
    Write-Host " +-[ " -NoNewline -ForegroundColor DarkGray
    Write-Host "NCCA" -NoNewline -ForegroundColor Cyan
    Write-Host " ]-[ " -NoNewline -ForegroundColor DarkGray
    Write-Host $loc -NoNewline -ForegroundColor White
    Write-Host " ]" -NoNewline -ForegroundColor DarkGray

    if ($gitBranch) {
        Write-Host "-( " -NoNewline -ForegroundColor DarkGray
        Write-Host "git:$gitBranch" -NoNewline -ForegroundColor Yellow
        if ($gitDirty) {
            Write-Host $gitDirty -NoNewline -ForegroundColor Red
        }
        Write-Host " )" -NoNewline -ForegroundColor DarkGray
    }
    Write-Host ""

    Write-Host " +-" -NoNewline -ForegroundColor DarkGray
    if ($lastOk) {
        Write-Host ">" -NoNewline -ForegroundColor Green
    } else {
        Write-Host ">" -NoNewline -ForegroundColor Red
    }
    return " "
}

# Konfigurasi warna sintaks PSReadLine jika modul tersedia
try {
    if (Get-Module -ListAvailable -Name PSReadLine) {
        Set-PSReadLineOption -Colors @{
            Command   = 'Cyan'
            Parameter = 'Yellow'
            String    = 'Green'
            Operator  = 'Gray'
            Variable  = 'Magenta'
            Number    = 'White'
            Comment   = 'DarkGray'
        } -ErrorAction SilentlyContinue
    }
} catch { }

# ------------------------------------------------------------------------------
# BANNER UTAMA NCCA
# ------------------------------------------------------------------------------
function NCCA {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$IgnoredArguments
    )

    Clear-Host

    $leftArt = @(
        '                     ''       ''                    ',
        ' ;,,,                ''       ''                ;;;;',
        ' `YES8888bo.         :       :         .od8888YES''',
        '   888I08D088b.      :       :      .d8888I8D088  ',
        '   8LOVEY''  `Y8b.    ''       ''    .d8Y''  `YLOVE8  ',
        '  jTHEE!  .db.  Yb. '' ''       '' '' .dY  .db.  8THEE!',
        '    `888  Y88Y        `b ( ) d''        Y88Y  888'' ',
        '     8MYb  ''"            '',''            ''"   dMY8 ',
        '    j8pRECIOUSgf"''       '':''       `"?g8pRECIOUSk ',
        '      ''Y''    .8''        d'' ''b        ''8.    ''Y''   ',
        '       !   .8'' db      d''; ;''b      db ''8.   !    ',
        '          d88  `''      8 ; ; 8      `''  88b       ',
        '         d88Ib       .g8 '','' 8g.       dI88b      ',
        '         :888LOVE88Y''             ''Y88LOVE888:    ',
        '         ''! THEE888''               `888THEE !''    ',
        '           ''8Y  `Y                   Y''  Y8''      ',
        '             Y                           Y        '
    )

    $right = @(
        '+----------------------------------------------------------+',
        '| National Cyber and Crypto Agency                _ [] X   |',
        '+----------------------------------------------------------+',
        '| PLAYERS      National Cyber     ##   ##  ####  ####  ####|',
        '| [ PRANATA ]  Sumbawa, ID.....   ###  ## ##    ##     ##  |',
        '| [ ANA     ]  SE Asia, Earth..   #### ## ##    ##     ####|',
        '| [ ANDREW  ]  ................   ## #### ##    ##     ##  |',
        '| [ ELIJAH  ]  [ CHENYU  ]        ##  ###  ####  ####  ##  |',
        '| [ HANNAH  ]  Indonesian vocational cybersecurity guild   |',
        '| [ CAIDAN  ]  Practice securing, building & maintaining   |',
        '| [ LOUANNE ]  national critical systems end-to-end.       |',
        '+----------------------------------------------------------+',
        '|           THE NATIONAL CYBER AND CRYPTO AGENCY           |',
        '|      <-========-  OF SUMBAWA, INDONESIA  -========->     |',
        '------------------------------------------------------------',
        '--------- ##    ##   ######     ######      ##   -----------',
        '--------- ###   ##  ##    ##   ##    ##    ####  -----------',
        '--------- ####  ##  ##         ##         ##  ## -----------',
        '--------- ## ## ##  ##         ##        ########-----------',
        '--------- ##  ####  ##    ##   ##    ##  ##    ##-----------',
        '--------- ##   ###   ######     ######   ##    ##-----------',
        '------------------------------------------------------------',
        '                                                            ',
        '   <-====- (WORKFLOW MASTER v2.2 - 16 AI SKILLS) -====->    ',
        '+----------------------------------------------------------+',
        '| Copyright (C) 2026. All rights reserved.     Terms & Co  |',
        '+----------------------------------------------------------+'
    )

    $termWidth = 120
    try {
        if ($Host.UI.RawUI.WindowSize.Width -gt 0) {
            $termWidth = $Host.UI.RawUI.WindowSize.Width
        }
    } catch { }

    if ($termWidth -ge 115) {
        $leftPadded = @()
        for ($i = 0; $i -lt 5; $i++) { $leftPadded += (' ' * 52) }
        foreach ($line in $leftArt) {
            $leftPadded += (' ' + $line).PadRight(52)
        }
        while ($leftPadded.Count -lt $right.Count) {
            $leftPadded += (' ' * 52)
        }

        $totalWidth = 52 + 60
        $leftMargin = [Math]::Max(0, [Math]::Floor(($termWidth - $totalWidth) / 2))
        $prefix = ' ' * $leftMargin

        for ($i = 0; $i -lt $right.Length; $i++) {
            Write-Host "$prefix$($leftPadded[$i])" -NoNewline -ForegroundColor White
            Write-Host $right[$i] -ForegroundColor Cyan
        }
    } else {
        $crestPad = [Math]::Max(0, [Math]::Floor(($termWidth - 52) / 2))
        $cardPad  = [Math]::Max(0, [Math]::Floor(($termWidth - 60) / 2))
        $crestPrefix = ' ' * $crestPad
        $cardPrefix  = ' ' * $cardPad

        Write-Host ""
        foreach ($line in $leftArt) {
            Write-Host "$crestPrefix $line" -ForegroundColor White
        }
        Write-Host ""
        foreach ($line in $right) {
            Write-Host "$cardPrefix$line" -ForegroundColor Cyan
        }
    }

    Write-Host ""
    Write-Host "  [INFO] Selamat datang di Terminal NCCA. Ketik " -NoNewline -ForegroundColor Gray
    Write-Host "info" -NoNewline -ForegroundColor Yellow
    Write-Host " untuk panduan lengkap & contoh prompt AI, atau " -NoNewline -ForegroundColor Gray
    Write-Host "info prompt" -NoNewline -ForegroundColor Green
    Write-Host " khusus katalog prompt." -ForegroundColor Gray
    Write-Host ""
}

# ------------------------------------------------------------------------------
# KOMPONEN TABEL & KARTU PANDUAN TERMINAL
# ------------------------------------------------------------------------------
function Show-GuideSection {
    param(
        [string]$Title,
        [string]$Color,
        [array]$Items,
        [string]$Col1Header = "Perintah / Syntax",
        [string]$Col2Header = "Fungsi & Keterangan"
    )

    $boxW = Get-TerminalWidth
    $col1W = 30
    $col2W = $boxW - $col1W - 7
    if ($col2W -lt 30) { $col2W = 30 }

    $topBorder = "  +" + ("-" * ($col1W + 2)) + "+" + ("-" * ($col2W + 2)) + "+"
    $midBorder = "  +" + ("=" * ($col1W + 2)) + "+" + ("=" * ($col2W + 2)) + "+"

    Write-Host ""
    Write-Host "  >> $Title" -ForegroundColor $Color
    Write-Host $topBorder -ForegroundColor DarkGray

    Write-Host "  | " -NoNewline -ForegroundColor DarkGray
    Write-Host ("{0,-$col1W}" -f $Col1Header) -NoNewline -ForegroundColor Yellow
    Write-Host " | " -NoNewline -ForegroundColor DarkGray
    Write-Host ("{0,-$col2W}" -f $Col2Header) -NoNewline -ForegroundColor Yellow
    Write-Host " |" -ForegroundColor DarkGray

    Write-Host $midBorder -ForegroundColor DarkGray

    foreach ($item in $Items) {
        $cmd  = [string]$item[0]
        $desc = [string]$item[1]

        $cmdLines  = @(Wrap-TextLines -Text $cmd  -MaxWidth $col1W)
        $descLines = @(Wrap-TextLines -Text $desc -MaxWidth $col2W)
        $maxLines  = [Math]::Max($cmdLines.Count, $descLines.Count)

        for ($i = 0; $i -lt $maxLines; $i++) {
            $cText = if ($i -lt $cmdLines.Count)  { [string]$cmdLines[$i] }  else { "" }
            $dText = if ($i -lt $descLines.Count) { [string]$descLines[$i] } else { "" }

            Write-Host "  | " -NoNewline -ForegroundColor DarkGray
            Write-Host ("{0,-$col1W}" -f $cText) -NoNewline -ForegroundColor Cyan
            Write-Host " | " -NoNewline -ForegroundColor DarkGray
            Write-Host ("{0,-$col2W}" -f $dText) -NoNewline -ForegroundColor White
            Write-Host " |" -ForegroundColor DarkGray
        }
    }

    Write-Host $topBorder -ForegroundColor DarkGray
}

function Show-PromptSection {
    param(
        [string]$Title,
        [string]$Color,
        [array]$Prompts
    )

    $boxW = Get-TerminalWidth
    $innerW = $boxW - 4

    $topBorder = "  +" + ("=" * ($innerW + 2)) + "+"
    $sepBorder = "  +" + ("-" * ($innerW + 2)) + "+"

    Write-Host ""
    Write-Host "  >> $Title" -ForegroundColor $Color
    Write-Host $topBorder -ForegroundColor DarkGray

    for ($idx = 0; $idx -lt $Prompts.Count; $idx++) {
        $entry = $Prompts[$idx]
        $badge = [string]$entry[0]
        $skill = [string]$entry[1]
        $text  = [string]$entry[2]

        $headerRight = "[Skill: $skill]"
        $padLen = [Math]::Max(1, $innerW - $badge.Length - $headerRight.Length)
        $spaces = " " * $padLen

        Write-Host "  | " -NoNewline -ForegroundColor DarkGray
        Write-Host $badge -NoNewline -ForegroundColor Yellow
        Write-Host $spaces -NoNewline
        Write-Host $headerRight -NoNewline -ForegroundColor Cyan
        Write-Host " |" -ForegroundColor DarkGray

        $wrapped = @(Wrap-TextLines -Text ("Prompt > `"$text`"") -MaxWidth $innerW)
        foreach ($line in $wrapped) {
            Write-Host "  | " -NoNewline -ForegroundColor DarkGray
            Write-Host ("{0,-$innerW}" -f [string]$line) -NoNewline -ForegroundColor Green
            Write-Host " |" -ForegroundColor DarkGray
        }

        if ($idx -lt ($Prompts.Count - 1)) {
            Write-Host $sepBorder -ForegroundColor DarkGray
        }
    }

    Write-Host $topBorder -ForegroundColor DarkGray
}

# ------------------------------------------------------------------------------
# FUNGSI SHORTCUT WORKFLOW MASTER (LINTER, INSTALLER & PIPELINE DATA/ML)
# ------------------------------------------------------------------------------
function install-agents {
    param([string]$Destination = ".")
    $source = "$script:WorkflowMasterRoot\AGENTS.md"
    if (Test-Path $source) {
        Copy-Item $source -Destination $Destination -Force
        Write-Host ""
        Write-Host "  [SUCCESS] AGENTS.md (16 Skills & 20 Rules) berhasil dipasang ke '$Destination'." -ForegroundColor Green
        Write-Host "  [INFO] AI Assistant kini otomatis mematuhi arketipe UI, KBBI, anti-emoji, & ML anti-leakage." -ForegroundColor Cyan
        Write-Host ""
    } else {
        Write-Error "Sumber berkas AGENTS.md tidak ditemukan di $source"
    }
}
Set-Alias init-agents install-agents

function update-skills {
    $installer = "$script:WorkflowMasterRoot\skills\install-skills.ps1"
    if (Test-Path $installer) {
        & $installer -Target $script:GlobalSkillsDir
    } else {
        Write-Error "Skrip install-skills.ps1 tidak ditemukan di $installer"
    }
}

function setup-git {
    $script = "$script:WorkflowMasterRoot\templates\git\setup-git-discipline.ps1"
    if (Test-Path $script) {
        & $script
    } else {
        Write-Error "Skrip setup-git tidak ditemukan di $script"
    }
}

function lint-ui {
    param([string]$Path = ".")
    & "$script:GlobalSkillsDir\distinctive-ui-design\scripts\ui-sloplint.ps1" -Path $Path
}

function lint-code {
    param([string]$Path = ".")
    & "$script:GlobalSkillsDir\clean-code-concise-docs\scripts\check-code-hygiene.ps1" -Path $Path
}

function lint-readme {
    param([string]$Path = "README.md")
    & "$script:GlobalSkillsDir\readme-github-sync\scripts\check-readme.ps1" -Path $Path
}

function scan-diff {
    & "$script:GlobalSkillsDir\diff-review\scripts\scan-diff.ps1"
}

function run-eda {
    param(
        [Parameter(Mandatory=$true)][string]$InputFile,
        [string]$GroupCol = "",
        [string]$OutputDir = "reports/eda"
    )
    $pyArgs = @("$script:GlobalSkillsDir\data-analysis-explorer\scripts\profile-dataset.py", "--input", $InputFile, "--output-dir", $OutputDir)
    if ($GroupCol) { $pyArgs += @("--group-col", $GroupCol) }
    python @pyArgs
}

function run-stat {
    param(
        [Parameter(Mandatory=$true)][string]$InputFile,
        [Parameter(Mandatory=$true)][string]$GroupCol,
        [Parameter(Mandatory=$true)][string]$ValueCols,
        [string]$OutputDir = "reports/stats"
    )
    python "$script:GlobalSkillsDir\data-science-workbench\scripts\stat-test.py" --input $InputFile --group-col $GroupCol --value-cols $ValueCols --output-dir $OutputDir
}

function run-ml {
    param(
        [Parameter(Mandatory=$true)][string]$InputFile,
        [Parameter(Mandatory=$true)][string]$TargetCol,
        [string]$SliceCol = "",
        [string]$Task = "auto",
        [string]$OutputDir = "artifacts/ml"
    )
    $pyArgs = @("$script:GlobalSkillsDir\ml-model-engineering\scripts\train-evaluate-baseline.py", "--input", $InputFile, "--target", $TargetCol, "--task", $Task, "--output-dir", $OutputDir)
    if ($SliceCol) { $pyArgs += @("--slice-col", $SliceCol) }
    python @pyArgs
}

function run-report {
    param(
        [Parameter(Mandatory=$true)][string]$InputMd,
        [string]$OutputHtml = "reports/executive_report.html",
        [string]$Title = "Laporan Evaluasi Teknis & Eksekutif",
        [string]$Subtitle = "Analisis Data, Uji Statistik, dan Evaluasi Model",
        [string]$Author = "Pranataa Labs"
    )
    python "$script:GlobalSkillsDir\professional-report-writer\scripts\build-html-report.py" --input $InputMd --output $OutputHtml --title $Title --subtitle $Subtitle --author $Author
}

# ------------------------------------------------------------------------------
# PERINTAH UTAMA `info` — PUSAT PANDUAN & KATALOG PROMPT AI
# ------------------------------------------------------------------------------
function info {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Topics
    )

    $topicStr = if ($Topics) { ($Topics -join " ").ToLower() } else { "" }
    $boxW = Get-TerminalWidth
    $innerW = $boxW - 2

    Clear-Host

    $topD = "  +" + ("=" * $innerW) + "+"
    $sepD = "  +" + ("-" * $innerW) + "+"
    $title1 = "  [NCCA] PUSAT PANDUAN TERMINAL & KATALOG PROMPT AI (WORKFLOW MASTER v2.2)"
    $title2 = "  16 Agent Skills | 8 Arketipe UI/UX | Data Analysis | Data Science | ML | Report"
    $filterLine = "  Filter: info prompt | info ui | info ml | info agent | info git | info folder | info file | info sys"

    Write-Host $topD -ForegroundColor Cyan
    Write-Host ("  |{0,-$innerW}|" -f $title1) -ForegroundColor Yellow
    Write-Host ("  |{0,-$innerW}|" -f $title2) -ForegroundColor White
    Write-Host $sepD -ForegroundColor DarkCyan
    Write-Host ("  |{0,-$innerW}|" -f $filterLine) -ForegroundColor Cyan
    Write-Host $topD -ForegroundColor Cyan

    $secPrompts = @(
        @(
            "[1] UI/UX Web & Aplikasi Berbasis Arketipe Domain",
            "distinctive-ui-design + shadcn-admin",
            "Buatkan aplikasi web [Toko Buku / Klinik / Kasir POS / Finansial]. Gunakan skill distinctive-ui-design dengan arketipe [editorial-serif / clinical-clean / industrial-ops / swiss-grid] untuk halaman pelanggan dan shadcn-admin-design-system komposisi [Command Split / Queue-First Triage / POS Terminal Grid / Analytical Workbench] untuk halaman admin, lalu validasi dengan ui-sloplint.ps1."
        ),
        @(
            "[2] Exploratory Data Analysis (EDA) & Deteksi Anomali",
            "data-analysis-explorer",
            "Analisis berkas data/dataset.csv menggunakan skill data-analysis-explorer dengan pengelompokan pada kolom [kategori]. Tampilkan profil skema 100% baris, persentase data hilang, pencilan (outlier IQR & MAD), serta pasangan korelasi terkuat."
        ),
        @(
            "[3] Uji Statistik & Hipotesis Ilmiah (Data Science)",
            "data-science-workbench",
            "Uji apakah terdapat perbedaan signifikan pada metrik [return_1y, sharpe_ratio] berdasarkan grup [kategori] di berkas data/dataset.csv menggunakan skill data-science-workbench lengkap dengan uji asumsi normalitas, ukuran efek (effect size), dan koreksi Holm-Bonferroni."
        ),
        @(
            "[4] Pembuatan & Evaluasi Model Machine Learning",
            "ml-model-engineering",
            "Bangun model machine learning dari data/dataset.csv dengan target [kolom_target] dan slice analysis pada kolom [kategori] menggunakan skill ml-model-engineering. Terapkan Pipeline bebas data leakage, bandingkan model Baseline terhadap Gradient Boosting, dan laporkan titik buta model."
        ),
        @(
            "[5] Laporan Eksekutif Profesional (Siap Cetak PDF A4)",
            "professional-report-writer",
            "Buatkan laporan eksekutif berstruktur Piramida Minto dari hasil analisis data, uji statistik, dan evaluasi model ML tadi menggunakan skill professional-report-writer dalam bahasa Indonesia baku KBBI, lengkap dengan kartu KPI dan rumus KaTeX, lalu ekspor ke HTML siap cetak PDF A4."
        ),
        @(
            "[6] Audit Bahasa Baku KBBI, Anti-Emoji & Keamanan Kode",
            "clean-code-concise-docs + security-audit",
            "Periksa seluruh kode, komentar, log, dan README pada proyek ini menggunakan skill clean-code-concise-docs (check-code-hygiene.ps1) dan ui-sloplint.ps1. Pastikan nol emoji, 100% kata baku KBBI, dan jalankan audit keamanan security-audit sebelum commit."
        )
    )

    $secArchetypes = @(
        @("swiss-grid", "Finansial, Kuantitatif, Reksa Dana | Plus Jakarta Sans + JetBrains Mono"),
        @("editorial-serif", "Toko Buku, LMS, Riset, Publikasi   | Fraunces / Newsreader + Source Sans 3"),
        @("warm-craft", "Kafe, Kuliner, Kerajinan, Hotel    | Instrument Serif + DM Sans"),
        @("clinical-clean", "Klinik, Rumah Sakit, Lab, Farmasi  | Figtree + IBM Plex Mono"),
        @("industrial-ops", "Kasir POS, Gudang, Logistik, Pabrik| Space Grotesk + IBM Plex Sans"),
        @("sovereign-civic", "Layanan Publik, Regulasi, Hukum    | Public Sans + Source Serif 4"),
        @("technical-dark", "DevTools, MLOps, Keamanan Siber    | Geist + Geist Mono"),
        @("neo-brutal", "Studio Kreatif, Agensi, Acara      | Syne + Space Mono"),
        @("Admin: Command Split", "Komposisi Backoffice CRUD & Operasional Umum (Tabel + Drawer Kanan)"),
        @("Admin: Queue-First", "Komposisi Antrean Klinik, Tiket, Moderasi & Persetujuan Langsung"),
        @("Admin: Analytical", "Komposisi Analitik, Keuangan & Pemantauan Model ML"),
        @("Admin: POS Terminal", "Komposisi Kasir, Gudang & Pemindaian Barcode Sentuh (48x48px)")
    )

    $secAgents = @(
        @("install-agents", "Pasang AGENTS.md (16 Skills & 20 Rules) ke folder proyek aktif"),
        @("update-skills", "Perbarui seluruh 16 skill ke direktori global ~/.gemini/config/skills"),
        @("lint-ui [path]", "Cek kualitas UI/UX anti-slop (gradien AI, tabular-nums, transition-all)"),
        @("lint-code [path]", "Cek kebersihan kode & README (bebas emoji, kata baku KBBI, anti-klise AI)"),
        @("lint-readme [path]", "Validasi README.md (baris topik GitHub, rumus LaTeX aman, gambar)"),
        @("scan-diff", "Pindai git diff terhadap rahasia bocor, API key, dan data pribadi (PII)"),
        @("run-eda <csv> [grup]", "Jalankan profiling dataset 100% baris & deteksi outlier (profile-dataset.py)"),
        @("run-stat <csv> <grup> <kol>", "Jalankan uji hipotesis statistik + effect size (stat-test.py)"),
        @("run-ml <csv> <target> [slice]", "Latih model ML baseline vs kandidat bebas data leakage (train-evaluate-baseline.py)"),
        @("run-report <md> [html]", "Kompilasi laporan Markdown ke HTML eksekutif siap cetak PDF A4"),
        @("setup-git", "Pasang commitlint, husky, dan template commit ke repositori aktif")
    )

    $secFolder = @(
        @("pwd", "Lihat lokasi direktori aktif saat ini (Get-Location)"),
        @("ls  (atau dir)", "Lihat daftar berkas dan folder di direktori saat ini"),
        @("ls -Force", "Lihat seluruh isi termasuk berkas tersembunyi (hidden)"),
        @("ls -Recurse", "Lihat seluruh isi folder beserta sub-folder di dalamnya"),
        @("tree /F", "Tampilkan struktur pohon direktori dan berkas secara visual"),
        @("mkdir <nama>", "Buat folder baru (contoh: mkdir ProyekBaru)"),
        @("mkdir f1, f2, f3", "Buat beberapa folder sekaligus dalam satu perintah"),
        @("cd <nama_folder>", "Masuk ke dalam folder tujuan"),
        @("cd ..  /  cd ..\..", "Naik 1 atau 2 tingkat ke folder induk"),
        @("cd ~", "Kembali langsung ke direktori Home pengguna"),
        @("start .  (explorer .)", "Buka folder aktif di File Explorer Windows"),
        @("code .", "Buka folder aktif di Visual Studio Code")
    )

    $secFile = @(
        @("ni <nama_file>", "Buat berkas kosong baru (contoh: ni app.py)"),
        @("cat <nama_file>", "Baca seluruh isi berkas teks di terminal"),
        @("gc <file> -Head 15", "Lihat 15 baris pertama berkas teks"),
        @("gc <file> -Tail 20", "Lihat 20 baris terakhir berkas teks"),
        @("echo 'teks' > file.txt", "Tulis atau timpa teks ke dalam berkas"),
        @("echo 'teks' >> file.txt", "Tambahkan teks ke akhir berkas"),
        @("cp <asal> <tujuan>", "Salin berkas (contoh: cp data.json backup.json)"),
        @("cp -r <folder> <tujuan>", "Salin folder beserta seluruh isinya secara rekursif"),
        @("mv <lama> <baru>", "Pindahkan atau ubah nama berkas/folder"),
        @("rm <nama_file>", "Hapus berkas tertentu"),
        @("rm -r -Force <folder>", "Hapus folder beserta seluruh isinya secara permanen")
    )

    $secSearch = @(
        @("sls 'kata' <file>", "Cari teks di dalam berkas (Select-String / grep)"),
        @("sls 'kata' *.py", "Cari teks di seluruh berkas .py pada folder aktif"),
        @("gci -r -Filter *.py", "Cari seluruh berkas .py di semua sub-folder"),
        @("Test-Path <path>", "Periksa keberadaan berkas/folder (True / False)"),
        @("Get-Command <nama>", "Lihat lokasi program dari suatu perintah CLI")
    )

    $secGit = @(
        @("git status", "Lihat status perubahan berkas pada repositori Git"),
        @("git add -A", "Tambahkan seluruh perubahan berkas ke staging area"),
        @("git commit -m 'pesan'", "Simpan commit perubahan ke riwayat lokal"),
        @("git pull", "Ambil dan gabungkan pembaruan dari remote repository"),
        @("git push", "Unggah commit lokal ke GitHub"),
        @("git log --oneline -10", "Lihat 10 riwayat commit terakhir secara ringkas"),
        @("git branch", "Lihat daftar cabang (branch) repositori")
    )

    $secSys = @(
        @("cls  (atau clear)", "Bersihkan layar terminal"),
        @("ps   (Get-Process)", "Tampilkan daftar proses aplikasi yang berjalan"),
        @("ps | sls 'nama'", "Saring proses aplikasi tertentu yang sedang aktif"),
        @("kill -Name <proses>", "Hentikan paksa proses tertentu (Stop-Process)"),
        @("history", "Lihat daftar riwayat perintah yang pernah dijalankan"),
        @("NCCA", "Tampilkan banner utama terminal NCCA"),
        @("exit", "Tutup sesi terminal aktif")
    )

    $secShortcut = @(
        @("Tab", "Auto-complete nama berkas, folder, atau perintah"),
        @("Ctrl + C", "Batalkan atau hentikan perintah yang sedang berjalan"),
        @("Ctrl + L", "Bersihkan layar terminal secara instan"),
        @("Panah Atas / Bawah", "Telusuri riwayat perintah sebelumnya"),
        @("Ctrl + R", "Cari riwayat perintah secara interaktif"),
        @("Ctrl + V / Klik Kanan", "Tempelkan (paste) teks ke terminal")
    )

    $secSysInfo = @(
        @("Nama Perangkat", "$env:COMPUTERNAME (pranataa-005)"),
        @("Prosesor", "11th Gen Intel(R) Core(TM) i7-1165G7"),
        @("Memori (RAM)", "16.0 GB (15.7 GB usable)"),
        @("Grafis", "Intel(R) Iris(R) Xe Graphics"),
        @("Sistem Operasi", "Windows 11 Home 64-bit"),
        @("PowerShell Host", "ConsoleHost (Windows Terminal / SF Mono)")
    )

    $showAll = ($topicStr -eq "")

    if ($showAll -or $topicStr -match "prompt|ai|contoh|chat|cara") {
        Show-PromptSection "[0] CONTOH PROMPT AI SIAP PAKAI (SALIN & TEMPEL KE CHAT AI)" "Green" $secPrompts
    }
    if ($showAll -or $topicStr -match "ui|ux|design|arketipe|archetype|prompt") {
        Show-GuideSection "[1] 8 ARKETIPE VISUAL UI/UX & 4 KOMPOSISI ADMIN BACKOFFICE" "Magenta" $secArchetypes "Nama Arketipe / Mode" "Domain Penggunaan & Pasangan Font"
    }
    if ($showAll -or $topicStr -match "agent|skill|workflow|master|ml|data|lint|report") {
        Show-GuideSection "[2] PERINTAH CEPAT WORKFLOW MASTER (LINTER, DATA, ML & LAPORAN)" "Cyan" $secAgents "Perintah Terminal" "Fungsi Eksekusi"
    }
    if ($showAll -or $topicStr -match "folder|dir") {
        Show-GuideSection "[3] PENGELOLAAN FOLDER & DIREKTORI" "Green" $secFolder
    }
    if ($showAll -or $topicStr -match "file|berkas") {
        Show-GuideSection "[4] PENGELOLAAN BERKAS (FILE)" "Green" $secFile
    }
    if ($showAll -or $topicStr -match "search|cari|find") {
        Show-GuideSection "[5] PENCARIAN & INSPEKSI KONTEN" "Green" $secSearch
    }
    if ($showAll -or $topicStr -match "git|repo") {
        Show-GuideSection "[6] GIT & KONTROL VERSI" "Green" $secGit
    }
    if ($showAll -or $topicStr -match "sys|sistem|proc") {
        Show-GuideSection "[7] MANAJEMEN SISTEM & PROSES" "Green" $secSys
    }
    if ($showAll -or $topicStr -match "short|key|tips") {
        Show-GuideSection "[8] SHORTCUT & PRODUKTIVITAS TERMINAL" "Green" $secShortcut
    }
    if ($topicStr -match "spec|hardware") {
        Show-GuideSection "[9] SPESIFIKASI PERANGKAT" "Cyan" $secSysInfo "Komponen" "Spesifikasi"
    }

    Write-Host ""
    Write-Host ("  " + ("-" * $boxW)) -ForegroundColor DarkGray
    Write-Host "  [TIPS] Ketik " -NoNewline -ForegroundColor Gray
    Write-Host "info prompt" -NoNewline -ForegroundColor Green
    Write-Host " (contoh prompt AI), " -NoNewline -ForegroundColor Gray
    Write-Host "info ui" -NoNewline -ForegroundColor Magenta
    Write-Host " (8 arketipe desain), " -NoNewline -ForegroundColor Gray
    Write-Host "info ml" -NoNewline -ForegroundColor Cyan
    Write-Host " (CLI Data/ML), atau " -NoNewline -ForegroundColor Gray
    Write-Host "info git" -NoNewline -ForegroundColor Yellow
    Write-Host "." -ForegroundColor Gray
    Write-Host ""
}
