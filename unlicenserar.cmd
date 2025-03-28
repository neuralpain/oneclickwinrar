<# :# DO NOT REMOVE THIS LINE

:: unlicenserar.cmd
:: Last updated @ v0.9.0.701
:: Copyright (c) 2023, neuralpain
:: Un-license WinRAR

@echo off
mode 44,8
title unlicenserar (v0.10.0.711)
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

$script_name           = "unlicenserar"
$script_name_uninstall = "un-licenserar"

$rarloc    = ""
$loc32     = "${env:ProgramFiles(x86)}\WinRAR"
$loc64     = "$env:ProgramFiles\WinRAR"
$winrar64  = "$loc64\WinRAR.exe"
$winrar32  = "$loc32\WinRAR.exe"

$UNINSTALL = $false

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

# check config
if ($CMD_NAME -ne $script_name) {
  $_data = [regex]::matches($CMD_NAME, '[^_]+')
  if ($_data.Count -eq 1) {
    # user wants to uninstall WinRAR
    if ($_data[0].Value -eq $script_name_uninstall) {
      $UNINSTALL = $true
    }
    else {
      New-Toast -LongerDuration -ActionButtonUrl "https://github.com/neuralpain/oneclickwinrar#customization" -ToastTitle "What script is this?" -ToastText "Script name is invalid. Check the script name for any typos and try again."; exit
    }
  }
}

if (Test-Path $winrar64 -PathType Leaf) { $rarloc = $loc64 }
elseif (Test-Path $winrar32 -PathType Leaf) { $rarloc = $loc32 }
else { New-Toast -ToastTitle "WinRAR is not installed" -ToastText "Check your installation and try again."; exit }

if ($UNINSTALL) {
  if (Test-Path "$rarloc\Uninstall.exe" -PathType Leaf) {
    Start-Process "$rarloc\Uninstall.exe" "/s" -Wait
  }
  New-Toast -ToastTitle "WinRAR uninstalled successfully" -ToastText "Run oneclickrar.cmd to reinstall."; exit
}

# remove license
if (Test-Path "$rarloc\rarreg.key" -PathType Leaf) {
  Remove-Item "$rarloc\rarreg.key" -Force | Out-Null
  New-Toast -ToastTitle "WinRAR unlicensed successfully" -ToastText "Enjoy your 40-day infinite trial period!"; exit
} else {
  New-Toast -ToastTitle "Unable to un-license WinRAR" -ToastText "A WinRAR license was not found on your device."; exit
}
