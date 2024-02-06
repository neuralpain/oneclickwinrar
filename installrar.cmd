<# :# DO NOT REMOVE THIS LINE

:: installrar.cmd
:: oneclickwinrar, version 0.3.0
:: Copyright (c) 2023, neuralpain
:: Install WinRAR

@echo off
mode 44,8
title installrar (v0.3.0)
:: uses PwshBatch.cmd <https://gist.github.com/neuralpain/4ca8a6c9aca4f0a1af2440f474e92d05>
setlocal EnableExtensions DisableDelayedExpansion
set ARGS=%*
if defined ARGS set ARGS=%ARGS:"=\"%
if defined ARGS set ARGS=%ARGS:'=''%
PowerShell -NoP -C ^"Invoke-Expression ('^& {' + (get-content -raw '%~f0') + '} %ARGS%')"
exit /b

# --- PS --- #>

$global:ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Script:WINRAR_EXE = $null
$Script:FETCH_WINRAR = $false
$winrar = "winrar-x\d{2}-\d{3}\.exe"

function Invoke-Installer($file) {
  $x = (($file -replace('winrar-x\d{2}-')).Trim('.exe')) / 100
  Write-Host "Installing WinRAR v${x}..."
  
  try {
    Start-Process $file "/s" -Wait
    Write-Host "WinRAR installed successfully." -ForegroundColor Green
  }
  catch {
    Write-Host "Installer ran into a problem." -ForegroundColor DarkRed
    Write-Host "Please restart the script." -ForegroundColor Yellow
    Pause; exit
  }
  finally { if ($Script:FETCH_WINRAR) { Remove-Item $Script:WINRAR_EXE } }
}

function Get-Installer {
  $files = Get-ChildItem -Path $pwd | Where-Object { $_.Name -match '^winrar' }
  foreach ($file in $files) { if ($file -match $winrar) { return $file } }
}

$Script:WINRAR_EXE = (Get-Installer)

if ($null -eq $Script:WINRAR_EXE) {
  Write-Host "Testing connection... " -NoNewLine
  if (Test-Connection www.google.com -Quiet) {
    Write-Host -NoNewLine "OK.`nDownloading WinRAR... "
    try { Start-BitsTransfer "https://www.rarlab.com/rar/winrar-x64-623.exe" $pwd\ } 
    catch {
      Write-Host "`nDownloader ran into a problem." -ForegroundColor DarkRed
      Write-Host "Please check your internet connection." -ForegroundColor Yellow
      Pause; exit
    } 
    $Script:WINRAR_EXE = (Get-Installer)
    $Script:FETCH_WINRAR = $true
    Write-Host "Done."
  } else { Write-Host "No internet."; Pause; exit }
}

Invoke-Installer $Script:WINRAR_EXE
Start-Sleep -Seconds 2
exit
