<#
.SYNOPSIS
  Scans added lines of a git diff for secrets, PII, debug leftovers and risky files.
.PARAMETER Base
  Compare HEAD against this ref (e.g. main) instead of the staged changes.
.PARAMETER All
  Scan every tracked file instead of a diff.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scan-diff.ps1
  powershell -ExecutionPolicy Bypass -File scan-diff.ps1 -Base main
#>
param(
    [string]$Base = "",
    [switch]$All,
    [int]$MaxFileMB = 50
)

# Continue: native git/gh stderr must not abort PS 5.1; exit codes are checked explicitly.
$ErrorActionPreference = "Continue"
$blocks = 0
$warns = 0

function Hit([string]$level, [string]$file, [int]$line, [string]$msg) {
    if ($level -eq "BLOCK") { $script:blocks++ } else { $script:warns++ }
    Write-Host ("[{0}] {1}:{2} {3}" -f $level, $file, $line, $msg)
}

$blockRules = @(
    @{ re = '-----BEGIN (RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY-----'; msg = "Private key" },
    @{ re = 'gh[pousr]_[A-Za-z0-9]{36,}'; msg = "GitHub token" },
    @{ re = 'github_pat_[A-Za-z0-9_]{40,}'; msg = "GitHub fine-grained token" },
    @{ re = 'sk-(proj-)?[A-Za-z0-9_-]{32,}'; msg = "OpenAI-style secret key" },
    @{ re = 'sk-ant-[A-Za-z0-9_-]{32,}'; msg = "Anthropic API key" },
    @{ re = 'AIza[0-9A-Za-z_-]{35}'; msg = "Google API key" },
    @{ re = 'AKIA[0-9A-Z]{16}'; msg = "AWS access key id" },
    @{ re = 'xox[baprs]-[A-Za-z0-9-]{10,}'; msg = "Slack token" },
    @{ re = '(?i)(api[_-]?key|secret|access[_-]?token|auth[_-]?token|client[_-]?secret|db[_-]?password)\s*[:=]\s*[''"][A-Za-z0-9_\-\/+=]{16,}[''"]'; msg = "Hardcoded credential assignment" },
    @{ re = '(?i)(mysql|postgres(ql)?|mongodb(\+srv)?|redis)://[^:\s]+:[^@\s]{4,}@'; msg = "Connection string with password" }
)

$warnRules = @(
    @{ re = '\bconsole\.(log|debug)\('; msg = "console.log left in code" },
    @{ re = '\b(dd|dump|var_dump|print_r)\('; msg = "PHP debug helper" },
    @{ re = '^\s*debugger;?\s*$'; msg = "debugger statement" },
    @{ re = '\bbreakpoint\(\)|\bpdb\.set_trace\('; msg = "Python breakpoint" },
    @{ re = '(?i)value\s*=\s*[''"](password123|admin@example\.com|user@example\.com|secret|12345678)[''"]'; msg = "Pre-filled demo credential in form (Rule 18)" },
    @{ re = '(?<!\d)\d{16}(?!\d)'; msg = "Possible NIK or card number (16 digits)" },
    @{ re = '(?<![\d+])(\+62|62|0)8[1-9]\d{7,10}(?!\d)'; msg = "Possible Indonesian phone number" },
    @{ re = '(?i)\b(TODO|FIXME|HACK)\b'; msg = "Unresolved TODO/FIXME" }
)

$skipFile = '(?i)(\.lock$|package-lock\.json$|yarn\.lock$|pnpm-lock\.yaml$|composer\.lock$|\.min\.(js|css)$|\.svg$|scan-diff\.ps1$)'
$blockedFiles = '(?i)(^|/)\.env(\.(?!example$)[^/]+)?$|(^|/)(id_rsa|id_ed25519)$|\.(pem|p12|pfx|keystore)$|(^|/)credentials\.json$'

# Collect file list and added lines.
if ($All) {
    $files = git ls-files
    $mode = "all tracked files"
} elseif ($Base) {
    $files = git diff --name-only --diff-filter=ACMR "$Base...HEAD"
    $mode = "diff $Base...HEAD"
} else {
    $files = git diff --cached --name-only --diff-filter=ACMR
    $mode = "staged changes"
}
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] git command failed. Run inside a git repository."; exit 2 }

Write-Host "[INFO] Scanning $mode"
if (-not $files) { Write-Host "[INFO] Nothing to scan."; exit 0 }

foreach ($f in $files) {
    if ($f -match $blockedFiles) { Hit "BLOCK" $f 0 "Sensitive file must not be committed"; continue }
    if (Test-Path $f) {
        $size = (Get-Item $f).Length / 1MB
        if ($size -gt $MaxFileMB) { Hit "BLOCK" $f 0 ("File is {0:N1} MB (limit {1} MB); use Git LFS" -f $size, $MaxFileMB) }
    }
}

# Build list of (file, lineNo, text) for added content.
$added = New-Object System.Collections.Generic.List[object]
if ($All) {
    foreach ($f in $files) {
        if ($f -match $skipFile -or -not (Test-Path $f)) { continue }
        if ((Get-Item $f).Length -gt 2MB) { continue }
        $n = 0
        foreach ($l in [System.IO.File]::ReadLines((Resolve-Path $f))) {
            $n++
            $added.Add(@($f, $n, $l))
        }
    }
} else {
    if ($Base) { $diff = git diff -U0 --diff-filter=ACMR "$Base...HEAD" }
    else { $diff = git diff --cached -U0 --diff-filter=ACMR }
    $cur = ""; $ln = 0
    foreach ($l in $diff) {
        if ($l -match '^\+\+\+ b/(.+)$') { $cur = $Matches[1]; continue }
        if ($l -match '^@@ -\d+(,\d+)? \+(\d+)') { $ln = [int]$Matches[2]; continue }
        if ($l.StartsWith("+") -and -not $l.StartsWith("+++")) {
            if ($cur -notmatch $skipFile) { $added.Add(@($cur, $ln, $l.Substring(1))) }
            $ln++
        }
    }
}

foreach ($item in $added) {
    $file = $item[0]; $n = $item[1]; $text = $item[2]
    if ($text.Length -gt 1000) { continue }
    foreach ($r in $blockRules) {
        if ($text -match $r.re) { Hit "BLOCK" $file $n $r.msg }
    }
    foreach ($r in $warnRules) {
        if ($text -match $r.re) { Hit "WARN" $file $n $r.msg }
    }
}

Write-Host ""
Write-Host ("[INFO] Result: {0} block(s), {1} warning(s)" -f $blocks, $warns)
if ($blocks -gt 0) {
    Write-Host "[ERROR] Blocking findings present. Do not commit."
    exit 1
}
Write-Host "[SUCCESS] No blocking findings."
exit 0
