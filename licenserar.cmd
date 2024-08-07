<# :# DO NOT REMOVE THIS LINE

:: licenserar.cmd
:: oneclickwinrar, version 0.6.1.701
:: Copyright (c) 2023, neuralpain
:: License WinRAR

@echo off
mode 44,8
title licenserar (v0.6.1.701)
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
  [CmdletBinding()]Param ([String]$ToastTitle, [String][parameter(ValueFromPipeline)]$ToastText)
  [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
  $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
  $RawXml = [xml] $Template.GetXml(); ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "1" }).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null; ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "2" }).AppendChild($RawXml.CreateTextNode($ToastText)) > $null
  $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument; $SerializedXml.LoadXml($RawXml.OuterXml);
  $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml); $Toast.Tag = "PowerShell"; $Toast.Group = "PowerShell"; $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)
  $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell"); $Notifier.Show($Toast);
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
      New-Toast -ToastTitle "oneclickwinrar: Error" -ToastText "Script name is invalid."; exit
    }
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
        New-Toast -ToastTitle "oneclickwinrar: License Error" -ToastText "Custom lincense data is invalid."; exit
      }
    }
    # verify custom license data --- this is a sanity check
    # the script should not reach this point, but I'm leaving
    # it here as a precaution just in case I missed something
    if ($LICENSEE.Length -eq 0 -or $LICENSE_TYPE.Length -eq 0) {  
      New-Toast -ToastTitle "oneclickwinrar: License Error" -ToastText "Custom lincense data is invalid."; exit
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
  New-Toast -ToastTitle "oneclickwinrar: Error" -ToastText "WinRAR is not installed. Please run installrar.cmd or oneclickrar.cmd to install WinRAR."; exit
}

# install WinRAR license
if (-not(Test-Path $rarreg -PathType Leaf) -or $OVERWRITE_LICENSE) {
  if ($CUSTOM_LICENSE) {
    if (Test-Path $keygen -PathType Leaf) {
      & $keygen "$($LICENSEE)" "$($LICENSE_TYPE)" | Out-File -Encoding utf8 $rarreg
    }
    else {
      New-Toast -ToastTitle "oneclickwinrar: Missing keygen" -ToastText "Unable to generate license."; exit
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
  New-Toast -ToastTitle "oneclickwinrar: Error" -ToastText "A WinRAR license already exists."; exit
}

New-Toast -ToastTitle "oneclickwinrar" -ToastText "WinRAR licensed successfully."; exit
