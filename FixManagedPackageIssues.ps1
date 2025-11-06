Write-Host "ðŸ” Starting cleanup for Apex project..." -ForegroundColor Cyan

$extensions = @("*.cls","*.trigger","*.js","*.html","*.xml")
foreach ($ext in $extensions) {
    $files = Get-ChildItem -Path . -Recurse -Include $ext
    foreach ($file in $files) {
        $cleaned = (Get-Content $file.FullName) | ForEach-Object { $_ -replace '\s+$','' }
        Set-Content -Path $file.FullName -Value $cleaned
        Write-Host ("âœ” Cleaned trailing spaces in " + $file.FullName)
    }
}

$metaFiles = Get-ChildItem -Path . -Recurse -Include "*-meta.xml"
foreach ($file in $metaFiles) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match "<apiVersion>(\d+\.\d+)</apiVersion>") {
        $newContent = $content -replace "<apiVersion>\d+\.\d+</apiVersion>", "<apiVersion>59.0</apiVersion>"
        Set-Content -Path $file.FullName -Value $newContent
        Write-Host ("âœ” Updated API version in " + $file.FullName)
    }
}

Write-Host ""
Write-Host "ðŸŽ‰ Cleanup completed successfully!" -ForegroundColor Green
Write-Host "Next: Run your analyzer again and recreate the managed package."
