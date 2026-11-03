<#
.SYNOPSIS
  Waits for the latest GitHub Actions run on a branch and probes the live URL.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File check-deploy.ps1 -Repo owner/name -Url https://owner.github.io/name/ -Expect "Title"
#>
param(
    [string]$Repo = "",
    [string]$Branch = "main",
    [string]$Url = "",
    [string]$Expect = "",
    [int]$TimeoutSec = 600,
    [switch]$SkipRun
)

# Continue: native gh stderr must not abort PS 5.1; exit codes are checked explicitly.
$ErrorActionPreference = "Continue"

if (-not $Repo) {
    $origin = git remote get-url origin 2>$null
    if ($origin -match 'github\.com[:/]([^/]+)/([^/.]+?)(\.git)?$') { $Repo = "$($Matches[1])/$($Matches[2])" }
    else { Write-Host "[ERROR] Cannot detect repository. Pass -Repo owner/name."; exit 2 }
}
Write-Host "[INFO] Repository: $Repo (branch $Branch)"

if (-not $SkipRun) {
    $json = gh run list --repo $Repo --branch $Branch --limit 1 --json databaseId,status,conclusion,displayTitle,workflowName,headSha 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $json) { Write-Host "[ERROR] gh run list failed. Check 'gh auth status'."; exit 2 }
    $runs = $json | ConvertFrom-Json
    if (-not $runs -or $runs.Count -eq 0) {
        Write-Host "[WARN] No workflow runs found for $Branch. Repository may not deploy via Actions."
    } else {
        $run = $runs[0]
        $sha = $run.headSha.Substring(0, 7)
        Write-Host "[INFO] Run $($run.databaseId): $($run.workflowName) - $($run.displayTitle) @ $sha"
        $start = Get-Date
        while ($true) {
            $state = gh run view $run.databaseId --repo $Repo --json status,conclusion | ConvertFrom-Json
            if ($state.status -eq "completed") { break }
            if (((Get-Date) - $start).TotalSeconds -gt $TimeoutSec) {
                Write-Host "[ERROR] Timed out after $TimeoutSec s waiting for run $($run.databaseId)."
                exit 1
            }
            Write-Host "[INFO] Status: $($state.status) ..."
            Start-Sleep -Seconds 10
        }
        $elapsed = [math]::Round(((Get-Date) - $start).TotalSeconds)
        if ($state.conclusion -ne "success") {
            Write-Host "[ERROR] Run concluded with '$($state.conclusion)'. Failed step logs:"
            gh run view $run.databaseId --repo $Repo --log-failed 2>$null | Select-Object -Last 40
            exit 1
        }
        Write-Host "[SUCCESS] Pipeline succeeded (waited $elapsed s)."
    }
}

if (-not $Url) { Write-Host "[INFO] No -Url given; live check skipped."; exit 0 }

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$probe = $Url + $(if ($Url.Contains("?")) { "&" } else { "?" }) + "v=" + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
try {
    $resp = Invoke-WebRequest -Uri $probe -UseBasicParsing -TimeoutSec 30
} catch {
    Write-Host "[ERROR] Live URL request failed: $($_.Exception.Message)"
    exit 1
}
Write-Host "[INFO] Live: $Url -> HTTP $($resp.StatusCode)"
if ($resp.StatusCode -ne 200) { exit 1 }

$failed = 0
if ($Expect) {
    if ($resp.Content -like "*$Expect*") { Write-Host "[SUCCESS] Expected text found: '$Expect'" }
    else { Write-Host "[ERROR] Expected text not found: '$Expect'"; $failed++ }
}

# Verify referenced JS/CSS assets resolve (catches wrong Vite base path).
$assets = [regex]::Matches($resp.Content, '(?:src|href)="([^"]+\.(?:js|css))"') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
$baseUri = New-Object System.Uri($Url)
foreach ($a in $assets) {
    if ($a -match '^https?://' -and $a -notmatch [regex]::Escape($baseUri.Host)) { continue }
    $abs = (New-Object System.Uri($baseUri, $a)).AbsoluteUri
    try {
        $r = Invoke-WebRequest -Uri $abs -UseBasicParsing -Method Head -TimeoutSec 30
        Write-Host "[INFO] Asset $($r.StatusCode): $a"
    } catch {
        Write-Host "[ERROR] Asset unreachable: $a ($($_.Exception.Message))"
        $failed++
    }
}

if ($failed -gt 0) { Write-Host "[ERROR] $failed live check(s) failed."; exit 1 }
Write-Host "[SUCCESS] Release verified."
exit 0
