param (
    [Parameter(Mandatory=$true)]
    [string]$Name
)

# Validasi nama project: hanya huruf kecil, angka, dan tanda hubung
if ($Name -notmatch '^[a-z0-9\-]+$') {
    Write-Error "Nama proyek harus huruf kecil, angka, dan tanda hubung (contoh: toko-kue-enak)."
    exit 1
}

$laragonPath = "C:\laragon"
$wwwPath = "$laragonPath\www"
$projectPath = "$wwwPath\$Name"

if (-not (Test-Path $laragonPath)) {
    Write-Error "Direktori Laragon tidak ditemukan di $laragonPath"
    exit 1
}

if (Test-Path $projectPath) {
    Write-Error "Folder proyek $projectPath sudah ada!"
    exit 1
}

Write-Host "=== [1/6] Membuat Proyek Laravel Baru: $Name ===" -ForegroundColor Cyan
Set-Location $wwwPath
composer create-project laravel/laravel $Name

if (-not (Test-Path $projectPath)) {
    Write-Error "Gagal menginisialisasi proyek Laravel."
    exit 1
}

Set-Location $projectPath

Write-Host "=== [2/6] Mengonfigurasi .env & Database MySQL Laragon ===" -ForegroundColor Cyan
$dbName = $Name.Replace("-", "_")

# Konfigurasi .env
(Get-Content .env) `
    -replace 'APP_NAME=Laravel', "APP_NAME=""$Name""" `
    -replace 'APP_URL=http://localhost', "APP_URL=http://$Name.test" `
    -replace 'DB_DATABASE=.*', "DB_DATABASE=$dbName" `
    -replace 'DB_USERNAME=.*', 'DB_USERNAME=root' `
    -replace 'DB_PASSWORD=.*', 'DB_PASSWORD=' |
    Set-Content .env

# Buat Database di MySQL Laragon jika belum ada
$mysqlBin = "$laragonPath\bin\mysql\mysql-8.0.30-winx64\bin\mysql.exe"
if (Test-Path $mysqlBin) {
    & $mysqlBin -u root -e "CREATE DATABASE IF NOT EXISTS \`$dbName\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    Write-Host "Database '$dbName' berhasil disiapkan." -ForegroundColor Green
} else {
    Write-Warning "mysql.exe tidak ditemukan di path default. Silakan buat database '$dbName' manual di HeidiSQL."
}

Write-Host "=== [3/6] Menjalankan Migration Awal & Storage Symlink ===" -ForegroundColor Cyan
php artisan migrate
php artisan storage:link

Write-Host "=== [4/6] Menginstal Dependensi Frontend (Alpine.js & Font) ===" -ForegroundColor Cyan
npm install alpinejs @alpinejs/focus @alpinejs/persist

Write-Host "=== [5/6] Menginstal Dev Tools & Image Processing ===" -ForegroundColor Cyan
composer require barryvdh/laravel-debugbar --dev

Write-Host "=== [6/6] Selesai! ===" -ForegroundColor Green
Write-Host "Proyek siap di: $projectPath"
Write-Host "Virtual host lokal: http://$Name.test"
Write-Host "Jangan lupa untuk klik kanan Laragon -> 'Reload' Apache/Nginx agar virtual host terdaftar!"
