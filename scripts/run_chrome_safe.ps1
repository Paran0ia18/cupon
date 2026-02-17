param(
  [string]$FlutterPath = 'C:\Users\tomas\flutter\bin\flutter.bat',
  [switch]$NoRun
)

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-Host '[1/5] Stopping lock-prone processes...'
Get-Process -ErrorAction SilentlyContinue |
  Where-Object {
    $_.ProcessName -in @('dart', 'dartvm', 'flutter', 'chrome', 'msedge', 'OneDrive')
  } |
  Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep -Milliseconds 400

Write-Host '[2/5] Releasing read-only attributes...'
& cmd.exe /d /c "attrib -R build\* /S /D 2>nul" | Out-Null
& cmd.exe /d /c "attrib -R .dart_tool\* /S /D 2>nul" | Out-Null

Write-Host '[3/5] Removing temporary build folders...'
$cleanupDirs = @(
  'build',
  '.dart_tool',
  'windows\\flutter\\ephemeral\\.plugin_symlinks',
  'windows\\flutter\\ephemeral'
)

foreach ($dir in $cleanupDirs) {
  if (Test-Path $dir) {
    & cmd.exe /d /c "rmdir /s /q ""$dir"" 2>nul" | Out-Null
  }
}

if (!(Test-Path $FlutterPath)) {
  throw "Flutter not found at: $FlutterPath"
}

Write-Host '[4/5] Getting packages...'
& $FlutterPath pub get

if (-not $NoRun) {
  Write-Host '[5/5] Running app on Chrome...'
  & $FlutterPath run -d chrome
} else {
  Write-Host '[5/5] Skipped run (NoRun switch used).'
}
