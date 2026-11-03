<#
.SYNOPSIS
  Initialises and publishes the current directory as a GitHub repository following
  Workflow Master Rules 11.1, 12 and 12.1.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File publish-repo.ps1 -Name my-project -Description "..." -DryRun
#>
param(
    [Parameter(Mandatory = $true)][string]$Name,
    [string]$Owner = "pranataa-labs",
    [string]$Description = "",
    [ValidateSet("public", "private")][string]$Visibility = "public",
    [string]$Collaborator = "ariasastra-dev",
    [switch]$DryRun
)

# Continue: native git/gh stderr must not abort PS 5.1; exit codes are checked explicitly.
$ErrorActionPreference = "Continue"
$CoAuthor = "Co-authored-by: aria sastra <192975116+ariasastra-dev@users.noreply.github.com>"

function Step([string]$msg) { Write-Host "[INFO] $msg" }
function Run([string]$exe, [string[]]$argv) {
    Write-Host ("  > {0} {1}" -f $exe, ($argv -join ' '))
    if ($DryRun) { return }
    & $exe @argv
    if ($LASTEXITCODE -ne 0) { throw "Command failed: $exe $($argv -join ' ')" }
}

# 1. Name validation
if ($Name -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
    Write-Host "[ERROR] Repository name must be lowercase English kebab-case (e.g. clinic-queue-management)."
    exit 1
}
Step "Target repository: $Owner/$Name ($Visibility)"

# 2. Prerequisites
if (-not $DryRun) {
    gh auth status *> $null
    if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] gh is not authenticated. Run 'gh auth login' first."; exit 1 }
}

# 3. Local repository
if (-not (Test-Path ".git")) {
    Step "Initialising git repository"
    Run "git" @("init", "-b", "main")
}

if (-not (Test-Path ".gitignore")) {
    Write-Host "[WARN] No .gitignore found. Create one before publishing to avoid leaking .env or build output."
}

$hasCommit = $true
git rev-parse --verify HEAD *> $null
if ($LASTEXITCODE -ne 0) { $hasCommit = $false }

if (-not $hasCommit) {
    Step "Creating initial commit"
    Run "git" @("add", "-A")
    Run "git" @("commit", "-m", "chore: initialize repository", "-m", $CoAuthor)
}

# 4. Remote creation
$existing = (git remote 2>$null) -contains "origin"
if ($existing) {
    Write-Host "[WARN] Remote 'origin' already exists; skipping gh repo create and pushing current branch."
    Run "git" @("push", "-u", "origin", "HEAD")
} else {
    Step "Creating GitHub repository"
    $createArgs = @("repo", "create", "$Owner/$Name", "--$Visibility", "--source", ".", "--remote", "origin", "--push")
    if ($Description) { $createArgs += @("--description", $Description) }
    Run "gh" $createArgs
}

# 5. Collaborator invitation (Rule 12.1)
if ($Collaborator) {
    Step "Inviting collaborator $Collaborator with push permission"
    Run "gh" @("api", "-X", "PUT", "repos/$Owner/$Name/collaborators/$Collaborator", "-f", "permission=push", "--silent")
}

# 6. Topic sync (Rule 11.1)
$sync = Join-Path $PSScriptRoot "..\..\readme-github-sync\scripts\sync-topics.ps1"
if ((Test-Path "README.md") -and (Test-Path $sync)) {
    Step "Synchronising topics from README.md"
    $syncArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $sync, "-Path", "README.md", "-Repo", "$Owner/$Name")
    if ($DryRun) { $syncArgs += "-DryRun" }
    & powershell @syncArgs
} else {
    Write-Host "[WARN] README.md or sync-topics.ps1 not found; topics were not synchronised."
}

Write-Host ""
Write-Host "[SUCCESS] https://github.com/$Owner/$Name"
