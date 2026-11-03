<#
.SYNOPSIS
  Scans frontend source files (.tsx, .jsx, .vue, .blade.php, .html, .css) for common
  AI UI slop anti-patterns defined in Rule 19 and distinctive-ui-design:
  1. Banned purple/violet/indigo-to-blue neon gradients.
  2. transition-all / transition: all (causes layout thrashing).
  3. 100vw usage that triggers horizontal scrollbars.
  4. Emoji used inside UI markup headings/buttons.
  5. Missing overflow-x: clip on root stylesheet/layout.
  6. Missing tabular-nums when numeric KPI/table formatting is present.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File ui-sloplint.ps1 -Path ./src
#>
param(
    [string]$Path = "."
)

$ErrorActionPreference = "Continue"

if (-not (Test-Path $Path)) {
    Write-Host "[ERROR] Path not found: $Path"
    exit 2
}

$fails = 0
$reflexes = 0

function Flag([string]$tier, [string]$file, [int]$line, [string]$msg) {
    if ($tier -eq "FAIL") { $script:fails++ } else { $script:reflexes++ }
    Write-Host ("[{0}] {1}:{2} {3}" -f $tier, $file, $line, $msg)
}

$exclude = '(\\.git\\|\\node_modules\\|\\vendor\\|\\dist\\|\\build\\|\\\.next\\|ui-sloplint\.ps1$)'
$item = Get-Item $Path
$baseDir = if ($item.PSIsContainer) { $item.FullName } else { $item.DirectoryName }
$files = if ($item.PSIsContainer) {
    Get-ChildItem -Path $Path -Recurse -File -Include *.tsx,*.jsx,*.vue,*.php,*.html,*.css |
        Where-Object { $_.FullName -notmatch $exclude }
} else {
    @($item)
}

if (-not $files -or $files.Count -eq 0) {
    Write-Host "[INFO] No frontend UI files found in $Path."
    exit 0
}

$hasOverflowClip = $false
$hasTabularNums = $false
$hasTableOrKpi = $false
$emojiRegex = '[\uD800-\uDBFF][\uDC00-\uDFFF]|[\u2600-\u27BF\u2B00-\u2BFF]'

foreach ($f in $files) {
    if ($f.Length -gt 2MB) { continue }
    $rel = $f.FullName
    if ($rel.StartsWith($baseDir)) { $rel = $rel.Substring($baseDir.Length).TrimStart('\', '/') }
    if (-not $rel) { $rel = $f.Name }

    $lines = [System.IO.File]::ReadAllLines($f.FullName, [System.Text.Encoding]::UTF8)
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $n = $i + 1
        $line = $lines[$i]

        if ($line -match 'overflow-x\s*:\s*clip|\boverflow-x-clip\b') { $hasOverflowClip = $true }
        if ($line -match 'tabular-nums') { $hasTabularNums = $true }
        if ($line -match '<table\b|\bkpi\b|\bmetric\b') { $hasTableOrKpi = $true }

        # 1. Banned neon purple/violet/indigo gradients (Craft Floor #6)
        if ($line -match '\bfrom-(purple|violet|indigo|fuchsia)-[4567]00\b.*\bto-(blue|indigo|purple|pink|violet)-[4567]00\b') {
            Flag "FAIL" $rel $n "Banned AI neon purple/indigo gradient detected. Use domain-authentic OKLCH tokens."
        }

        # 2. transition-all / transition: all (Craft Floor #5)
        if ($line -match '\btransition-all\b|transition\s*:\s*all\b') {
            Flag "REFLEX" $rel $n "Avoid 'transition-all'; transition specific properties (color, background-color, border-color, opacity, transform)."
        }

        # 3. w-screen / 100vw horizontal overflow hazard (Craft Floor #4)
        if ($line -match '\bw-screen\b|width\s*:\s*100vw\b') {
            Flag "REFLEX" $rel $n "Avoid '100vw' / 'w-screen' (causes horizontal scrollbar when vertical scrollbar is visible); use 'w-full'."
        }

        # 4. Ambient blur blobs (Rule 19 #5)
        if ($line -match '\bblur-3xl\b.*\brounded-full\b.*\b(bg-purple|bg-indigo|bg-violet|bg-blue|bg-pink)') {
            Flag "FAIL" $rel $n "Banned floating ambient blur blob detected."
        }

        # 5. Emoji inside UI markup headings or buttons (Craft Floor #9)
        if ($line -match '<(h[1-6]|button|a|span|label)\b[^>]*>.*' -and $line -match $emojiRegex) {
            Flag "FAIL" $rel $n "Emoji inside UI element; use consistent SVG icons (e.g. Lucide) instead."
        }
    }
}

if (-not $hasOverflowClip) {
    Write-Host "[WARN] No 'overflow-x: clip' or 'overflow-x-clip' found across scanned files. Add it to html, body (Rule 19)."
    $reflexes++
}
if ($hasTableOrKpi -and -not $hasTabularNums) {
    Write-Host "[WARN] Tables or KPI metrics detected without 'tabular-nums'. Add 'tabular-nums' to numeric columns and metrics."
    $reflexes++
}

Write-Host ""
Write-Host ("[INFO] UI sloplint scanned {0} file(s): {1} FAIL, {2} REFLEX/WARN" -f $files.Count, $fails, $reflexes)
if ($fails -gt 0) {
    Write-Host "[ERROR] UI sloplint failed. Fix all [FAIL] items before handoff."
    exit 1
}
Write-Host "[SUCCESS] UI sloplint passed with 0 hard failures."
exit 0
