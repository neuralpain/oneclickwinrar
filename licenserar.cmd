<# :# DO NOT REMOVE THIS LINE

:: licenserar.cmd
:: oneclickwinrar, version 0.7.0.701
:: Copyright (c) 2023, neuralpain
:: License WinRAR

@echo off
mode 44,8
title licenserar (v0.7.0.701)
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

$script_name = "licenserar"
$script_name_overwrite = "license-rar"

$CUSTOM_LICENSE = $false
$OVERWRITE_LICENSE = $false

$rarkey = "RAR registration data`r`nEveryone`r`nGeneral Public License`r`nUID=119fdd47b4dbe9a41555`r`n6412212250155514920287d3b1cc8d9e41dfd22b78aaace2ba4386`r`n9152c1ac6639addbb73c60800b745269020dd21becbc46390d7cee`r`ncce48183d6d73d5e42e4605ab530f6edf8629596821ca042db83dd`r`n68035141fb21e5da4dcaf7bf57494e5455608abc8a9916ffd8e23d`r`n0a68ab79088aa7d5d5c2a0add4c9b3c27255740277f6edf8629596`r`n821ca04340a7c91e88b14ba087e0bfb04b57824193d842e660c419`r`nb8af4562cb13609a2ca469bf36fb8da2eda6f5e978bf1205660302"
$rarreg64 = "$env:ProgramFiles\WinRAR\rarreg.key"
$rarreg32 = "${env:ProgramFiles(x86)}\WinRAR\rarreg.key"
$rarreg = $null

$winrar64 = "$env:ProgramFiles\WinRAR\WinRAR.exe"
$winrar32 = "${env:ProgramFiles(x86)}\WinRAR\WinRAR.exe"

$keygen64 = "./bin/winrar-keygen/winrar-keygen-x64.exe"
$keygen32 = "./bin/winrar-keygen/winrar-keygen-x86.exe"
$keygen = $null

$LICENSEE = $null
$LICENSE_TYPE = $null

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

# check for custom license
if ($CMD_NAME -ne $script_name) {
  $_data = [regex]::matches($CMD_NAME, '[^_]+')
  if ($_data.Count -eq 1) {
    # user only wants to overwrite the existing license
    if ($_data[0].Value -eq $script_name_overwrite) {
      $OVERWRITE_LICENSE = $true
    }
    else {
      New-Toast -LongerDuration -ActionButtonUrl "https://github.com/neuralpain/oneclickwinrar#customization" -ToastTitle "What script is this?" -ToastText "Script name is invalid. Check the script name for any typos and try again."; exit
    }
  }
  elseif ($_data.Count -gt 3) {
    New-Toast -LongerDuration -ActionButtonUrl "https://github.com/neuralpain/oneclickwinrar#customization" -ToastTitle "Too many arguments!" -ToastText "It seems like you've made a customization error. Check the customization data and try again."; exit
  }
  else {
    # `$_data[2]` is the script name
    $CUSTOM_LICENSE = $true
    switch ($_data[2].Value) {
      $script_name {
        # custom license, script name is valid
        $LICENSEE = $_data[0].Value
        $LICENSE_TYPE = $_data[1].Value
      }
      $script_name_overwrite {
        # custom license, script name is valid, but user
        # wants to overwrite an existing license
        $OVERWRITE_LICENSE = $true
        $LICENSEE = $_data[0].Value
        $LICENSE_TYPE = $_data[1].Value
      }
      default {
        # custom license, but script name is invalid
        New-Toast -ActionButtonUrl "https://github.com/neuralpain/oneclickwinrar#naming-patterns" -ToastTitle "Licensing error" -ToastText "Custom lincense data is invalid. Check the license data and try again."; exit
      }
    }
    # verify custom license data --- this is a sanity check
    # the script should not reach this point, but I'm leaving
    # it here as a precaution just in case I missed something
    if ($LICENSEE.Length -eq 0 -or $LICENSE_TYPE.Length -eq 0) {  
      New-Toast -ActionButtonUrl "https://github.com/neuralpain/oneclickwinrar#naming-patterns" -ToastTitle "Licensing error" -ToastText "Custom lincense data is invalid. Check the license data and try again."; exit
    }
  }
}

# check for WinRAR architecture
if (Test-Path $winrar64 -PathType Leaf) {
  $keygen = $keygen64
  $rarreg = $rarreg64
}
elseif (Test-Path $winrar32 -PathType Leaf) {
  $keygen = $keygen32
  $rarreg = $rarreg32
}
else {
  New-Toast -ToastTitle "WinRAR is not installed" -ToastText "Run installrar.cmd or oneclickrar.cmd to install WinRAR before licensing."; exit
}

# install WinRAR license
if (-not(Test-Path $rarreg -PathType Leaf) -or $OVERWRITE_LICENSE) {
  if ($CUSTOM_LICENSE) {
    if (Test-Path $keygen -PathType Leaf) {
      & $keygen "$($LICENSEE)" "$($LICENSE_TYPE)" | Out-File -Encoding utf8 $rarreg
    }
    else {
      New-Toast -ActionButtonUrl "https://github.com/neuralpain/oneclickwinrar#how-to-use" -ToastTitle "Missing keygen" -ToastText "Unable to generate a license. Ensure that the `"bin`" file is available in the same directory as the script."; exit
    }
  }
  else {
    if (Test-Path "rarreg.key" -PathType Leaf) {
      Copy-Item -Path "rarreg.key" -Destination $rarreg -Force
    }
    else {
      [IO.File]::WriteAllLines($rarreg, $rarkey)
    }
  }
}
else {
  New-Toast -ActionButtonUrl "https://github.com/neuralpain/oneclickwinrar#overwriting-licenses" -ToastTitle "A WinRAR license already exists" -ToastText2 "View the documentation on how to use the override switch to install a new license."; exit
}

if ($CUSTOM_LICENSE) {
  New-Toast -Url "https://ko-fi.com/neuralpain" -ToastTitle "WinRAR licensed successfully" -ToastText "Licensed to `"$($LICENSEE)`"" -ToastText2 "Thanks for using oneclickwinrar!"; exit
}
else {
  New-Toast -Url "https://ko-fi.com/neuralpain" -ToastTitle "WinRAR licensed successfully" -ToastText "Thanks for using oneclickwinrar!"; exit
}
