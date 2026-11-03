# Setup Git Discipline & Automated Commit Linting
# Usage: .\setup-git-discipline.ps1

Write-Host "[INFO] Memasang standar Git Discipline dan Conventional Commits..." -ForegroundColor Cyan

# 1. Pasang Git Commit Message Template lokal
if (Test-Path "templates/git/git-commit-template.txt") {
    Copy-Item "templates/git/git-commit-template.txt" ".gitmessage.txt" -Force
    git config commit.template .gitmessage.txt
    Write-Host "[SUCCESS] Git commit template lokal berhasil dipasang (.gitmessage.txt)" -ForegroundColor Green
}

# 2. Pasang Commitlint config jika belum ada
if ((Test-Path "templates/git/commitlint.config.js") -and -not (Test-Path "commitlint.config.js")) {
    Copy-Item "templates/git/commitlint.config.js" "commitlint.config.js"
    Write-Host "[SUCCESS] commitlint.config.js berhasil disalin" -ForegroundColor Green
}

# 3. Pasang Git-Cliff config jika belum ada
if ((Test-Path "templates/git/cliff.toml") -and -not (Test-Path "cliff.toml")) {
    Copy-Item "templates/git/cliff.toml" "cliff.toml"
    Write-Host "[SUCCESS] cliff.toml (generator changelog otomatis) berhasil disalin" -ForegroundColor Green
}

# 4. Inisialisasi Husky & Commitlint jika proyek memiliki package.json
if (Test-Path "package.json") {
    Write-Host "[INFO] Memasang dependensi npm: @commitlint/cli, @commitlint/config-conventional, dan husky..." -ForegroundColor Cyan
    npm install --save-dev @commitlint/cli @commitlint/config-conventional husky
    npx husky init
    Set-Content -Path ".husky/commit-msg" -Value 'npx --no -- commitlint --edit "$1"'
    Write-Host "[SUCCESS] Husky dan Commitlint hook berhasil diaktifkan" -ForegroundColor Green
}

Write-Host "[SUCCESS] Standar Git Commit Craft selesai dipasang." -ForegroundColor Green