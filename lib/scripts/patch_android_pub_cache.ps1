$ErrorActionPreference = 'Stop'

$pubCaches = @()

if (-not [string]::IsNullOrWhiteSpace($env:PUB_CACHE)) {
    $pubCaches += $env:PUB_CACHE
}

if (-not [string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
    $pubCaches += Join-Path $env:LOCALAPPDATA 'Pub/Cache'
}

$pubCaches += Join-Path $HOME '.pub-cache'
$pubCaches = $pubCaches | Select-Object -Unique

$files = @()

foreach ($pubCache in $pubCaches) {
    $patterns = @(
        (Join-Path $pubCache 'hosted/pub.dev/flutter_inappwebview_android-*/android/build.gradle'),
        (Join-Path $pubCache 'hosted/pub.dartlang.org/flutter_inappwebview_android-*/android/build.gradle')
    )

    $files += Get-ChildItem -Path $patterns -ErrorAction SilentlyContinue
}

if ($null -eq $files -or $files.Count -eq 0) {
    Write-Host 'flutter_inappwebview_android was not found in the pub cache; skipping Android pub cache patch.'
    exit 0
}

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $updated = $content.Replace('proguard-android.txt', 'proguard-android-optimize.txt')

    if ($updated -eq $content) {
        Write-Host "$($file.FullName) already uses proguard-android-optimize.txt"
        continue
    }

    Set-Content -Path $file.FullName -Value $updated -NoNewline -Encoding UTF8
    Write-Host "$($file.FullName) patched for AGP 9"
}
