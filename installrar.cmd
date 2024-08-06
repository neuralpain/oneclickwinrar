<# :# DO NOT REMOVE THIS LINE

:: installrar.cmd
:: oneclickwinrar, version 0.6.1.701
:: Copyright (c) 2023, neuralpain
:: Install WinRAR

@echo off
mode 44,8
title installrar (v0.6.1.701)
:: uses PwshBatch.cmd <https://gist.github.com/neuralpain/4ca8a6c9aca4f0a1af2440f474e92d05>
setlocal EnableExtensions DisableDelayedExpansion
set ARGS=%*
if defined ARGS set ARGS=%ARGS:"=\"%
if defined ARGS set ARGS=%ARGS:'=''%

:: uses cmdUAC.cmd <https://gist.github.com/neuralpain/4bcc08065fe79e4597eb65ed707be90d>
fsutil dirty query %systemdrive% >nul
if %ERRORLEVEL% NEQ 0 (
  cls & echo.
  echo Please grant admin priviledges.
  echo Attempting to elevate...
  goto UAC_Prompt
) else ( goto :begin_script )

:UAC_Prompt
set n=%0 %*
set n=%n:"=" ^& Chr(34) ^& "%
echo Set objShell = CreateObject("Shell.Application")>"%tmp%\cmdUAC.vbs"
echo objShell.ShellExecute "cmd.exe", "/c start " ^& Chr(34) ^& "." ^& Chr(34) ^& " /d " ^& Chr(34) ^& "%CD%" ^& Chr(34) ^& " cmd /c %n%", "", "runas", ^1>>"%tmp%\cmdUAC.vbs"
cscript "%tmp%\cmdUAC.vbs" //Nologo
del "%tmp%\cmdUAC.vbs"
goto :eof

:begin_script
PowerShell -NoP -C ^"$CMD_NAME='%~n0';Invoke-Expression ('^& {' + (get-content -raw '%~f0') + '} %ARGS%')"
exit /b

# --- PS --- #>

$global:ProgressPreference = "SilentlyContinue"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

$script_name = "installrar"
$winrar = "winrar-x\d{2}-\d{3}\w*\.exe" # catch any version for any language

$LATEST = 701
$Script:WINRAR_EXE = $null
$Script:FETCH_WINRAR = $false
$Script:CUSTOM_DOWNLOAD = $false

$Script:ARCH = $null # download architecture
$Script:RARVER = $null # download version
$Script:TAGS = $null # other download types, eg. language, beta, etc.

function New-Toast {
  [CmdletBinding()]Param ([String]$ToastTitle, [String][parameter(ValueFromPipeline)]$ToastText)
  [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
  $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
  $RawXml = [xml] $Template.GetXml(); ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "1" }).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null; ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "2" }).AppendChild($RawXml.CreateTextNode($ToastText)) > $null
  $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument; $SerializedXml.LoadXml($RawXml.OuterXml);
  $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml); $Toast.Tag = "PowerShell"; $Toast.Group = "PowerShell"; $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)
  $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell"); $Notifier.Show($Toast);
}

function Get-WinRARData {
  $Script:CUSTOM_DOWNLOAD = $true
  $_data = [regex]::matches($CMD_NAME, '[^_]+')
  # `$_data[0]` is the script name
  $Script:ARCH = $_data[1].Value
  $Script:RARVER = $_data[2].Value
  $Script:TAGS = $_data[3].Value
  
  if ($_data[0].Value -ne $script_name) {
    New-Toast -ToastTitle "oneclickwinrar: Error" -ToastText "Script name is invalid."; exit
  }
  if ($Script:ARCH.Length -ne 3) {
    New-Toast -ToastTitle "oneclickwinrar: Error" -ToastText "WinRAR architecture is invalid."; exit
  }
  if ($Script:RARVER.Length -gt 0 -and $Script:RARVER.Length -ne 3) {
    New-Toast -ToastTitle "oneclickwinrar: Error" -ToastText "WinRAR version is invalid."; exit
  }
  if ($Script:ARCH -ne "x64" -and $Script:ARCH -ne "x32") {
    New-Toast -ToastTitle "oneclickwinrar: Error" -ToastText "WinRAR architecture is invalid."; exit
  }
  if ($null -eq $Script:RARVER) {
    $Script:RARVER = $LATEST
  }
}

function Invoke-Installer($file) {
  $x = if ($file -match "(?<version>\d{3})") { ($matches['version']) / 100 } # get WinRAR version number
  Write-Host "Installing WinRAR v${x}..."
  try {
    Start-Process $file "/s" -Wait
  }
  catch {
    New-Toast -ToastTitle "oneclickwinrar: Installation Error" -ToastText "Please restart the script."; exit
  }
  finally {
    if ($Script:FETCH_WINRAR) { Remove-Item $Script:WINRAR_EXE }
  }
}

function Get-Installer {
  $files = Get-ChildItem -Path $pwd | Where-Object { $_.Name -match '^winrar-x' }
  if ($CUSTOM_DOWNLOAD) {
    $exe = "winrar-${Script:ARCH}-${Script:RARVER}${Script:TAGS}.exe"
    foreach ($file in $files) { if ($file -match $exe) { return $file } }
  } else {
    foreach ($file in $files) { if ($file -match $winrar) { return $file } }
  }
}

if ($CMD_NAME -ne $script_name) { Get-WinRARData }

$Script:WINRAR_EXE = (Get-Installer)
if ($null -eq $Script:WINRAR_EXE) {
  Write-Host "Testing connection... " -NoNewLine
  if (Test-Connection www.rarlab.com -Count 2 -Quiet) {
    Write-Host -NoNewLine "OK.`nDownloading WinRAR... "
    try {
      if ($Script:CUSTOM_DOWNLOAD) { Start-BitsTransfer "https://www.rarlab.com/rar/winrar-${Script:ARCH}-${Script:RARVER}${Script:TAGS}.exe" $pwd\ }
      else { Start-BitsTransfer "https://www.rarlab.com/rar/winrar-x64-${LATEST}.exe" $pwd\ }
    }
    catch {
      New-Toast -ToastTitle "oneclickwinrar: Download Error" -ToastText "Please check your internet connection."; exit
    }
    $Script:WINRAR_EXE = (Get-Installer)
    $Script:FETCH_WINRAR = $true
    Write-Host "Done."
  }
  else {
    New-Toast -ToastTitle "oneclickwinrar: Download Error" -ToastText "Please check your internet connection."; exit
  }
}

Invoke-Installer $Script:WINRAR_EXE
New-Toast -ToastTitle "oneclickwinrar" -ToastText "WinRAR installed successfully."; exit
