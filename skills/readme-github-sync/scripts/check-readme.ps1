<#
.SYNOPSIS
  Validates a README.md against Workflow Master documentation rules (11, 11.1, 18, 20).
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File check-readme.ps1 -Path README.md
#>
param(
    [string]$Path = "README.md"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $Path)) {
    Write-Host "[ERROR] File not found: $Path"
    exit 2
}

$baseDir = Split-Path -Parent (Resolve-Path $Path)
$lines = [System.IO.File]::ReadAllLines((Resolve-Path $Path), [System.Text.Encoding]::UTF8)
$errors = 0
$warnings = 0

function Report([string]$level, [int]$line, [string]$msg) {
    if ($level -eq "ERROR") { $script:errors++ } else { $script:warnings++ }
    if ($line -gt 0) { Write-Host ("[{0}] L{1}: {2}" -f $level, $line, $msg) }
    else { Write-Host ("[{0}] {1}" -f $level, $msg) }
}

# Track fenced code blocks so their content is not linted as prose.
$inFence = $false
$fenceLang = ""
$h1Line = 0
$topicLine = 0
$topicCount = 0

for ($i = 0; $i -lt $lines.Length; $i++) {
    $n = $i + 1
    $line = $lines[$i]

    if ($line -match '^\s*(```+|~~~+)\s*([A-Za-z0-9_-]*)') {
        if (-not $inFence) { $inFence = $true; $fenceLang = $Matches[2] }
        else { $inFence = $false; $fenceLang = "" }
        continue
    }
    if ($inFence) { continue }

    # Headings
    if ($line -match '^(#{1,6})\s+(.*)$') {
        if ($Matches[1].Length -eq 1 -and $h1Line -eq 0) { $h1Line = $n }
        $text = $Matches[2]
        # Emoji: surrogate pairs (most pictographs) or Misc Symbols / Dingbats block.
        if ($text -match '[\uD800-\uDBFF][\uDC00-\uDFFF]|[\u2600-\u27BF\u2B00-\u2BFF]') {
            Report "ERROR" $n "Emoji in heading violates Rule 20: '$text'"
        }
    }

    # Topics line
    $topicMatches = [regex]::Matches($line, 'https://github\.com/topics/([a-z0-9-]+)')
    if ($topicMatches.Count -gt 0 -and $topicLine -eq 0) {
        $topicLine = $n
        $topicCount = $topicMatches.Count
    }

    # Display math with $$ breaks on GitHub when it contains \\ or &.
    if ($line -match '\$\$') {
        Report "ERROR" $n 'Use a fenced ```math block instead of $$ for display math.'
    }
    if ($line -match '\\begin\{(cases|aligned|align|matrix|pmatrix|bmatrix|array)\}') {
        Report "ERROR" $n 'LaTeX environment outside a ```math block will break on GitHub.'
    }
    if ($line -match '\\mathbf\{\\text\{') {
        Report "WARN" $n 'Replace \mathbf{\text{...}} with \textbf{...}.'
    }

    # Local images must exist.
    $imgRefs = @()
    foreach ($m in [regex]::Matches($line, '!\[[^\]]*\]\(([^)\s]+)')) { $imgRefs += $m.Groups[1].Value }
    foreach ($m in [regex]::Matches($line, '<img[^>]+src="([^"]+)"')) { $imgRefs += $m.Groups[1].Value }
    foreach ($ref in $imgRefs) {
        if ($ref -match '^(https?:|data:)') {
            if ($ref -match 'github-readme-stats\.vercel\.app') {
                Report "WARN" $n "Public github-readme-stats instance is often rate-limited; self-host or use a GitHub Action."
            }
            continue
        }
        $clean = ($ref -split '[?#]')[0]
        $full = Join-Path $baseDir $clean
        if (-not (Test-Path $full)) { Report "ERROR" $n "Image not found on disk: $ref" }
    }
    foreach ($m in [regex]::Matches($line, '!\[\]\(')) {
        Report "WARN" $n "Image without alt text."
    }
}

if ($h1Line -eq 0) { Report "ERROR" 0 "Missing H1 title." }

if ($topicLine -eq 0) {
    Report "ERROR" 0 "Missing topics line (Rule 11.1). Add 5-10 links to https://github.com/topics/<tag> below the title."
} else {
    if ($h1Line -gt 0 -and ($topicLine - $h1Line) -gt 12) {
        Report "WARN" $topicLine "Topics line should sit directly below the title/subtitle."
    }
    if ($topicCount -lt 5 -or $topicCount -gt 10) {
        Report "WARN" $topicLine "Topics line has $topicCount tags; expected 5-10."
    }
}

Write-Host ""
Write-Host ("[INFO] {0}: {1} error(s), {2} warning(s)" -f $Path, $errors, $warnings)
if ($errors -gt 0) { exit 1 }
Write-Host "[SUCCESS] README passed validation."
exit 0
