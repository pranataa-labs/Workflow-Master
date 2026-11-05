#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('feat', 'fix', 'refactor', 'perf', 'test', 'docs', 'chore', 'style', 'ci', 'build', 'revert')]
    [string]$Type,

    [Parameter(Mandatory = $false)]
    [string]$Scope = '',

    [Parameter(Mandatory = $true)]
    [string]$Subject,

    [Parameter(Mandatory = $false)]
    [string]$Body = '',

    [Parameter(Mandatory = $false)]
    [string]$Branch = '',

    [Parameter(Mandatory = $false)]
    [string]$Base = 'main',

    [Parameter(Mandatory = $false)]
    [string]$Remote = 'origin',

    [Parameter(Mandatory = $false)]
    [string[]]$SyncRemotes = @()
)

$ErrorActionPreference = 'Stop'
$CoAuthorTrailer = 'Co-authored-by: aria sastra <192975116+ariasastra-dev@users.noreply.github.com>'

# 1. Validate Conventional Commit subject
$cleanSubject = $Subject.Trim().TrimEnd('.')
if ([string]::IsNullOrWhiteSpace($cleanSubject)) {
    Write-Host '[ERROR] Commit subject cannot be empty.' -ForegroundColor Red
    exit 1
}

$header = if ($Scope) { "$Type($Scope): $cleanSubject" } else { "$Type`: $cleanSubject" }

# 2. Stage all tracked/untracked modifications if nothing is staged yet
$staged = git diff --cached --name-only
if (-not $staged) {
    Write-Host '[INFO] Staging modified and untracked files (git add -A)'
    git add -A
    $staged = git diff --cached --name-only
}

if (-not $staged) {
    Write-Host '[ERROR] No changes found to commit.' -ForegroundColor Red
    exit 1
}

# 3. Run pre-commit diff security scan if available
$scanDiffScript = Join-Path $PSScriptRoot '..\..\diff-review\scripts\scan-diff.ps1'
if (Test-Path $scanDiffScript) {
    Write-Host '[INFO] Running pre-commit diff review scan'
    & $scanDiffScript
    if ($LASTEXITCODE -ne 0) {
        Write-Host '[ERROR] Pre-commit diff scan blocked the commit.' -ForegroundColor Red
        exit 1
    }
}

# 4. Generate feature branch name if omitted
if (-not $Branch) {
    $slugSource = if ($Scope) { "$Scope-$cleanSubject" } else { $cleanSubject }
    $slug = ($slugSource.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
    if ($slug.Length -gt 32) { $slug = $slug.Substring(0, 32).Trim('-') }
    $stamp = Get-Date -Format 'MMdd-HHmm'
    $Branch = "$Type/$slug-$stamp"
}

Write-Host "[INFO] Creating and switching to branch: $Branch"
git checkout -b $Branch
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to create branch '$Branch'." -ForegroundColor Red
    exit 1
}

# 5. Build commit message with mandatory Rule 12.1 Co-Author trailer
$msgParts = New-Object System.Collections.Generic.List[string]
$msgParts.Add($header)
$msgParts.Add('')
if (-not [string]::IsNullOrWhiteSpace($Body)) {
    $msgParts.Add($Body.Trim())
    $msgParts.Add('')
}
$msgParts.Add($CoAuthorTrailer)
$fullCommitMsg = $msgParts -join "`n"

Write-Host "[INFO] Committing changes: $header"
git commit -m $fullCommitMsg
if ($LASTEXITCODE -ne 0) {
    Write-Host '[ERROR] git commit failed.' -ForegroundColor Red
    exit 1
}

# 6. Push feature branch to remote
Write-Host "[INFO] Pushing branch '$Branch' to remote '$Remote'"
git push -u $Remote $Branch
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to push branch '$Branch' to '$Remote'." -ForegroundColor Red
    exit 1
}

# 7. Resolve target GitHub repository slug from remote URL
$remoteUrl = (git remote get-url $Remote).Trim()
$repoSlug = ''
if ($remoteUrl -match 'github\.com[:/]([^/]+/[^/\.]+)(\.git)?$') {
    $repoSlug = $Matches[1]
}

if (-not $repoSlug) {
    Write-Host "[ERROR] Could not parse GitHub owner/repo from remote URL: $remoteUrl" -ForegroundColor Red
    exit 1
}

# 8. Open Pull Request via GitHub CLI
$prBody = if (-not [string]::IsNullOrWhiteSpace($Body)) {
    "$($Body.Trim())`n`n---`nAutomated Branch & PR flow compliant with Workflow Master Rule 12.1 and Rule 12.2."
} else {
    "Automated Branch & PR flow for `$header` compliant with Workflow Master Rule 12.1 and Rule 12.2."
}

Write-Host "[INFO] Opening Pull Request on $repoSlug ($Branch -> $Base)"
$prUrl = gh pr create --repo $repoSlug --base $Base --head $Branch --title $header --body $prBody
if ($LASTEXITCODE -ne 0) {
    Write-Host '[ERROR] Failed to create Pull Request via gh CLI.' -ForegroundColor Red
    exit 1
}
$prUrl = ($prUrl | Select-Object -Last 1).ToString().Trim()
Write-Host "[SUCCESS] Pull Request created: $prUrl"

# 9. Merge Pull Request and delete remote branch
Write-Host "[INFO] Merging Pull Request: $prUrl"
gh pr merge $prUrl --repo $repoSlug --merge --delete-branch
if ($LASTEXITCODE -ne 0) {
    Write-Host '[WARN] Standard merge returned non-zero; retrying with --admin flag'
    gh pr merge $prUrl --repo $repoSlug --merge --delete-branch --admin
    if ($LASTEXITCODE -ne 0) {
        Write-Host '[ERROR] Failed to merge Pull Request.' -ForegroundColor Red
        exit 1
    }
}
Write-Host "[SUCCESS] Pull Request merged into '$Base'."

# 10. Switch back to base branch, pull merged changes, and clean up local feature branch
Write-Host "[INFO] Synchronising local '$Base' branch"
git checkout $Base
git pull $Remote $Base
git branch -d $Branch 2>$null | Out-Null

# 11. Sync additional remotes if specified
foreach ($extraRemote in $SyncRemotes) {
    if ($extraRemote -and $extraRemote -ne $Remote) {
        Write-Host "[INFO] Synchronising '$Base' to secondary remote '$extraRemote'"
        git push $extraRemote $Base
    }
}

Write-Host "[SUCCESS] Branch & PR workflow completed for $repoSlug."
