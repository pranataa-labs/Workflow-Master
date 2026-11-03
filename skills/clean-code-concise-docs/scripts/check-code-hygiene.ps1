<#
.SYNOPSIS
  Lints source code and markdown files for Rule 20 compliance:
  1. Emoji characters in code comments, log statements, or markdown headings.
  2. Non-standard Indonesian slang/abbreviations (yg, tdk, utk, bgt, gimana, etc.).
  3. Non-standard KBBI technical loanwords (analisa, resiko, otentikasi, merubah, praktek, etc.).
  4. AI writing cliches (delve into, testament to, not only... but also, di era digital).
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File check-code-hygiene.ps1 -Path .
#>
param(
    [string]$Path = ".",
    [switch]$StrictWarnings
)

$ErrorActionPreference = "Continue"

if (-not (Test-Path $Path)) {
    Write-Host "[ERROR] Path not found: $Path"
    exit 2
}

$errors = 0
$warns = 0

function Report([string]$level, [string]$file, [int]$line, [string]$msg) {
    if ($level -eq "ERROR") { $script:errors++ } else { $script:warns++ }
    Write-Host ("[{0}] {1}:{2} {3}" -f $level, $file, $line, $msg)
}

$emojiRegex = '[\uD800-\uDBFF][\uDC00-\uDFFF]|[\u2600-\u27BF\u2B00-\u2BFF]'
$slangRegex = '(?i)\b(yg|tdk|utk|dgn|krn|bwt|kyk|bgt|blm|udh|udah|gimana|kalo|gak|nggak|bikin)\b'
$nonBakuMap = @(
    @{ re = '(?i)\b(menganalisa|analisa)\b'; fix = 'analisis / menganalisis' },
    @{ re = '(?i)\b(beresiko|resiko)\b'; fix = 'risiko / berisiko' },
    @{ re = '(?i)\b(aktifitas|produktifitas|efektifitas)\b'; fix = 'aktivitas / produktivitas / efektivitas' },
    @{ re = '(?i)\b(mempraktekkan|praktek)\b'; fix = 'praktik / mempraktikkan' },
    @{ re = '(?i)\bsistim\b'; fix = 'sistem' },
    @{ re = '(?i)\btehnik\b'; fix = 'teknik' },
    @{ re = '(?i)\botentikasi\b'; fix = 'autentikasi' },
    @{ re = '(?i)\b(merubah|dirubah)\b'; fix = 'mengubah / diubah' },
    @{ re = '(?i)\bstandarisasi\b'; fix = 'standardisasi' },
    @{ re = '(?i)\bsilahkan\b'; fix = 'silakan' },
    @{ re = '(?i)\b(mendiagnosa|diagnosa)\b'; fix = 'diagnosis / mendiagnosis' },
    @{ re = '(?i)\bhipotesa\b'; fix = 'hipotesis' },
    @{ re = '(?i)\bprosentase\b'; fix = 'persentase' },
    @{ re = '(?i)\bketrampilan\b'; fix = 'keterampilan' },
    @{ re = '(?i)\bsekedar\b'; fix = 'sekadar' }
)
$aiTropeRegex = '(?i)\b(delve into|testament to|in today''s fast-paced|in the realm of|di era digital yang serba cepat|bukan hanya sekadar)\b'

$excludePattern = '(\\.git\\|\\node_modules\\|\\vendor\\|\\dist\\|\\build\\|\\\.venv\\|\\venv\\|\\__pycache__\\|check-code-hygiene\.ps1$|clean-code-concise-docs\\SKILL\.md$|19-anti-slop-humanized-ui-design-rules\.md$|20-concise-code-clean-logs-and-docs-rules\.md$)'

$item = Get-Item $Path
$baseDir = if ($item.PSIsContainer) { $item.FullName } else { $item.DirectoryName }
$files = if ($item.PSIsContainer) {
    Get-ChildItem -Path $Path -Recurse -File -Include *.py,*.ts,*.tsx,*.js,*.jsx,*.php,*.go,*.ps1,*.sh,*.md |
        Where-Object { $_.FullName -notmatch $excludePattern }
} else {
    @($item)
}

foreach ($f in $files) {
    if ($f.Length -gt 2MB) { continue }
    $rel = $f.FullName
    if ($rel.StartsWith($baseDir)) { $rel = $rel.Substring($baseDir.Length).TrimStart('\', '/') }
    if (-not $rel) { $rel = $f.Name }

    $ext = $f.Extension.ToLowerInvariant()
    $lines = [System.IO.File]::ReadAllLines($f.FullName, [System.Text.Encoding]::UTF8)
    $inFence = $false

    for ($i = 0; $i -lt $lines.Length; $i++) {
        $n = $i + 1
        $line = $lines[$i]

        if ($ext -eq ".md") {
            if ($line -match '^\s*(```+|~~~+)') { $inFence = -not $inFence; continue }
            if ($inFence) { continue }
            if ($line -match '^#{1,6}\s+' -and $line -match $emojiRegex) {
                Report "ERROR" $rel $n "Emoji in markdown heading violates Rule 20."
            }
            $prose = [regex]::Replace($line, '`[^`]+`', '')
            if ($prose -match $slangRegex) {
                Report "ERROR" $rel $n "Informal abbreviation '$($Matches[1])' in documentation; use formal standard language."
            }
            foreach ($nb in $nonBakuMap) {
                if ($prose -match $nb.re) {
                    Report "WARN" $rel $n "Non-standard KBBI word '$($Matches[0])'; use '$($nb.fix)'."
                }
            }
            if ($prose -match $aiTropeRegex) {
                Report "WARN" $rel $n "AI rhetoric cliche detected: '$($Matches[0])'."
            }
        } else {
            # Source code: check comments and log statements
            $isComment = $line -match '^\s*(//|#|--|/\*|\*)' -or $line -match '\s(//|#)\s+\S'
            $isLog = $line -match '\b(print|console\.(log|info|warn|error)|Write-Host|Log::(info|warning|error|debug)|logger\.(info|warning|error|debug))\b'

            if (($isComment -or $isLog) -and ($line -match $emojiRegex)) {
                $target = if ($isLog) { "log statement" } else { "code comment" }
                Report "ERROR" $rel $n "Emoji in $target violates Rule 20."
            }
            if ($isComment -or $isLog) {
                if ($line -match $slangRegex) {
                    Report "ERROR" $rel $n "Informal abbreviation '$($Matches[1])' in comment/log; use formal language."
                }
                foreach ($nb in $nonBakuMap) {
                    if ($line -match $nb.re) {
                        Report "WARN" $rel $n "Non-standard KBBI word '$($Matches[0])' in comment/log; use '$($nb.fix)'."
                    }
                }
            }
        }
    }
}

Write-Host ""
Write-Host ("[INFO] Code hygiene scan: {0} file(s), {1} error(s), {2} warning(s)" -f $files.Count, $errors, $warns)
if ($errors -gt 0 -or ($StrictWarnings -and $warns -gt 0)) {
    Write-Host "[ERROR] Code hygiene check failed."
    exit 1
}
Write-Host "[SUCCESS] Code and documentation hygiene passed."
exit 0
