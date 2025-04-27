<# :# DO NOT REMOVE THIS LINE

:: oneclickrar.cmd
:: Last updated @ v0.11.0.711
:: Copyright (c) 2023, neuralpain
:: Install and license WinRAR

@echo off
title oneclickrar (v0.11.0.711)
mode 48,12
:: uses PwshBatch.cmd <https://gist.github.com/neuralpain/4ca8a6c9aca4f0a1af2440f474e92d05>
setlocal EnableExtensions DisableDelayedExpansion
set ARGS=%*
if defined ARGS set ARGS=%ARGS:"=\"%
if defined ARGS set ARGS=%ARGS:'=''%

:: uses cmdUAC.cmd <https://gist.github.com/neuralpain/4bcc08065fe79e4597eb65ed707be90d>
fsutil dirty query %systemdrive% >nul
if %ERRORLEVEL% NEQ 0 (
  cls & echo.
  echo Please grant admin privileges.
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
#>

$global:ProgressPreference = "SilentlyContinue"
# ([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -contains "S-1-5-32-544"
# ([System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

$script_name                         = "oneclickrar"
$script_name_overwrite               = "oneclick-rar"
$script_name_download_only           = "one-clickrar"
$script_name_download_only_overwrite = "one-click-rar"

$winrar   = "winrar-x\d{2}-\d{3}\w*\.exe"                                       # catch any version for any language
$wrar     = "wrar\d{3}\w*\.exe"                                                 # catch the old version of WinRAR for any language

$rarkey   = "RAR registration data`r`nEveryone`r`nGeneral Public License`r`nUID=119fdd47b4dbe9a41555`r`n6412212250155514920287d3b1cc8d9e41dfd22b78aaace2ba4386`r`n9152c1ac6639addbb73c60800b745269020dd21becbc46390d7cee`r`ncce48183d6d73d5e42e4605ab530f6edf8629596821ca042db83dd`r`n68035141fb21e5da4dcaf7bf57494e5455608abc8a9916ffd8e23d`r`n0a68ab79088aa7d5d5c2a0add4c9b3c27255740277f6edf8629596`r`n821ca04340a7c91e88b14ba087e0bfb04b57824193d842e660c419`r`nb8af4562cb13609a2ca469bf36fb8da2eda6f5e978bf1205660302"
$rarreg64 = "$env:ProgramFiles\WinRAR\rarreg.key"
$rarreg32 = "${env:ProgramFiles(x86)}\WinRAR\rarreg.key"
$rarreg   = $null

$rarloc   = ""
$loc32    = "${env:ProgramFiles(x86)}\WinRAR"
$loc64    = "$env:ProgramFiles\WinRAR"
$winrar64 = "$loc64\WinRAR.exe"
$winrar32 = "$loc32\WinRAR.exe"

$keygen64 = "./bin/winrar-keygen/winrar-keygen-x64.exe"
$keygen32 = "./bin/winrar-keygen/winrar-keygen-x86.exe"
$keygen   = $null

$server1_host = "www.rarlab.com"
$server1      = "https://$server1_host/rar"
$server2_host = "www.win-rar.com"
$server2      = @("https://$server2_host/fileadmin/winrar-versions", "https://$server2_host/fileadmin/winrar-versions/winrar")

$freedom_universe_yt_url = "https://youtu.be/OD_WIKht0U0?t=450"

$link_overwriting = "https://github.com/neuralpain/oneclickwinrar#overwriting-licenses"
$link_howtouse = "https://github.com/neuralpain/oneclickwinrar#how-to-use"
$link_customization = "https://github.com/neuralpain/oneclickwinrar#customization"
$link_endof32bitsupport = "https://www.win-rar.com/singlenewsview.html?&L=0&tx_ttnews%5Btt_news%5D=266&cHash=44c8cdb0ff6581307702dfe4892a3fb5"

$LATEST                     = 711
$script:WINRAR_EXE          = $null
$script:FETCH_WINRAR        = $false                                            # Download standard WinRAR
$script:FETCH_WRAR          = $false                                            # Download old 32-bit WinRAR naming scheme
$script:WINRAR_IS_INSTALLED = $false

$script:CUSTOM_DOWNLOAD     = $false
$script:DOWNLOAD_ONLY       = $false
$script:KEEP_DOWNLOAD       = $false

$script:LICENSEE            = $null
$script:LICENSE_TYPE        = $null
$script:LICENSE_ONLY        = $false
$script:CUSTOM_LICENSE      = $false
$script:SKIP_LICENSING      = $false
$script:OVERWRITE_LICENSE   = $false

$script:ARCH                = $null                                             # Download architecture
$script:RARVER              = $null                                             # WinRAR version
$script:TAGS                = $null                                             # Other download types, i.e. beta, language

$script:SCRIPT_NAME_LOCATION_LEFT         = $null
$script:SCRIPT_NAME_LOCATION_MIDDLE_RIGHT = $null

# check if WinRAR is installed before begin
if (Test-Path $winrar64 -PathType Leaf) {
  $rarloc = $loc64
  $script:WINRAR_IS_INSTALLED = $true
}
elseif (Test-Path $winrar32 -PathType Leaf) {
  $rarloc = $loc32
  $script:WINRAR_IS_INSTALLED = $true
}

$SetDefaultArchVersion = {
  if ($null -eq $script:ARCH) { $script:ARCH = "x64" }
  if ($null -eq $script:RARVER) { $script:RARVER = $LATEST }
}

$Error_UnknownScript = { New-Toast -LongerDuration -ActionButtonUrl "$link_customization" -ToastTitle "What script is this?" -ToastText  "Script name is invalid. Check the script name for any typos and try again." }
$Error_UnableToProcess = { New-Toast -ActionButtonUrl "$link_customization" -ToastTitle "Unable to process data" -ToastText "WinRAR data is invalid." -ToastText2 "Check your configuration for any errors or typos and try again." }
$Error_No32bitSupport = { New-Toast -LongerDuration -ActionButtonUrl "$link_endof32bitsupport"  -ActionButtonText "Read More" -ToastTitle "Unable to process data" -ToastText "WinRAR no longer supports 32-bit on newer versions." -ToastText2 "Check your configuration for any errors or typos and try again." }
$Error_InvalidArchitecture = { New-Toast -ToastTitle "Unable to process data" -ToastText "The WinRAR architecture is invalid." -ToastText2 "Only x64 and x32 are supported." }
$Error_InvalidVersionNumber = { New-Toast -ToastTitle "Unable to process data" -ToastText "The WinRAR version is invalid." -ToastText2 "The version number must have 3 digits." }

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

function Get-SpecialCode($code) {
  switch ($code) {
    0 {
      if ($script:WINRAR_IS_INSTALLED -and (Test-Path "$rarloc\Uninstall.exe" -PathType Leaf)) {
        Write-Host -NoNewLine "Uninstalling WinRAR... "
        Start-Process "$rarloc\Uninstall.exe" "/s" -Wait
        $script:WINRAR_IS_INSTALLED = $false # unnecessary to add this here but logically correct
        New-Toast -ToastTitle "WinRAR uninstalled successfully" -ToastText "Run oneclickrar.cmd to reinstall."; exit
      } else {
        New-Toast -ToastTitle "WinRAR is not installed" -ToastText "Check your installation and try again."; exit
      }
    }
    1 {
      Write-Host -NoNewLine "Un-licensing WinRAR... "
      if (Test-Path "$rarloc\rarreg.key" -PathType Leaf) {
        Remove-Item "$rarloc\rarreg.key" -Force | Out-Null
        New-Toast -ToastTitle "WinRAR unlicensed successfully" -ToastText "Enjoy your 40-day infinite trial period!"; exit
      } else {
        New-Toast -ToastTitle "Unable to un-license WinRAR" -ToastText "A WinRAR license was not found on your device."; exit
      }
    }
    2 { $script:SKIP_LICENSING = $true; break }
    3 { $script:LICENSE_ONLY   = $true; break }
    default { break }
  }
}

# TODO - review this function with new changes

function Get-SpecialFunctionCode($_data) {
  if ([regex]::matches($_data[0], 'rar') -and -not [regex]::matches($_data[0], 'i')) {
    $switch_code = ([regex]::matches($_data[0], '\d+'))[0].Value
    $switch_one  = ([regex]::matches($_data[0], 'one-'))[0].Value
    $switch_rar  = ([regex]::matches($_data[0], '-rar'))[0].Value

    if ($null -ne $switch_one -and $null -ne $switch_rar) {
      $script:SCRIPT_NAME_LOCATION_LEFT = $script_name_download_only_overwrite
    } elseif ($null -ne $switch_one) {
      $script:SCRIPT_NAME_LOCATION_LEFT = $script_name_download_only
    } elseif ($null -ne $switch_rar) {
      $script:SCRIPT_NAME_LOCATION_LEFT = $script_name_overwrite
    } else {
      $script:SCRIPT_NAME_LOCATION_LEFT = $script_name
    }
  }
  elseif ([regex]::matches($_data[2], 'rar') -and -not [regex]::matches($_data[2], 'i')) {
    $switch_code = ([regex]::matches($_data[2], '\d+'))[0].Value
    $switch_one  = ([regex]::matches($_data[2], 'one-'))[0].Value
    $switch_rar  = ([regex]::matches($_data[2], '-rar'))[0].Value

    if ($null -ne $switch_one -and $null -ne $switch_rar) {
      $script:SCRIPT_NAME_LOCATION_MIDDLE_RIGHT = $script_name_download_only_overwrite
    } elseif ($null -ne $switch_one) {
      $script:SCRIPT_NAME_LOCATION_MIDDLE_RIGHT = $script_name_download_only
    } elseif ($null -ne $switch_rar) {
      $script:SCRIPT_NAME_LOCATION_MIDDLE_RIGHT = $script_name_overwrite
    } else {
      $script:SCRIPT_NAME_LOCATION_MIDDLE_RIGHT = $script_name
    }
  }

  Get-SpecialCode $switch_code
}

function Get-WinRARData {
  <#
    .SYNOPSIS
    Parse the script name and determine the type of operation.

    .DESCRIPTION
    The script name is parsed to determine the type of operation.
    There are three types of operations:
    1. Download and overwrite
    2. License and overwrite
    3. Download, license, and overwrite
  #>

  $local:custom_name = $null
  $_data = [regex]::matches($CMD_NAME, '[^_]+')

  # Download, and overwrite
  # oneclick-rar.cmd
  # oneclickrar_x64_700.cmd
  $script:SCRIPT_NAME_LOCATION_LEFT = $_data[0]

  # License, download, and overwrite
  # John Doe_License_oneclickrar.cmd
  # John Doe_License_oneclickrar_x64_700.cmd
  $script:SCRIPT_NAME_LOCATION_MIDDLE_RIGHT = $_data[2]

  Get-SpecialFunctionCode $_data

  if ($script:SCRIPT_NAME_LOCATION_LEFT) {
    $script:SCRIPT_NAME_LOCATION_MIDDLE_RIGHT = $null
    $local:custom_name = $script:SCRIPT_NAME_LOCATION_LEFT
    if ($_data.Count -gt 1 -and $_data.Count -le 4) {                           # GET DOWNLOAD-ONLY DATA
      $script:CUSTOM_DOWNLOAD = $true
      # `$_data[0]` is the script name # 1
      $script:ARCH   = $_data[1].Value # 2
      $script:RARVER = $_data[2].Value # 3                                      # Not required for download
      $script:TAGS   = $_data[3].Value # 4                                      # Not required for download
    }
    elseif ($_data.Count -ne 1) { &$Error_UnableToProcess; exit }               # data out of bounds
  }
  elseif ($script:SCRIPT_NAME_LOCATION_MIDDLE_RIGHT) {
    $script:SCRIPT_NAME_LOCATION_LEFT = $null
    $local:custom_name = $script:SCRIPT_NAME_LOCATION_MIDDLE_RIGHT
    if ($_data.Count -gt 1 -and $_data.Count -eq 3) {                           # GET LICENSE-ONLY DATA
      $script:CUSTOM_LICENSE = $true
      $script:LICENSEE       = $_data[0].Value # 1
      $script:LICENSE_TYPE   = $_data[1].Value # 2
      # `$_data[2]` is the script name         # 3
    }
    elseif ($_data.Count -ge 4 -and $_data.Count -le 6) {                       # GET DOWNLOAD AND LICENSE DATA
      $script:CUSTOM_LICENSE  = $true
      $script:CUSTOM_DOWNLOAD = $true
      $script:LICENSEE        = $_data[0].Value # 1
      $script:LICENSE_TYPE    = $_data[1].Value # 2
      # `$_data[2]` is the script name # 3
      $script:ARCH   = $_data[3].Value # 4
      $script:RARVER = $_data[4].Value # 5                                      # Not required for download
      $script:TAGS   = $_data[5].Value # 6                                      # Not required for download
    }
    elseif ($_data.Count -ne 1) { &$Error_UnableToProcess; exit }               # Data out of bounds
  } else { &$Error_UnknownScript; exit }

  # VERIFY SCRIPT NAME
  switch ($local:custom_name) {
    $script_name { break }
    $script_name_overwrite {
      $script:OVERWRITE_LICENSE = $true
      break
    }
    $script_name_download_only {
      $script:DOWNLOAD_ONLY = $true
      $script:KEEP_DOWNLOAD = $true
      break
    }
    $script_name_download_only_overwrite {
      $script:OVERWRITE_LICENSE = $true
      # when both overwrite and download-only is set, the function is changed
      # to keep the download but allow installation
      $script:DOWNLOAD_ONLY = $false
      $script:KEEP_DOWNLOAD = $true
      break
    }
    default { &$Error_UnknownScript; exit }
  }

  &$SetDefaultArchVersion

  # VERIFY DOWNLOAD DATA
  if ($script:CUSTOM_DOWNLOAD) {
    if (([regex]::matches($script:ARCH, 'x')).Count -eq 0) {                    # architecture is omitted if the data does not contain an `x`
      # Copy the config to the correct variables (LIFO)
      $script:TAGS   = $script:RARVER
      $script:RARVER = $script:ARCH
      $script:ARCH   = "x64" # assume 64-bit
    }
    if ($script:ARCH -ne "x64" -and $script:ARCH -ne "x32") {
      &$Error_InvalidArchitecture; exit
    }
    if (-not($script:RARVER.Length -ge 3) -and $script:RARVER -lt 100) {
      &$Error_InvalidVersionNumber; exit
    }
    if ($script:ARCH -eq "x32" -and $script:RARVER -gt 701) {
      &$Error_No32bitSupport; exit
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
    if ($script:FETCH_WINRAR -and -not $script:KEEP_DOWNLOAD) {
      Remove-Item $script:WINRAR_EXE
    }
  }
}

function Get-OldInstaller {
  $files = Get-ChildItem -Path $pwd | Where-Object { $_.Name -match '^wrar' }
  if ($CUSTOM_DOWNLOAD) {
    $download = "wrar${script:RARVER}${script:TAGS}.exe"
    foreach ($file in $files) {
      if ($file -match $download) { return $file }
    }
  } else {
    foreach ($file in $files) {
      if ($file -match $wrar) { return $file }
    }
  }
}

function Get-Installer {
  $files = Get-ChildItem -Path $pwd | Where-Object { $_.Name -match '^winrar-x' }
  if ($CUSTOM_DOWNLOAD) {
    if ($script:RARVER -lt 611 -and $script:ARCH -eq "x32") {
      $script:FETCH_WRAR = $true
      Get-OldInstaller
    } else {
      $script:FETCH_WINRAR = $true
      $download = "winrar-${script:ARCH}-${script:RARVER}${script:TAGS}.exe"
      foreach ($file in $files) {
        if ($file -match $download) { return $file }
      }
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

  $v =  if ($IntToDouble) { $x }
        elseif ($x -match "(?<version>\d{3})") { $matches['version'] }
        else { return $null }

  return "{0:N2}" -f ($v / 100)
}

function Add-WinRarLicense {
  if (Test-Path $winrar64 -PathType Leaf) {
    $keygen = $keygen64
    $rarreg = $rarreg64
  }
  elseif (Test-Path $winrar32 -PathType Leaf) {
    $keygen = $keygen32
    $rarreg = $rarreg32
  }
  else {
    New-Toast -ToastTitle "WinRAR is not installed" -ToastText "Run this script to install WinRAR before licensing."; exit
  }

  # install WinRAR license
  if (-not(Test-Path $rarreg -PathType Leaf) -or $script:OVERWRITE_LICENSE) {
    if ($script:CUSTOM_LICENSE) {
      if (Test-Path $keygen -PathType Leaf) {
        &$keygen "$($script:LICENSEE)" "$($script:LICENSE_TYPE)" | Out-File -Encoding utf8 $rarreg
      }
      else {
        New-Toast -ActionButtonUrl "$link_howtouse" `
                  -ToastTitle "Missing `"bin`" folder" `
                  -ToastText  "Unable to generate a license. Ensure that the `"bin`" file is available in the same directory as the script."; exit
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
    if ($script:LICENSE_ONLY) {
      New-Toast -LongerDuration `
                -ToastTitle "Unable to license WinRAR" `
                -ActionButtonUrl "$link_overwriting" `
                -ToastText  "Notice: A WinRAR license already exists." `
                -ToastText2 "View the documentation on how to use the override switch to install a new license."; exit
    } else {
      New-Toast -LongerDuration `
                -ToastTitle "WinRAR installed successfully but..." `
                -ActionButtonUrl "$link_overwriting" `
                -ToastText  "Notice: A WinRAR license already exists." `
                -ToastText2 "View the documentation on how to use the override switch to install a new license."; exit
    }
  }
}

function Get-WinRarInstaller {
  param($HostUri, $HostUriDir)
  Write-Host "Connecting to $HostUri... " -NoNewLine
  if (Test-Connection "$HostUri" -Count 2 -Quiet) {
    Write-Host -NoNewLine "OK.`nDownloading WinRAR $(Get-WinRARExeVersion $script:RARVER -IntToDouble) ($script:ARCH)... "
    if ($script:FETCH_WRAR) {
      Start-BitsTransfer "$HostUriDir/wrar$script:RARVER$script:TAGS.exe" $pwd\ -ErrorAction SilentlyContinue
    } else {
      Start-BitsTransfer "$HostUriDir/winrar-$($script:ARCH)-$($script:RARVER)$($script:TAGS).exe" $pwd\ -ErrorAction SilentlyContinue
    }
  } else {
    New-Toast -ToastTitle "No internet" -ToastText "Please check your internet connection."; exit
  }
}

# Grab the name of the script file and process any
# customization data set by the user
if ($CMD_NAME -ne $script_name) { Get-WinRARData }
else { &$SetDefaultArchVersion }

if (-not($script:LICENSE_ONLY)) {
  # This ensures that the script does not unnecessarily
  # download a new installer if one is available in the
  # current directory
  $script:WINRAR_EXE = (Get-Installer)

  # if there are no installers, proceed to download one
  if ($null -eq $script:WINRAR_EXE) {
    $Error.Clear()
    Get-WinRarInstaller -HostUri $server1_host -HostUriDir $server1
    $local:retrycount = 0
    foreach ($wdir in $server2) {
      if ($Error) {
        $Error.Clear()
        $local:retrycount++
        Write-Host -NoNewLine "`nRetrying... $local:retrycount`n"
        Get-WinRarInstaller -HostUri $server2_host -HostUriDir $wdir
      }
    }
    if ($Error) {
      Write-Host -NoNewLine "`nNo installer found at $server2_host`n"
      if ($script:CUSTOM_DOWNLOAD) {
        New-Toast -ToastTitle "Unable to fetch download" `
                  -ToastText  "WinRAR $(Get-WinRARExeVersion $script:RARVER -IntToDouble) ($script:ARCH) may not exist on the server." `
                  -ToastText2 "Check the version number and try again."; exit
      } else {
        New-Toast -ToastTitle "Unable to fetch download" `
                  -ToastText  "Are you still connected to the internet?" `
                  -ToastText2 "Please check your internet connection."; exit
      }
    }
    if ($script:DOWNLOAD_ONLY) {
      New-Toast -ToastTitle "Download Complete" `
                -ToastText  "WinRAR $(Get-WinRARExeVersion $script:RARVER -IntToDouble) ($script:ARCH) was successfully downloaded." `
                -ToastText2 "Run this script again if you ever need to install it."; exit
    }
    $script:WINRAR_EXE = (Get-Installer) # get the new installer
    Write-Host "Done."
  } elseif ($script:DOWNLOAD_ONLY) {
    New-Toast -ToastTitle "Download Aborted" `
              -ToastText  "An installer for WinRAR $(Get-WinRARExeVersion $script:WINRAR_EXE) ($script:ARCH) already exists." `
              -ToastText2 "Check the requested download version and try again."; exit
  }

  Invoke-Installer $script:WINRAR_EXE (Get-WinRARExeVersion $script:WINRAR_EXE)
}

# --- LICENSING

if (-not($script:SKIP_LICENSING)) {
  Add-WinRarLicense
}

# --- EXIT TOAST MESSAGES

if ($script:SKIP_LICENSING) {
    New-Toast -Url $freedom_universe_yt_url `
              -ToastTitle "WinRAR installed successfully" `
              -ToastText  "Freedom throughout the universe!"; exit
} elseif ($script:LICENSE_ONLY) {
  if ($script:CUSTOM_LICENSE) {
    New-Toast -Url $freedom_universe_yt_url `
              -ToastTitle "WinRAR licensed successfully" `
              -ToastText  "Licensed to `"$($script:LICENSEE)`"" `
              -ToastText2 "Freedom throughout the universe!"; exit
  } else {
    New-Toast -Url $freedom_universe_yt_url `
              -ToastTitle "WinRAR licensed successfully" `
              -ToastText  "Freedom throughout the universe!"; exit
  }
} elseif ($script:CUSTOM_LICENSE) {
    New-Toast -Url $freedom_universe_yt_url `
              -ToastTitle "WinRAR installed and licensed successfully" `
              -ToastText  "Licensed to `"$($script:LICENSEE)`"" `
              -ToastText2 "Freedom throughout the universe!"; exit
} else {
    New-Toast -Url $freedom_universe_yt_url `
              -ToastTitle "WinRAR installed and licensed successfully" `
              -ToastText  "Freedom throughout the universe!"; exit
}
