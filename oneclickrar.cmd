<# :# DO NOT REMOVE THIS LINE

:: oneclickrar.cmd
:: oneclickwinrar, version 0.8.0.701
:: Copyright (c) 2023, neuralpain
:: Install and license WinRAR

@echo off
mode 44,8
title oneclickrar (v0.8.0.701)
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

<#
  .SYNOPSIS
  Install and license WinRAR Archiver.

  .DESCRIPTION
  oneclickrar.cmd is a combination of installrar.cmd and
  licenserar.cmd but there are some small modifications to
  that were made to allow the two scripts to work together
  as a single unit.

  .NOTES
  Yes, I wrote this description in PowerShell because it's
  the main logic of the script. Bite me :)
#>

$global:ProgressPreference = "SilentlyContinue"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

$script_name = "oneclickrar"
$script_name_overwrite = "oneclick-rar"
$script_name_download_only = "one-clickrar"
$script_name_download_only_overwrite = "one-click-rar"
$winrar = "winrar-x\d{2}-\d{3}\w*\.exe" # catch any version for any language
$wrar = "wrar\d{3}\w*\.exe" # catch the old version of WinRAR for any language

$rarkey = "RAR registration data`r`nEveryone`r`nGeneral Public License`r`nUID=119fdd47b4dbe9a41555`r`n6412212250155514920287d3b1cc8d9e41dfd22b78aaace2ba4386`r`n9152c1ac6639addbb73c60800b745269020dd21becbc46390d7cee`r`ncce48183d6d73d5e42e4605ab530f6edf8629596821ca042db83dd`r`n68035141fb21e5da4dcaf7bf57494e5455608abc8a9916ffd8e23d`r`n0a68ab79088aa7d5d5c2a0add4c9b3c27255740277f6edf8629596`r`n821ca04340a7c91e88b14ba087e0bfb04b57824193d842e660c419`r`nb8af4562cb13609a2ca469bf36fb8da2eda6f5e978bf1205660302"
$rarreg64 = "$env:ProgramFiles\WinRAR\rarreg.key"
$rarreg32 = "${env:ProgramFiles(x86)}\WinRAR\rarreg.key"
$rarreg = $null

$winrar64 = "$env:ProgramFiles\WinRAR\WinRAR.exe"
$winrar32 = "${env:ProgramFiles(x86)}\WinRAR\WinRAR.exe"

$keygen64 = "./bin/winrar-keygen/winrar-keygen-x64.exe"
$keygen32 = "./bin/winrar-keygen/winrar-keygen-x86.exe"
$keygen = $null

$LATEST = 701
$Script:WINRAR_EXE = $null
$Script:FETCH_WINRAR = $false # regular WinRAR
$Script:FETCH_WRAR = $false # old 32-bit WinRAR

$Script:OVERWRITE_LICENSE = $false
$Script:CUSTOM_LICENSE = $false
$Script:CUSTOM_DOWNLOAD = $false
$Script:KEEP_DOWNLOAD = $false
$Script:DOWNLOAD_ONLY = $false

$Script:LICENSEE = $null # name of licensee
$Script:LICENSE_TYPE = $null # type of license

$Script:ARCH = $null # download architecture
$Script:RARVER = $null # download version
$Script:TAGS = $null # other download types, i.e. beta, language

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
  <#
    .SYNOPSIS
    Parses the script name to determine the type of operation.

    .DESCRIPTION
    The script name is parsed to determine the type of operation.
    There are three types of operations:
    1. Download and overwrite
    2. License and overwrite
    3. Download, license, and overwrite
  #>
  $_data = [regex]::matches($CMD_NAME, '[^_]+')

  # Download, and overwrite
  # oneclick-rar.cmd
  # oneclickrar___x64_700.cmd
  $SCRIPT_NAME_LOCATION_LEFT = $_data[0]

  # License, download, and overwrite
  # John Doe_License___oneclickrar.cmd
  # John Doe_License___oneclickrar___x64_700.cmd
  $SCRIPT_NAME_LOCATION_MIDDLE_RIGHT = $_data[2]

  # VERIFY SCRIPT NAME
  switch ($SCRIPT_NAME_LOCATION_LEFT.Value) {
    $script_name {
      $SCRIPT_NAME_LOCATION_MIDDLE_RIGHT = $null
      break
    }
    # CHECK FOR OVERWRITE SWITCH
    $script_name_overwrite {
      $Script:OVERWRITE_LICENSE = $true
      $SCRIPT_NAME_LOCATION_MIDDLE_RIGHT = $null
      break
    }
    $script_name_download_only {
      $Script:CUSTOM_DOWNLOAD = $true
      $Script:DOWNLOAD_ONLY = $true
      $Script:KEEP_DOWNLOAD = $true
      $SCRIPT_NAME_LOCATION_MIDDLE_RIGHT = $null
      break
    }
    $script_name_download_only_overwrite {
      $Script:OVERWRITE_LICENSE = $true
      $Script:KEEP_DOWNLOAD = $true
      $SCRIPT_NAME_LOCATION_MIDDLE_RIGHT = $null
      break
    }
    default {
      switch ($SCRIPT_NAME_LOCATION_MIDDLE_RIGHT.Value) {
        $script_name {
          $SCRIPT_NAME_LOCATION_LEFT = $null
          break
        }
        # CHECK FOR OVERWRITE SWITCH
        $script_name_overwrite {
          $Script:OVERWRITE_LICENSE = $true
          $SCRIPT_NAME_LOCATION_LEFT = $null
          break
        }
        $script_name_download_only {
          $Script:CUSTOM_DOWNLOAD = $true
          $Script:DOWNLOAD_ONLY = $true
          $Script:KEEP_DOWNLOAD = $true
          $SCRIPT_NAME_LOCATION_LEFT = $null
          break
        }
        $script_name_download_only_overwrite {
          $Script:OVERWRITE_LICENSE = $true
          # when both overwrite and download-only is set,
          # the function is changed to keep the download
          # but allow installation
          $Script:DOWNLOAD_ONLY = $false
          $Script:KEEP_DOWNLOAD = $true
          $SCRIPT_NAME_LOCATION_LEFT = $null
          break
        }
        default {
          New-Toast -LongerDuration -ActionButtonUrl "https://github.com/neuralpain/oneclickwinrar#customization" -ToastTitle "What script is this?" -ToastText "Script name is invalid. Check the script name for any typos and try again."; exit
        }
      }
    }
  }

  <#
    VERIFY CONFIGURATION BOUNDS
  #>

  # GET DOWNLOAD-ONLY DATA
  if ($_data.Count -gt 1 -and $_data.Count -le 4 -and $null -ne $SCRIPT_NAME_LOCATION_LEFT) {
    $Script:CUSTOM_DOWNLOAD = $true
    # `$_data[0]` is the script name # 1
    $Script:ARCH = $_data[1].Value # 2
    $Script:RARVER = $_data[2].Value # 3 # not required for download
    $Script:TAGS = $_data[3].Value # 4 # not required for download
  }
  # GET LICENSE-ONLY DATA
  elseif ($_data.Count -gt 1 -and $_data.Count -eq 3 -and $null -ne $SCRIPT_NAME_LOCATION_MIDDLE_RIGHT) {
    $Script:CUSTOM_LICENSE = $true
    $Script:LICENSEE = $_data[0].Value # 1
    $Script:LICENSE_TYPE = $_data[1].Value # 2
    # `$_data[2]` is the script name # 3
  }
  # GET DOWNLOAD AND LICENSE DATA
  elseif ($_data.Count -ge 4 -and $_data.Count -le 6 -and $null -ne $SCRIPT_NAME_LOCATION_MIDDLE_RIGHT) {
    $Script:CUSTOM_LICENSE = $true
    $Script:CUSTOM_DOWNLOAD = $true
    $Script:LICENSEE = $_data[0].Value # 1
    $Script:LICENSE_TYPE = $_data[1].Value # 2
    # `$_data[2]` is the script name # 3
    $Script:ARCH = $_data[3].Value # 4
    $Script:RARVER = $_data[4].Value # 5 # not required for download
    $Script:TAGS = $_data[5].Value # 6 # not required for download
  }
  elseif ($_data.Count -ne 1) {
    New-Toast -ActionButtonUrl "https://github.com/neuralpain/oneclickwinrar#customization" -ToastTitle "Unable to process data" -ToastText "WinRAR data is invalid." -ToastText2 "Check your configuration for any errors or typos and try again."; exit
  }

  # VERIFY DOWNLOAD DATA
  if ($Script:CUSTOM_DOWNLOAD) {
    if ($null -eq $Script:ARCH -and $Script:DOWNLOAD_ONLY) {
      $Script:ARCH = "x64" # assume 64-bit download if not specified
    }
    elseif ($Script:ARCH -ne "x64" -and $Script:ARCH -ne "x32") {
      New-Toast -ToastTitle "Unable to process data" -ToastText "The WinRAR architecture is invalid." -ToastText2 "Only x64 and x32 are supported."; exit
    }
    if ($Script:RARVER.Length -gt 0 -and $Script:RARVER.Length -ne 3) {
      New-Toast -ToastTitle "Unable to process data" -ToastText "The WinRAR version is invalid." -ToastText2 "The version number must have 3 digits."; exit
    }
    if ($null -eq $Script:RARVER) {
      $Script:RARVER = $LATEST
    }
  }
}

# --- INSTALLATION

function Invoke-Installer($x, $v) {
  Write-Host "Installing WinRAR $v... " -NoNewLine
  try {
    Start-Process $x "/s" -Wait
    Write-Host "Done."
  }
  catch {
    New-Toast -ToastTitle "Installation error" -ToastText "The script has run into a problem during installation. Please restart the script."; exit
  }
  finally {
    if ($Script:FETCH_WINRAR -and -not $Script:KEEP_DOWNLOAD) { Remove-Item $Script:WINRAR_EXE }
  }
}

function Get-OldInstaller {
  $files = Get-ChildItem -Path $pwd | Where-Object { $_.Name -match '^wrar' }
  if ($CUSTOM_DOWNLOAD) {
    $download = "wrar${Script:RARVER}${Script:TAGS}.exe"
    foreach ($file in $files) { if ($file -match $download) { return $file } }
  } else {
    foreach ($file in $files) { if ($file -match $wrar) { return $file } }
  }
}

function Get-Installer {
  $files = Get-ChildItem -Path $pwd | Where-Object { $_.Name -match '^winrar-x' }
  if ($CUSTOM_DOWNLOAD) {
    if ($Script:RARVER -lt 611 -and $Script:ARCH -eq "x32") {
      # if the user wants to download an older version of 32-bit WinRAR
      $Script:FETCH_WRAR = $true
      Get-OldInstaller
    } else {
      $download = "winrar-${Script:ARCH}-${Script:RARVER}${Script:TAGS}.exe"
      foreach ($file in $files) { if ($file -match $download) { return $file } }
    }
  } else {
    foreach ($file in $files) {
      if ($file -match $winrar) { return $file }
      else { Get-OldInstaller }
    }
  }
}

function Get-WinRARExeVersion {
  param($x, [Switch]$IntToDouble)
  if ($IntToDouble) {
    return "{0:N2}" -f ($x / 100)
  } elseif ($x -match "(?<version>\d{3})") {
    return "{0:N2}" -f ($matches['version'] / 100)
  }
}

# grab the name of the script file and process any
# customization data set by the user
if ($CMD_NAME -ne $script_name) { Get-WinRARData }

# this ensures that the script does not
# unnecessarily download a new installer if one
# is available in the current directory
$Script:WINRAR_EXE = (Get-Installer)

# if there are no installers, proceed to download one
if ($null -eq $Script:WINRAR_EXE) {
  Write-Host "Testing connection... " -NoNewLine
  if (Test-Connection www.rarlab.com -Count 2 -Quiet) {
    # a try-catch block didn't work here, so instead I'm using the
    # `$Error` variable paired with `-ErrorAction SilentlyContinue`
    # to suppress error messages
    if ($Script:CUSTOM_DOWNLOAD) {
      Write-Host -NoNewLine "OK.`nDownloading WinRAR $(Get-WinRARExeVersion $Script:RARVER -IntToDouble)... "
      $Error.Clear()
      if ($Script:FETCH_WRAR) {
        # get older 32-bit WinRAR
        Start-BitsTransfer "https://www.rarlab.com/rar/wrar${Script:RARVER}${Script:TAGS}.exe" $pwd\ -ErrorAction SilentlyContinue
      }
      else {
        Start-BitsTransfer "https://www.rarlab.com/rar/winrar-${Script:ARCH}-${Script:RARVER}${Script:TAGS}.exe" $pwd\ -ErrorAction SilentlyContinue
      }
      if ($Error) {
        New-Toast -ToastTitle "Unable to fetch download" -ToastText "WinRAR $(Get-WinRARExeVersion $Script:RARVER -IntToDouble) may not exist on the server." -ToastText2 "Check the version number and try again."; exit
      }
      if ($Script:DOWNLOAD_ONLY) {
        New-Toast -ToastTitle "Download Complete" -ToastText "WinRAR $(Get-WinRARExeVersion $Script:RARVER -IntToDouble) was successfully downloaded." -ToastText2 "Run this script again if you ever need to install it."; exit
      }
    }
    else {
      Write-Host -NoNewLine "OK.`nDownloading WinRAR $(Get-WinRARExeVersion $LATEST -IntToDouble)... "
      $Error.Clear()
      Start-BitsTransfer "https://www.rarlab.com/rar/winrar-x64-${LATEST}.exe" $pwd\ -ErrorAction SilentlyContinue
      if ($Error) {
        New-Toast -ToastTitle "Unable to fetch download" -ToastText "Are you still connected to the internet?" -ToastText2 "Please check your internet connection."; exit
      }
      # this block is skipped if overwrite is enabled
      if ($Script:DOWNLOAD_ONLY) {
        Write-Host "Done."
        New-Toast -ToastTitle "Download Complete" -ToastText "WinRAR $(Get-WinRARExeVersion $LATEST -IntToDouble) was successfully downloaded." -ToastText2 "Run this script again if you ever need to install it."; exit
      }
    }
    $Script:FETCH_WINRAR = $true # WinRAR was downloaded
    $Script:WINRAR_EXE = (Get-Installer) # get the new installer
    Write-Host "Done."
  }
  else {
    New-Toast -ToastTitle "No internet" -ToastText "Please check your internet connection."; exit
  }
} elseif ($Script:DOWNLOAD_ONLY) {
  New-Toast -ToastTitle "Download Aborted" -ToastText "An installer for WinRAR $(Get-WinRARExeVersion $Script:WINRAR_EXE) already exists." -ToastText2 "Check the requested download version and try again."; exit
}

Invoke-Installer $Script:WINRAR_EXE (Get-WinRARExeVersion $Script:WINRAR_EXE)

# --- LICENSING

# check for WinRAR architecture
# (the final `else` block in `licenserar.cmd` is unnecessary,
# because WinRAR will be installed before the license, else
# the script will exit)
if (Test-Path $winrar64 -PathType Leaf) {
  $keygen = $keygen64
  $rarreg = $rarreg64
}
elseif (Test-Path $winrar32 -PathType Leaf) {
  $keygen = $keygen32
  $rarreg = $rarreg32
}

# install WinRAR license
if (-not(Test-Path $rarreg -PathType Leaf) -or $Script:OVERWRITE_LICENSE) {
  if ($Script:CUSTOM_LICENSE) {
    if (Test-Path $keygen -PathType Leaf) {
      & $keygen "$($Script:LICENSEE)" "$($Script:LICENSE_TYPE)" | Out-File -Encoding utf8 $rarreg
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
  New-Toast -LongerDuration -ToastTitle "WinRAR installed successfully but..." -ActionButtonUrl "https://github.com/neuralpain/oneclickwinrar#overwriting-licenses" -ToastText "Notice: A WinRAR license already exists." -ToastText2 "View the documentation on how to use the override switch to install a new license."; exit
}

if ($CUSTOM_LICENSE) {
  New-Toast -Url "https://youtu.be/OD_WIKht0U0?t=450" -ToastTitle "WinRAR installed and licensed successfully" -ToastText "Licensed to `"$($Script:LICENSEE)`"" -ToastText2 "Freedom throughout the universe!"; exit
}
else {
  New-Toast -Url "https://youtu.be/OD_WIKht0U0?t=450" -ToastTitle "WinRAR installed and licensed successfully" -ToastText "Freedom throughout the universe!"; exit
}
