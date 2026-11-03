# Performance & Build Healthcheck Script
Write-Host "=== Memeriksa Kondisi Performa & Build Proyek ===" -ForegroundColor Cyan

# 1. Cek APP_DEBUG di .env
if (Test-Path .env) {
    $envContent = Get-Content .env -Raw
    if ($envContent -match 'APP_DEBUG=true') {
        Write-Warning "[PERINGATAN] APP_DEBUG bernilai true. Pastikan diubah ke false sebelum deploy ke produksi!"
    } else {
        Write-Host "[OK] APP_DEBUG false atau dinonaktifkan." -ForegroundColor Green
    }
}

# 2. Cek Hot Reload file sisa
if (Test-Path public/hot) {
    Write-Warning "[PERINGATAN] Ditemukan file 'public/hot'. Ini menandakan mode 'npm run dev' aktif. Hapus sebelum build produksi!"
} else {
    Write-Host "[OK] Tidak ada file public/hot." -ForegroundColor Green
}

# 3. Cek Gambar Tanpa Format WebP di public/images atau storage
$largeImages = Get-ChildItem -Path public, storage/app/public -Include *.png, *.jpg, *.jpeg -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt 300KB }
if ($largeImages) {
    Write-Warning "[PERINGATAN] Ditemukan file gambar JPG/PNG > 300KB. Disarankan convert ke WebP:"
    $largeImages | ForEach-Object { Write-Host " - $($_.FullName) ($([math]::Round($_.Length/1KB, 2)) KB)" -ForegroundColor Yellow }
} else {
    Write-Host "[OK] Tidak ditemukan gambar mentah berukuran besar." -ForegroundColor Green
}

# 4. Cek Ukuran Build Vite
if (Test-Path public/build/assets) {
    Write-Host "[INFO] Analisis Ukuran Aset Build (public/build/assets):"
    Get-ChildItem public/build/assets | Select-Object Name, @{Name="Size(KB)";Expression={[math]::Round($_.Length/1KB, 2)}} | Format-Table -AutoSize
} else {
    Write-Warning "[INFO] Direktori public/build/assets belum dibuat. Jalankan 'npm run build'."
}
