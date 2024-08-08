<# :# DO NOT REMOVE THIS LINE

:: installrar.cmd
:: oneclickwinrar, version 0.7.0.701
:: Copyright (c) 2023, neuralpain
:: Install WinRAR

@echo off
mode 44,8
title installrar (v0.7.0.701)
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
  [CmdletBinding()] Param ([String]$AppId = "oneclickwinrar", [String]$Url, [String]$ToastTitle, [String]$ToastText, [String]$ToastText2, [string]$Attribution, [String]$ActionButtonUrl, [String]$ActionButtonText = "Open documentation", [switch]$KeepAlive, [switch]$LongerDuration)
  [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
  $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText04)
  $RawXml = [xml] $Template.GetXml(); ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "1" }).AppendChild($RawXml.CreateTextNode($ToastTitle)) | Out-Null; ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "2" }).AppendChild($RawXml.CreateTextNode($ToastText)) | Out-Null; ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "3" }).AppendChild($RawXml.CreateTextNode($ToastText2)) | Out-Null
  $XmlDocument = New-Object Windows.Data.Xml.Dom.XmlDocument; $XmlDocument.LoadXml($RawXml.OuterXml)
  if ($Url) { $XmlDocument.DocumentElement.SetAttribute("activationType", "protocol"); $XmlDocument.DocumentElement.SetAttribute("launch", $Url) }
  if ($Attribution) { $attrElement = $XmlDocument.CreateElement("text"); $attrElement.SetAttribute("placement", "attribution"); $attrElement.InnerText = $Attribution; $bindingElement = $XmlDocument.SelectSingleNode('//toast/visual/binding'); $bindingElement.AppendChild($attrElement) | Out-Null }
  if ($ActionButtonUrl) { $actionsElement = $XmlDocument.CreateElement("actions"); $actionElement = $XmlDocument.CreateElement("action"); $actionElement.SetAttribute("content", $ActionButtonText); $actionElement.SetAttribute("activationType", "protocol"); $actionElement.SetAttribute("arguments", $ActionButtonUrl); $actionsElement.AppendChild($actionElement) | Out-Null; $XmlDocument.DocumentElement.AppendChild($actionsElement) | Out-Null }
  if ($KeepAlive) { $XmlDocument.DocumentElement.SetAttribute("scenario", "incomingCall") } elseif ($LongerDuration) { $XmlDocument.DocumentElement.SetAttribute("duration", "long") }
  $Toast = [Windows.UI.Notifications.ToastNotification]::new($XmlDocument); $Toast.Tag = "PowerShell"; $Toast.Group = "PowerShell"
  if (-not($KeepAlive -or $LongerDuration)) { $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1) }
  $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId); $Notifier.Show($Toast)
}

function Get-WinRARData {
  $Script:CUSTOM_DOWNLOAD = $true
  $_data = [regex]::matches($CMD_NAME, '[^_]+')
  # `$_data[0]` is the script name
  $Script:ARCH = $_data[1].Value
  $Script:RARVER = $_data[2].Value
  $Script:TAGS = $_data[3].Value
  
  if ($_data[0].Value -ne $script_name) {
    New-Toast -LongerDuration -ActionButtonUrl "https://github.com/neuralpain/oneclickwinrar#customization" -ToastTitle "What script is this?" -ToastText "Script name is invalid. Check the script name for any typos and try again."; exit
  }
  if ($Script:ARCH -ne "x64" -and $Script:ARCH -ne "x32") {
    New-Toast -ToastTitle "Unable to process data" -ToastText "The WinRAR architecture is invalid." -ToastText2 "Only x64 and x32 are supported."; exit
  }
  if ($Script:RARVER.Length -gt 0 -and $Script:RARVER.Length -ne 3) {
    New-Toast -ToastTitle "Unable to process data" -ToastText "The WinRAR version is invalid." -ToastText2 "The version number must have 3 digits."; exit
  }
  if ($null -eq $Script:RARVER) {
    $Script:RARVER = $LATEST
  }
}

function Invoke-Installer($file) {
  $x = if ($file -match "(?<version>\d{3})") { "{0:N2}" -f ($matches['version'] / 100) } # get WinRAR version number
  Write-Host "Installing WinRAR v${x}... " -NoNewLine
  try {
    Start-Process $file "/s" -Wait
    Write-Host "Done."
  }
  catch {
    New-Toast -ToastTitle "Installation error" -ToastText "The script has run into a problem during installation. Please restart the script."; exit
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
    # a try-catch block did not work here, so instead I'm using the
    # `$Error` variable paired with `-ErrorAction SilentlyContinue`
    # to suppress error messages
    if ($Script:CUSTOM_DOWNLOAD) {
      $Error.Clear()
      Start-BitsTransfer "https://www.rarlab.com/rar/winrar-${Script:ARCH}-${Script:RARVER}${Script:TAGS}.exe" $pwd\ -ErrorAction SilentlyContinue
      if ($Error) {
        New-Toast -ToastTitle "Unable to fetch download" -ToastText "WinRAR version may not exist on the server." -ToastText2 "Check the version number and try again."; exit
      }
    }
    else {
      $Error.Clear()
      Start-BitsTransfer "https://www.rarlab.com/rar/winrar-x64-${LATEST}.exe" $pwd\ -ErrorAction SilentlyContinue
      if ($Error) {
        New-Toast -ToastTitle "Unable to fetch download" -ToastText "Please check your internet connection."; exit
      }
    }
    $Script:WINRAR_EXE = (Get-Installer)
    $Script:FETCH_WINRAR = $true
    Write-Host "Done."
  }
  else {
    New-Toast -ToastTitle "No internet" -ToastText "Please check your internet connection."; exit
  }
}

Invoke-Installer $Script:WINRAR_EXE

New-Toast -Url "https://ko-fi.com/neuralpain" -ToastTitle "WinRAR installed successfully" -ToastText2 "Thanks for using oneclickwinrar!"; exit
