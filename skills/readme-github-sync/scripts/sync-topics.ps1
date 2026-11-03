<#
.SYNOPSIS
  Reads GitHub topic links from README.md and applies them to the repository (Rule 11.1).
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File sync-topics.ps1 -Path README.md
  powershell -ExecutionPolicy Bypass -File sync-topics.ps1 -Repo owner/name -DryRun
#>
param(
    [string]$Path = "README.md",
    [string]$Repo = "",
    [switch]$DryRun
)

# Continue: native git/gh stderr must not abort PS 5.1; exit codes are checked explicitly.
$ErrorActionPreference = "Continue"

if (-not (Test-Path $Path)) { Write-Host "[ERROR] File not found: $Path"; exit 2 }

$content = [System.IO.File]::ReadAllText((Resolve-Path $Path), [System.Text.Encoding]::UTF8)
$topics = [regex]::Matches($content, 'https://github\.com/topics/([a-z0-9-]+)') |
    ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique

if (-not $topics -or $topics.Count -eq 0) {
    Write-Host "[ERROR] No topic links found in $Path."
    exit 1
}
if ($topics.Count -gt 20) {
    Write-Host "[ERROR] GitHub allows at most 20 topics; found $($topics.Count)."
    exit 1
}

if (-not $Repo) {
    $dir = Split-Path -Parent (Resolve-Path $Path)
    $url = (git -C $dir remote get-url origin 2>$null)
    if ($url -match 'github\.com[:/]([^/]+)/([^/.]+?)(\.git)?$') {
        $Repo = "$($Matches[1])/$($Matches[2])"
    } else {
        Write-Host "[ERROR] Cannot detect GitHub repository from origin remote. Pass -Repo owner/name."
        exit 1
    }
}

$ghArgs = @("repo", "edit", $Repo)
foreach ($t in $topics) { $ghArgs += "--add-topic"; $ghArgs += $t }

Write-Host "[INFO] Repository: $Repo"
Write-Host "[INFO] Topics ($($topics.Count)): $($topics -join ', ')"

if ($DryRun) {
    Write-Host "[INFO] Dry run: gh $($ghArgs -join ' ')"
    exit 0
}

& gh @args
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] gh repo edit failed."; exit 1 }
Write-Host "[SUCCESS] Topics synchronised."
