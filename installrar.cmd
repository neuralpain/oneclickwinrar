<# :# DO NOT REMOVE THIS LINE

:: installrar.cmd, version 0.2.3
:: Copyright (c) 2023, neuralpain
:: Install WinRAR

@echo off
title installrar v0.2.3
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

$winrar = "winrar-x\d{2}-\d{3}\.exe"

function Invoke-Installer($file) { Write-Host "Installing..."; Start-Process $file "/s" -Wait >$null 2>&1 }

function Get-Installer {
  $files = Get-ChildItem -Path $pwd | Where-Object { $_.Name -match '^winrar' }
  foreach ($file in $files) { if ($file -match $winrar) { return $file } }
}

if ($null -eq (Get-Installer)) {
  Write-Host "Testing connection... " -NoNewLine
  if (Test-Connection www.google.com -Quiet) {
    Write-Host "OK.`nDownloading WinRAR..."
    Start-BitsTransfer "https://www.rarlab.com/rar/winrar-x64-623.exe" $pwd\
  } else { Write-Host "No internet."; Pause; exit 1 }
}

Invoke-Installer (Get-Installer)
exit
