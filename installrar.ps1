<#
  installrar.ps1
  Version 0.10.0.710
  Copyright (c) 2025, neuralpain
  Install and license WinRAR

  .SYNOPSIS
  Install and license WinRAR Archiver.

  .DESCRIPTION
  installrar.ps1 is a distribution of the PowerShell code
  within installrar.cmd for use specifically within the
  terminal.
#>

$global:ProgressPreference = "SilentlyContinue"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

$script_name            = "installrar"
$winrar                 = "winrar-x\d{2}-\d{3}\w*\.exe" # catch any version for any language
$wrar                   = "wrar\d{3}\w*\.exe" # catch the old version of WinRAR for any language

$CMD_NAME = $script_name

$LATEST                 = 710
$script:WINRAR_EXE      = $null
$script:FETCH_WINRAR    = $false # regular WinRAR
$script:FETCH_WRAR      = $false # old 32-bit WinRAR
$script:CUSTOM_DOWNLOAD = $false

$script:ARCH            = $null # download architecture
$script:RARVER          = $null # download version
$script:TAGS            = $null # other download types, i.e. beta, language

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
  $script:CUSTOM_DOWNLOAD = $true
  $_data = [regex]::matches($CMD_NAME, '[^_]+')

  # `$_data[0]` is the script name
  $script:ARCH   = $_data[1].Value
  $script:RARVER = $_data[2].Value
  $script:TAGS   = $_data[3].Value

  if ($_data[0].Value -ne $script_name) {
    New-Toast -LongerDuration -ActionButtonUrl "https://github.com/neuralpain/oneclickwinrar#customization" -ToastTitle "What script is this?" -ToastText "Script name is invalid. Check the script name for any typos and try again."; exit
  }
  # architecture is omitted if the data does not contain an `x`
  if (([regex]::matches($script:ARCH, 'x')).Count -eq 0) {
    # copy config to correct variables (LIFO)
    $script:TAGS   = $script:RARVER
    $script:RARVER = $script:ARCH
    $script:ARCH   = "x64" # assume 64-bit
  }
  if ($script:ARCH -ne "x64" -and $script:ARCH -ne "x32") {
    New-Toast -ToastTitle "Unable to process data" -ToastText "The WinRAR architecture is invalid." -ToastText2 "Only x64 and x32 are supported."; exit
  }
  if (-not($script:RARVER.Length -ge 3) -and $script:RARVER -lt 100) {
    New-Toast -ToastTitle "Unable to process data" -ToastText "The WinRAR version is invalid." -ToastText2 "The version number must have 3 digits."; exit
  }
  if ($null -eq $script:RARVER) {
    $script:RARVER = $LATEST
  }
}

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
    if ($script:RARVER -lt 611 -and $script:ARCH -eq "x32") {
      # if the user wants to download an older version of 32-bit WinRAR
      $script:FETCH_WRAR = $true
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

# --- MAIN ---

# grab the name of the script file and process any
# customization data set by the user
if ($CMD_NAME -ne $script_name) { Get-WinRARData }

# this ensures that the script does not
# unnecessarily download a new installer if one
# is available in the current directory
$script:WINRAR_EXE = (Get-Installer)

# if there are no installers, proceed to download one
if ($null -eq $script:WINRAR_EXE) {
  Write-Host "Testing connection... " -NoNewLine
  if (Test-Connection www.rarlab.com -Count 2 -Quiet) {
    # a try-catch block didn't work here, so instead I'm using the
    # `$Error` variable paired with `-ErrorAction SilentlyContinue`
    # to suppress error messages
    if ($script:CUSTOM_DOWNLOAD) {
      Write-Host -NoNewLine "OK.`nDownloading WinRAR $(Get-WinRARExeVersion $script:RARVER -IntToDouble)... "
      $Error.Clear()
      if ($script:FETCH_WRAR) {
        # get older 32-bit WinRAR
        Start-BitsTransfer "https://www.rarlab.com/rar/wrar${Script:RARVER}${Script:TAGS}.exe" $pwd\ -ErrorAction SilentlyContinue
      }
      else {
        Start-BitsTransfer "https://www.rarlab.com/rar/winrar-${Script:ARCH}-${Script:RARVER}${Script:TAGS}.exe" $pwd\ -ErrorAction SilentlyContinue
      }
      if ($Error) {
        New-Toast -ToastTitle "Unable to fetch download" -ToastText "WinRAR $(Get-WinRARExeVersion $script:RARVER -IntToDouble) may not exist on the server." -ToastText2 "Check the version number and try again."; exit
      }
    }
    else {
      Write-Host -NoNewLine "OK.`nDownloading WinRAR $(Get-WinRARExeVersion $LATEST -IntToDouble)... "
      $Error.Clear()
      Start-BitsTransfer "https://www.rarlab.com/rar/winrar-x64-${LATEST}.exe" $pwd\ -ErrorAction SilentlyContinue
      if ($Error) {
        New-Toast -ToastTitle "Unable to fetch download" -ToastText "Are you still connected to the internet?" -ToastText2 "Please check your internet connection."; exit
      }
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

New-Toast -Url "https://ko-fi.com/neuralpain" -ToastTitle "WinRAR installed successfully" -ToastText2 "Thanks for using oneclickwinrar!"; exit
