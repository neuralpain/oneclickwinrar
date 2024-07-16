<# :# DO NOT REMOVE THIS LINE

:: oneclickrar.cmd
:: oneclickwinrar, version 0.4.0.2407
:: Copyright (c) 2023, neuralpain
:: Install and license WinRAR

@echo off
mode 44,8
title oneclickrar (v0.4.0.2407)
:: uses PwshBatch.cmd <https://gist.github.com/neuralpain/4ca8a6c9aca4f0a1af2440f474e92d05>
setlocal EnableExtensions DisableDelayedExpansion
set ARGS=%*
if defined ARGS set ARGS=%ARGS:"=\"%
if defined ARGS set ARGS=%ARGS:'=''%
PowerShell -NoP -C ^"Invoke-Expression ('^& {' + (get-content -raw '%~f0') + '} %ARGS%')"
exit /b

# --- PS --- #>

$global:ProgressPreference = "SilentlyContinue"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

$Script:WINRAR_EXE = $null
$Script:FETCH_WINRAR = $false
$rarkey = "RAR registration data`r`nTechTools.net`r`nUnlimited Company License`r`nUID=be495af2e04c51526b85`r`n64122122506b85be56d054210a35c74d3d4b85c98b58c1c03635b4`r`n931f702fd05f10d8593c60fce6cb5ffde62890079861be57638717`r`n7131ced835ed65cc743d9777f2ea71a8e32c7e593cf66794343565`r`nb41bcf56929486b8bcdac33d50ecf77399607b61cbd4c7c227f192`r`n2b3291c3cf4822a590ea57181b47bfe6cf92ddc40a7de2d2796819`r`n1781857ba6b1b67a2b15bc5f9dfb682cca338eaa5c606da560397f`r`n6c6efc340004788adcfe55aa8c331391a95957b7e7401955721377"
$winrar = "winrar-x\d{2}-\d{3}\w*\.exe" # catch any version for any language
$rarreg = "rarreg.key"

function Invoke-Installer($file) {
  $x = if ($file -match "(?<version>\d{3})") { ($matches['version']) / 100 } # get WinRAR version number
  Write-Host "Installing WinRAR v${x}..."
  
  try {
    Start-Process $file "/s" -Wait
    Write-Host "WinRAR installed successfully." -ForegroundColor Green
  }
  catch {
    Write-Host "Installer ran into a problem." -ForegroundColor Red
    Write-Host "Please restart the script." -ForegroundColor Yellow
    Pause; exit
  }
  finally {
    Remove-Item $rarreg
    if ($Script:FETCH_WINRAR) { Remove-Item $Script:WINRAR_EXE }
  }
}

function Write-License {
  if (-not(Test-Path $rarreg -PathType Leaf)) {
    [IO.File]::WriteAllLines($rarreg, $rarkey)
  }
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
    try { Start-BitsTransfer "https://www.rarlab.com/rar/winrar-x64-701.exe" $pwd\ } 
    catch {
      Write-Host "`nDownloader ran into a problem." -ForegroundColor Red
      Write-Host "Please check your internet connection." -ForegroundColor Yellow
      Pause; exit
    } 
    $Script:WINRAR_EXE = (Get-Installer)
    $Script:FETCH_WINRAR = $true
    Write-Host "Done."
  } else { Write-Host "No internet."; Pause; exit }
}

Write-License
Invoke-Installer $Script:WINRAR_EXE
Start-Sleep -Seconds 2
exit
