<# :# DO NOT REMOVE THIS LINE

:: oneclickrar.cmd
:: oneclickwinrar, version 0.6.0.701
:: Copyright (c) 2023, neuralpain
:: Install and license WinRAR

@echo off
mode 44,8
title oneclickrar (v0.6.0.701)
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
  Downloads and installs WinRAR and generates a license for it.

  .DESCRIPTION
  oneclickrar.cmd is a combination of installrar.cmd and
  licenserar.cmd but there are some small modifications to
  that were made to allow the two scripts to work together
  as a single unit.

  .NOTES
  Yes, I wrote this description in PowerShell because its
  the main logic of the script. Bite me :)
#>

$global:ProgressPreference = "SilentlyContinue"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

$script_name = "oneclickrar"
$script_name_overwrite = "oneclick-rar"
$winrar = "winrar-x\d{2}-\d{3}\w*\.exe" # catch any version for any language

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
$Script:FETCH_WINRAR = $false

$Script:OVERWRITE_LICENSE = $false
$Script:CUSTOM_LICENSE = $false
$Script:CUSTOM_DOWNLOAD = $false

$Script:LICENSEE = $null # name of licensee
$Script:LICENSE_TYPE = $null # type of license

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
  $_data = [regex]::matches($CMD_NAME, '[^_]+')
  if ($_data.Count -eq 1) {
    # CHECK OVERWRITE SWITCH
    if ($_data[0].Value -eq $script_name_overwrite) {
      $Script:OVERWRITE_LICENSE = $true
    }
    else {
      New-Toast -ToastTitle "oneclickwinrar: Error" -ToastText "Script name is invalid."; exit
    }
  }
  else {
    <#
      GET DOWNLOAD-ONLY DATA
      there's no need for an overwrite with download-only
      so only verify the script name
    #>
    if ($_data[0].Value -eq $script_name) {
      # verify configuration is within bounds
      if ($_data.Count -gt 1 -and $_data.Count -le 4) {
        $Script:CUSTOM_DOWNLOAD = $true
        # `$_data[0]` is the script name # 1
        $Script:ARCH = $_data[1].Value # 2
        $Script:RARVER = $_data[2].Value # 3 # not required for download
        $Script:TAGS = $_data[3].Value # 4 # not required for download
      }
      else {
        New-Toast -ToastTitle "oneclickwinrar: Error" -ToastText "WinRAR data is invalid."; exit
      }
    }
    # GET DOWNLOAD AND LICENSE DATA
    else {
      # verify script name and check for overwrite switch
      switch ($_data[2].Value) {
        $script_name { break }
        $script_name_overwrite { $Script:OVERWRITE_LICENSE = $true }
        default { New-Toast -ToastTitle "oneclickwinrar: Error" -ToastText "Script name is invalid."; exit }
      }
      # VERIFY CONFIGURATION BOUNDS
      # indicates licensing only
      if ($_data.Count -gt 1 -and $_data.Count -eq 3) {
        $Script:CUSTOM_LICENSE = $true
        $Script:LICENSEE = $_data[0].Value # 1
        $Script:LICENSE_TYPE = $_data[1].Value # 2
        # `$_data[2]` is the script name # 3
      }
      # indicates download and licensing
      elseif ($_data.Count -ge 4 -and $_data.Count -le 6) {
        $Script:CUSTOM_LICENSE = $true
        $Script:CUSTOM_DOWNLOAD = $true
        $Script:LICENSEE = $_data[0].Value # 1
        $Script:LICENSE_TYPE = $_data[1].Value # 2
        # `$_data[2]` is the script name # 3
        $Script:ARCH = $_data[3].Value # 4
        $Script:RARVER = $_data[4].Value # 5 # not required for download
        $Script:TAGS = $_data[5].Value # 6 # not required for download
      }
      else {
        New-Toast -ToastTitle "oneclickwinrar: Error" -ToastText "WinRAR data is invalid."; exit
      }
    }
  }
  # VERIFY DOWNLOAD DATA
  if ($Script:CUSTOM_DOWNLOAD) {
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
  }
  else {
    foreach ($file in $files) { if ($file -match $winrar) { return $file } }
  }
}

if ($CMD_NAME -ne $script_name) { Get-WinRARData }

# --- INSTALLATION

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

# --- LICENSING

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
if (-not(Test-Path $rarreg -PathType Leaf) -or $Script:OVERWRITE_LICENSE) {
  if ($Script:CUSTOM_LICENSE) {
    if (Test-Path $keygen -PathType Leaf) {
      & $keygen "$($Script:LICENSEE)" "$($Script:LICENSE_TYPE)" | Out-File -Encoding utf8 $rarreg
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

New-Toast -ToastTitle "oneclickwinrar" -ToastText "WinRAR installed and licensed successfully."; exit
