<#
.SYNOPSIS
  Copies Workflow Master skills into an agent skills directory.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File install-skills.ps1 -Target "$HOME\.gemini\config\skills"
  powershell -ExecutionPolicy Bypass -File install-skills.ps1 -Target "$HOME\.claude\skills" -Only diff-review,verify-and-test
#>
param(
    [Parameter(Mandatory = $true)][string]$Target,
    [string[]]$Only = @(),
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$source = $PSScriptRoot

$skills = Get-ChildItem $source -Directory | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") }
if ($Only.Count -gt 0) {
    $wanted = $Only | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    $unknown = $wanted | Where-Object { $skills.Name -notcontains $_ }
    if ($unknown) { Write-Host "[ERROR] Unknown skill(s): $($unknown -join ', ')"; exit 1 }
    $skills = $skills | Where-Object { $wanted -contains $_.Name }
}

if (-not $DryRun -and -not (Test-Path $Target)) { New-Item -ItemType Directory -Path $Target -Force | Out-Null }

foreach ($s in $skills) {
    $dest = Join-Path $Target $s.Name
    $action = if (Test-Path $dest) { "update" } else { "install" }
    Write-Host ("[INFO] {0,-8} {1}" -f $action, $s.Name)
    if ($DryRun) { continue }
    if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
    Copy-Item -Recurse $s.FullName $dest
}

Write-Host "[SUCCESS] $(@($skills).Count) skill(s) processed into $Target"
