<#
  oneclickrar.ps1, Version 0.2.0
  Copyright (c) 2025, neuralpain

  .SYNOPSIS
  Install and license WinRAR Archiver.

  .DESCRIPTION
  oneclickrar.ps1 is a modified distribution of the
  PowerShell code within oneclickrar.cmd for use
  specifically within the terminal.
#>

$global:ProgressPreference = "SilentlyContinue"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

$winrar   = "winrar-x\d{2}-\d{3}\w*\.exe"  # catch any version for any language

$rarkey   = "RAR registration data`r`nEveryone`r`nGeneral Public License`r`nUID=119fdd47b4dbe9a41555`r`n6412212250155514920287d3b1cc8d9e41dfd22b78aaace2ba4386`r`n9152c1ac6639addbb73c60800b745269020dd21becbc46390d7cee`r`ncce48183d6d73d5e42e4605ab530f6edf8629596821ca042db83dd`r`n68035141fb21e5da4dcaf7bf57494e5455608abc8a9916ffd8e23d`r`n0a68ab79088aa7d5d5c2a0add4c9b3c27255740277f6edf8629596`r`n821ca04340a7c91e88b14ba087e0bfb04b57824193d842e660c419`r`nb8af4562cb13609a2ca469bf36fb8da2eda6f5e978bf1205660302"
$rarreg64 = "$env:ProgramFiles\WinRAR\rarreg.key"
$rarreg32 = "${env:ProgramFiles(x86)}\WinRAR\rarreg.key"
$rarreg   = $null

$loc32    = "${env:ProgramFiles(x86)}\WinRAR"
$loc64    = "$env:ProgramFiles\WinRAR"
$winrar64 = "$loc64\WinRAR.exe"
$winrar32 = "$loc32\WinRAR.exe"

$freedom_universe_yt_url = "https://youtu.be/OD_WIKht0U0?t=450"

$LATEST                     = 710
$script:WINRAR_EXE          = $null
$script:FETCH_WINRAR        = $false  # regular WinRAR

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
    if ($script:FETCH_WINRAR) { Remove-Item $script:WINRAR_EXE }
  }
}

function Get-Installer {
  $files = Get-ChildItem -Path $pwd | Where-Object { $_.Name -match '^winrar-x' }
  foreach ($file in $files) {
    if ($file -match $winrar) { return $file }
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

# this ensures that the script does not
# unnecessarily download a new installer if one
# is available in the current directory
$script:WINRAR_EXE = (Get-Installer)

# if there are no installers, proceed to download one
if ($null -eq $script:WINRAR_EXE) {
  Write-Host "Testing connection... " -NoNewLine
  if (Test-Connection www.rarlab.com -Count 2 -Quiet) {
    Write-Host -NoNewLine "OK.`nDownloading WinRAR $(Get-WinRARExeVersion $LATEST -IntToDouble)... "
    $Error.Clear()
    Start-BitsTransfer "https://www.rarlab.com/rar/winrar-x64-${LATEST}.exe" $pwd\ -ErrorAction SilentlyContinue
    if ($Error) {
      New-Toast -ToastTitle "Unable to fetch download" -ToastText "Are you still connected to the internet?" -ToastText2 "Please check your internet connection."; exit
    }

    $script:FETCH_WINRAR = $true # WinRAR was downloaded
    $script:WINRAR_EXE = (Get-Installer) # get the new installer
    Write-Host "Done."
  }
  else {
    New-Toast -ToastTitle "No internet" -ToastText "Please check your internet connection."; exit
  }
}

Invoke-Installer $script:WINRAR_EXE (Get-WinRARExeVersion $script:WINRAR_EXE)

# --- LICENSING

# check for WinRAR architecture
if (Test-Path $winrar64 -PathType Leaf) {
  $rarreg = $rarreg64
}
elseif (Test-Path $winrar32 -PathType Leaf) {
  $rarreg = $rarreg32
}

# install WinRAR license
if (-not(Test-Path $rarreg -PathType Leaf)) {
  [IO.File]::WriteAllLines($rarreg, $rarkey)
}
else {
  New-Toast -LongerDuration -ToastTitle "WinRAR installed successfully but..." -ActionButtonUrl "https://github.com/neuralpain/oneclickwinrar#overwriting-licenses" -ToastText "Notice: A WinRAR license already exists." -ToastText2 "Download oneclickrar.cmd to overwrite this license."; exit
}

New-Toast -Url $freedom_universe_yt_url -ToastTitle "WinRAR installed and licensed successfully" -ToastText "Freedom throughout the universe!"; exit
