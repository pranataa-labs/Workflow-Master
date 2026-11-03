<#
.SYNOPSIS
  Detects the project stack and runs available typecheck, lint, test and build commands.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File verify.ps1
  powershell -ExecutionPolicy Bypass -File verify.ps1 -Path ./frontend -DryRun
#>
param(
    [string]$Path = ".",
    [switch]$DryRun
)

# Continue: native tool stderr must not abort PS 5.1; exit codes are checked explicitly.
$ErrorActionPreference = "Continue"

if (-not (Test-Path $Path)) { Write-Host "[ERROR] Path not found: $Path"; exit 2 }
Push-Location $Path

$checks = New-Object System.Collections.Generic.List[object]
function Add-Check([string]$name, [string]$cmd) { $checks.Add(@{ name = $name; cmd = $cmd }) }
function Has-Cmd([string]$c) { return [bool](Get-Command $c -ErrorAction SilentlyContinue) }
$stacks = @()

# Node / TypeScript
if (Test-Path "package.json") {
    $pm = "npm"
    if (Test-Path "pnpm-lock.yaml") { $pm = "pnpm" } elseif (Test-Path "yarn.lock") { $pm = "yarn" }
    $stacks += "node ($pm)"
    $pkg = Get-Content "package.json" -Raw | ConvertFrom-Json
    $scripts = @()
    if ($pkg.scripts) { $scripts = $pkg.scripts.PSObject.Properties.Name }
    $hasTypecheck = $false
    foreach ($s in @("typecheck", "type-check", "lint", "test", "build")) {
        if ($scripts -contains $s) {
            if ($s -like "type*") { $hasTypecheck = $true }
            $cmd = "$pm run $s"
            if ($s -eq "test" -and $pm -eq "npm") { $cmd = "npm test --silent" }
            Add-Check $s $cmd
        }
    }
    if (-not $hasTypecheck -and (Test-Path "tsconfig.json") -and -not ($scripts -contains "build" -and $pkg.scripts.build -match "tsc")) {
        Add-Check "typecheck" "npx --no-install tsc --noEmit"
    }
}

# Python
if ((Test-Path "pyproject.toml") -or (Test-Path "requirements.txt") -or (Test-Path "setup.py")) {
    $stacks += "python"
    $py = "python"
    if (Test-Path ".venv\Scripts\python.exe") { $py = ".venv\Scripts\python.exe" }
    elseif (Test-Path "venv\Scripts\python.exe") { $py = "venv\Scripts\python.exe" }
    $pyproject = ""
    if (Test-Path "pyproject.toml") { $pyproject = Get-Content "pyproject.toml" -Raw }
    & $py -m ruff --version *> $null
    if ($LASTEXITCODE -eq 0) { Add-Check "lint" "$py -m ruff check ." }
    if ($pyproject -match '\[tool\.mypy\]' -or (Test-Path "mypy.ini")) { Add-Check "typecheck" "$py -m mypy ." }
    $hasTests = (Test-Path "tests") -or (Test-Path "test") -or (Get-ChildItem -Recurse -Filter "test_*.py" -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\(\.?venv|site-packages)\\' } | Select-Object -First 1)
    if ($hasTests) { Add-Check "test" "$py -m pytest -q" }
}

# PHP / Laravel
if (Test-Path "composer.json") {
    $stacks += "php"
    if (Test-Path "artisan") { Add-Check "test" "php artisan test" }
    elseif (Test-Path "vendor\bin\phpunit") { Add-Check "test" "vendor\bin\phpunit" }
    if (Test-Path "vendor\bin\pint") { Add-Check "lint" "vendor\bin\pint --test" }
    if (Test-Path "vendor\bin\phpstan") { Add-Check "typecheck" "vendor\bin\phpstan analyse --no-progress" }
}

# Go
if (Test-Path "go.mod") {
    $stacks += "go"
    Add-Check "vet" "go vet ./..."
    Add-Check "test" "go test ./..."
}

Write-Host "[INFO] Directory: $((Get-Location).Path)"
if ($stacks.Count -eq 0) {
    Write-Host "[WARN] No supported stack detected. Verify manually (smoke run, open the page, run the script)."
    Pop-Location
    exit 0
}
Write-Host "[INFO] Stack: $($stacks -join ', ')"
if ($checks.Count -eq 0) {
    Write-Host "[WARN] Stack detected but no typecheck/lint/test/build commands are available. Report this explicitly."
    Pop-Location
    exit 0
}

$results = @()
foreach ($c in $checks) {
    if ($DryRun) { Write-Host ("[PLAN] {0,-10} {1}" -f $c.name, $c.cmd); continue }
    Write-Host ""
    Write-Host ("[RUN] {0}: {1}" -f $c.name, $c.cmd)
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    cmd /c $c.cmd
    $code = $LASTEXITCODE
    $sw.Stop()
    $status = if ($code -eq 0) { "PASS" } else { "FAIL" }
    $results += [pscustomobject]@{ Check = $c.name; Status = $status; Exit = $code; Seconds = [math]::Round($sw.Elapsed.TotalSeconds, 1); Command = $c.cmd }
}

Pop-Location
if ($DryRun) { exit 0 }

Write-Host ""
Write-Host "[INFO] Verification summary"
$results | Format-Table -AutoSize | Out-String | Write-Host
$failed = @($results | Where-Object { $_.Status -eq "FAIL" })
if ($failed.Count -gt 0) {
    Write-Host "[ERROR] $($failed.Count) check(s) failed: $(($failed | ForEach-Object { $_.Check }) -join ', ')"
    exit 1
}
Write-Host "[SUCCESS] All checks passed."
exit 0
