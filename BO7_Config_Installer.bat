@echo off
setlocal EnableExtensions DisableDelayedExpansion
title BO7 Config Installer

REM =========================
REM CONFIG
REM =========================
set "GH_OWNER=akahobby"
set "GH_REPO=bo7-config-installer"
set "ASSET_NAME=bo7.config.zip"
set "SET_READONLY=0"

REM =========================
REM Colors
REM =========================
for /f "delims=" %%A in ('echo prompt $E^| cmd') do set "ESC=%%A"
set "C_RESET=%ESC%[0m"
set "C_TITLE=%ESC%[96m"
set "C_OK=%ESC%[92m"
set "C_ERR=%ESC%[91m"
set "C_INFO=%ESC%[97m"

cls
echo %C_TITLE%==========================================%C_RESET%
echo %C_TITLE%        BO7 Config Installer%C_RESET%
echo %C_TITLE%==========================================%C_RESET%
echo.
echo %C_INFO%Repository:%C_RESET% %GH_OWNER%/%GH_REPO%
echo %C_INFO%Asset:%C_RESET% %ASSET_NAME%
echo.

set "PS1=%TEMP%\bo7_config_installer_%RANDOM%%RANDOM%.ps1"

> "%PS1%"  echo param([string]$Owner,[string]$Repo,[string]$PreferredAssetName,[int]$SetReadOnly)
>>"%PS1%" echo $ErrorActionPreference = 'Stop'
>>"%PS1%" echo function Write-Section($msg){ Write-Host ""; Write-Host ('==== ' + $msg + ' ====') -ForegroundColor Cyan }
>>"%PS1%" echo.
>>"%PS1%" echo function Pick-PlayersFolder ^{
>>"%PS1%" echo ^  $base = Join-Path $env:LOCALAPPDATA 'Activision'
>>"%PS1%" echo ^  if ^(-not ^(Test-Path $base^)^) ^{ throw 'Activision folder not found.' ^}
>>"%PS1%" echo ^  $preferred = Join-Path $base 'Call of Duty\players'
>>"%PS1%" echo ^  if ^(Test-Path $preferred^) ^{ return ^(Resolve-Path $preferred^).Path ^}
>>"%PS1%" echo ^  throw 'Players folder not found. Launch the game once first.'
>>"%PS1%" echo ^}
>>"%PS1%" echo.
>>"%PS1%" echo function Get-Release ^{
>>"%PS1%" echo ^  $headers = @{ 'User-Agent'='BO7-Installer'; 'Accept'='application/vnd.github+json' }
>>"%PS1%" echo ^  $url = "https://api.github.com/repos/$Owner/$Repo/releases/latest"
>>"%PS1%" echo ^  return Invoke-RestMethod -Uri $url -Headers $headers
>>"%PS1%" echo ^}
>>"%PS1%" echo.
>>"%PS1%" echo Add-Type -AssemblyName System.IO.Compression.FileSystem
>>"%PS1%" echo.
>>"%PS1%" echo try ^{
>>"%PS1%" echo ^  Write-Section 'Checking Latest Release'
>>"%PS1%" echo ^  $rel = Get-Release
>>"%PS1%" echo ^  $asset = $rel.assets ^| Where-Object { $_.name -ieq $PreferredAssetName } ^| Select-Object -First 1
>>"%PS1%" echo ^  if ^(-not $asset^) { throw 'Zip asset not found in release.' }
>>"%PS1%" echo ^  Write-Host ('Using asset: ' + $asset.name) -ForegroundColor Green
>>"%PS1%" echo.
>>"%PS1%" echo ^  Write-Section 'Downloading'
>>"%PS1%" echo ^  $work = Join-Path $env:TEMP ('bo7_' + [Guid]::NewGuid().ToString('N'))
>>"%PS1%" echo ^  New-Item -ItemType Directory -Path $work ^| Out-Null
>>"%PS1%" echo ^  $zipPath = Join-Path $work 'config.zip'
>>"%PS1%" echo ^  $extract = Join-Path $work 'extract'
>>"%PS1%" echo ^  New-Item -ItemType Directory -Path $extract ^| Out-Null
>>"%PS1%" echo ^  Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -UseBasicParsing
>>"%PS1%" echo ^  Write-Host 'Download complete.' -ForegroundColor Green
>>"%PS1%" echo.
>>"%PS1%" echo ^  Write-Section 'Extracting'
>>"%PS1%" echo ^  [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $extract)
>>"%PS1%" echo ^  Write-Host 'Extraction complete.' -ForegroundColor Green
>>"%PS1%" echo.
>>"%PS1%" echo ^  Write-Section 'Installing'
>>"%PS1%" echo ^  $players = Pick-PlayersFolder
>>"%PS1%" echo ^  Write-Host ('Target folder: ' + $players) -ForegroundColor Yellow
>>"%PS1%" echo ^  $files = @('s.1.0.cod25.m','s.1.0.cod25.txt0','s.1.0.cod25.txt1')
>>"%PS1%" echo ^  $stamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
>>"%PS1%" echo ^  $backup = Join-Path $players ('backup_bo7_' + $stamp)
>>"%PS1%" echo ^  New-Item -ItemType Directory -Path $backup ^| Out-Null
>>"%PS1%" echo ^  foreach ($f in $files){
>>"%PS1%" echo ^    $dest = Join-Path $players $f
>>"%PS1%" echo ^    if (Test-Path $dest){ Copy-Item -LiteralPath $dest -Destination (Join-Path $backup $f) -Force }
>>"%PS1%" echo ^    Copy-Item -LiteralPath (Join-Path $extract $f) -Destination $dest -Force
>>"%PS1%" echo ^  }
>>"%PS1%" echo ^  Write-Host ('Backup created: ' + $backup) -ForegroundColor DarkGray
>>"%PS1%" echo ^  Write-Host 'Config files installed successfully.' -ForegroundColor Green
>>"%PS1%" echo.
>>"%PS1%" echo ^  Write-Section 'Next Steps'
>>"%PS1%" echo ^  Write-Host '1) Launch the game'
>>"%PS1%" echo ^  Write-Host '2) Select "No" on the pop up'
>>"%PS1%" echo ^  Write-Host '3) Wait for shaders'
>>"%PS1%" echo.
>>"%PS1%" echo ^} catch ^{
>>"%PS1%" echo ^  Write-Host ('ERROR: ' + $_.Exception.Message) -ForegroundColor Red
>>"%PS1%" echo ^  exit 1
>>"%PS1%" echo ^}

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Owner "%GH_OWNER%" -Repo "%GH_REPO%" -PreferredAssetName "%ASSET_NAME%" -SetReadOnly %SET_READONLY%
set "EC=%ERRORLEVEL%"

del /q "%PS1%" >nul 2>&1

echo.
if "%EC%"=="0" (
  echo %C_OK%Installation completed successfully.%C_RESET%
) else (
  echo %C_ERR%Installation failed.%C_RESET%
)
echo.
pause
exit /b %EC%
