<# :# ###

:: installrar.cmd, version 0.1
:: Install WinRAR

@echo off
title installrar.cmd, v0.1
:: uses PwshBatch.cmd <https://gist.github.com/neuralpain/4ca8a6c9aca4f0a1af2440f474e92d05>
setlocal EnableExtensions DisableDelayedExpansion
set ARGS=%*
if defined ARGS set ARGS=%ARGS:"=\"%
if defined ARGS set ARGS=%ARGS:'=''%

PowerShell -NoP -C ^"Invoke-Expression ('^& {' + (get-content -raw '%~f0') + '} %ARGS%')"
winrar-x64.exe /s
exit /b

# --- PS --- #>

$global:ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$winrar = "winrar-x64.exe"


if (-not(Test-Path $winrar -PathType Leaf)) { 
  Write-Host "Testing connection... " -NoNewLine
  if (Test-Connection www.google.com -Quiet) {
    Write-Host "OK.`nDownloading..."
    Start-BitsTransfer "https://www.rarlab.com/rar/winrar-x64-623.exe" $winrar
  } else { Write-Host "No internet."; Pause; exit 1 }
}

Write-Host "Installing..."