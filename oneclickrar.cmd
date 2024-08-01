<# :# DO NOT REMOVE THIS LINE

:: oneclickrar.cmd
:: oneclickwinrar, version 0.5.0.701
:: Copyright (c) 2023, neuralpain
:: Install and license WinRAR

@echo off
mode 44,8
title oneclickrar (v0.5.0.701)
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

$Script:WINRAR_EXE = $null
$Script:FETCH_WINRAR = $false
$winrar = "winrar-x\d{2}-\d{3}\w*\.exe" # catch any version for any language

$Script:ARCH64 = $true;
$Script:CUSTOM_LICENSE = $false;
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
  # check for custom license and download
  if ($_data.Count -eq 3 -and $_data[2].Value -eq "oneclickrar") {
    $Script:CUSTOM_LICENSE = $true
    $Script:LICENSEE = $_data[0].Value
    $Script:LICENSE_TYPE = $_data[1].Value
    # `$_data[2]` is the script name
  }
  elseif ($_data.Count -ge 3 -and $_data[0].Value -eq "oneclickrar") {
    $Script:CUSTOM_DOWNLOAD = $true
    # `$_data[0]` is the script name
    $Script:ARCH = $_data[1].Value
    $Script:RARVER = $_data[2].Value
    $Script:TAGS = $_data[3].Value
  }
  elseif ($_data.Count -ge 5 -and $_data[2].Value -eq "oneclickrar") {
    $Script:CUSTOM_LICENSE = $true
    $Script:CUSTOM_DOWNLOAD = $true
    $Script:LICENSEE = $_data[0].Value
    $Script:LICENSE_TYPE = $_data[1].Value
    # `$_data[2]` is the script name
    $Script:ARCH = $_data[3].Value
    $Script:RARVER = $_data[4].Value
    $Script:TAGS = $_data[5].Value
  }
  else {
    New-Toast -ToastTitle "oneclickwinrar: Error" -ToastText "WinRAR data is invalid."; exit
  }
  
  if ($Script:CUSTOM_DOWNLOAD) {
    if ($Script:ARCH.Length -ne 3 -or $Script:RARVER.Length -ne 3) {
      New-Toast -ToastTitle "oneclickwinrar: Error" -ToastText "Download data is invalid."; exit
    }
    if ($Script:ARCH -ne "x64" -and $Script:ARCH -ne "x86") {
      New-Toast -ToastTitle "oneclickwinrar: Error" -ToastText "Download architecture is invalid."; exit
    }
  }
}

function Invoke-Installer($file) {
  $version = if ($file -match "(?<version>\d{3})") { ($matches['version']) / 100 } # get WinRAR version number
  Write-Host "Installing WinRAR v${version}..."
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
  foreach ($file in $files) { if ($file -match $winrar) { return $file } }
}

if ($CMD_NAME -ne "oneclickrar") { Get-WinRARData }

# --- INSTALLATION

$Script:WINRAR_EXE = (Get-Installer)
if ($null -eq $Script:WINRAR_EXE) {
  Write-Host "Testing connection... " -NoNewLine
  if (Test-Connection www.google.com -Quiet) {
    Write-Host -NoNewLine "OK.`nDownloading WinRAR... "
    try {
      if ($Script:CUSTOM_DOWNLOAD) { Start-BitsTransfer "https://www.rarlab.com/rar/winrar-${Script:ARCH}-${Script:RARVER}${Script:TAGS}.exe" $pwd\ }
      else { Start-BitsTransfer "https://www.rarlab.com/rar/winrar-x64-701.exe" $pwd\ }
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

$rarkey = "RAR registration data`r`nEveryone`r`nGeneral Public License`r`nUID=119fdd47b4dbe9a41555`r`n6412212250155514920287d3b1cc8d9e41dfd22b78aaace2ba4386`r`n9152c1ac6639addbb73c60800b745269020dd21becbc46390d7cee`r`ncce48183d6d73d5e42e4605ab530f6edf8629596821ca042db83dd`r`n68035141fb21e5da4dcaf7bf57494e5455608abc8a9916ffd8e23d`r`n0a68ab79088aa7d5d5c2a0add4c9b3c27255740277f6edf8629596`r`n821ca04340a7c91e88b14ba087e0bfb04b57824193d842e660c419`r`nb8af4562cb13609a2ca469bf36fb8da2eda6f5e978bf1205660302"
$rarreg = "$env:ProgramFiles\WinRAR\rarreg.key"
$rarg32 = "${env:ProgramFiles(x86)}\WinRAR\rarreg.key"

# check for WinRAR architecture
if (Test-Path "$env:ProgramFiles\WinRAR\WinRAR.exe" -PathType Leaf) {
  $Script:ARCH64 = $true
}
elseif (Test-Path "${env:ProgramFiles(x86)}\WinRAR\WinRAR.exe" -PathType Leaf) {
  $Script:ARCH64 = $false
}
else {
  New-Toast -ToastTitle "oneclickwinrar: Erorr" -ToastText "WinRAR is not installed."; exit
}

# generate license
if ($Script:ARCH64) {
  if ($Script:CUSTOM_LICENSE) {
    if (Test-Path "bin/winrar-keygen/winrar-keygen-x64.exe" -PathType Leaf) {
      ./bin/winrar-keygen/winrar-keygen-x64.exe "$($Script:LICENSEE)" "$($Script:LICENSE_TYPE)" | Out-File -Encoding utf8 $rarreg
    }
    else {
      New-Toast -ToastTitle "oneclickwinrar: Missing keygen" -ToastText "Unable to generate license."; exit
    }
  }
  elseif (Test-Path "rarreg.key" -PathType Leaf) {
    Copy-Item -Path "rarreg.key" -Destination $rarreg -Force
  }
  else {
    [IO.File]::WriteAllLines($rarreg, $rarkey)
  }
}
else {
  if ($Script:CUSTOM_LICENSE) {
    if (Test-Path "bin/winrar-keygen/winrar-keygen-x86.exe" -PathType Leaf) {
      ./bin/winrar-keygen/winrar-keygen-x86.exe "$($Script:LICENSEE)" "$($Script:LICENSE_TYPE)" | Out-File -Encoding utf8 $rarg32
    }
    else {
      New-Toast -ToastTitle "oneclickwinrar: Missing keygen" -ToastText "Unable to generate license."; exit
    }
  }
  elseif (Test-Path "rarreg.key" -PathType Leaf) {
    Copy-Item -Path "rarreg.key" -Destination $rarg32 -Force
  }
  else {
    [IO.File]::WriteAllLines($rarg32, $rarkey)
  }
}

New-Toast -ToastTitle "oneclickwinrar" -ToastText "WinRAR installed and licensed successfully."; exit
