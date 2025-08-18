<#
  installrar.ps1
  Copyright (c) 2025, neuralpain

  .SYNOPSIS
    Install WinRAR Archiver.

  .DESCRIPTION
    installrar.ps1 is a modified distribution of
    installrar.cmd for use within the terminal.

  .NOTES
    Last updated: 2025/08/17
#>

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

function Write-Info{Param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Message);Write-Host "INFO: $Message" -ForegroundColor DarkCyan}
function Write-Warn{Param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Message);Write-Host "WARN: $Message" -ForegroundColor Yellow}
function Write-Err{Param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Message);Write-Host "ERROR: $Message" -ForegroundColor Red}

#region Utility
function Format-Text{[CmdletBinding()]Param([Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true)][String]$Text,[Parameter(Mandatory=$false)][ValidateSet(8,24)][Int]$BitDepth,[Parameter(Mandatory=$false)][ValidateCount(1,3)][String[]]$Foreground,[Parameter(Mandatory=$false)][ValidateCount(1,3)][String[]]$Background,[Parameter(Mandatory=$false)][String[]]$Formatting);$Esc=[char]27;$Reset="${Esc}[0m";switch($BitDepth){8{if($null -eq $Foreground -or $Foreground -lt 0){$Foreground=0}if($null -eq $Background -or $Background -lt 0){$Background=0}if($Foreground -gt 255){$Foreground=255}if($Background -gt 255){$Background=255}$Foreground="${Esc}[38;5;${Foreground}m";$Background="${Esc}[48;5;${Background}m";break}24{foreach($color in $Foreground){if($null -eq $color -or $color -lt 0){$color=0}if($color -gt 255){$color=255}$_foreground+=";${color}"}foreach($color in $Background){if($null -eq $color -or $color -lt 0){$color=0}if($color -gt 255){$color=255}$_background+=";${color}"}$Foreground="${Esc}[38;2${_foreground}m";$Background="${Esc}[48;2${_background}m";break;}default{switch($Foreground){'Black'{$Foreground="${Esc}[30m"}'DarkRed'{$Foreground="${Esc}[31m"}'DarkGreen'{$Foreground="${Esc}[32m"}'DarkYellow'{$Foreground="${Esc}[33m"}'DarkBlue'{$Foreground="${Esc}[34m"}'DarkMagenta'{$Foreground="${Esc}[35m"}'DarkCyan'{$Foreground="${Esc}[36m"}'Gray'{$Foreground="${Esc}[37m"}'DarkGray'{$Foreground="${Esc}[90m"}'Red'{$Foreground="${Esc}[91m"}'Green'{$Foreground="${Esc}[92m"}'Yellow'{$Foreground="${Esc}[93m"}'Blue'{$Foreground="${Esc}[94m"}'Magenta'{$Foreground="${Esc}[95m"}'Cyan'{$Foreground="${Esc}[96m"}'White'{$Foreground="${Esc}[97m" }default{$Foreground=""}}switch($Background){'Black'{$Background="${Esc}[40m"}'DarkRed'{$Background="${Esc}[41m"}'DarkGreen'{$Background="${Esc}[42m"}'DarkYellow'{$Background="${Esc}[43m"}'DarkBlue'{$Background="${Esc}[44m"}'DarkMagenta'{$Background="${Esc}[45m"}'DarkCyan'{$Background="${Esc}[46m"}'Gray'{$Background="${Esc}[47m"}'DarkGray'{$Background="${Esc}[100m"}'Red'{Background="${Esc}[101m"}'Green'{$Background="${Esc}[102m"}'Yellow'{$Background="${Esc}[103m"}'Blue'{$Background="${Esc}[104m"}'Magenta'{$Background="${Esc}[105m"}'Cyan'{$Background="${Esc}[106m"}'White'{$Background="${Esc}[107m"}default{$Background=""}}break}};if($Formatting.Length -eq 0){$Format=""}else{$i=0;$Format="${Esc}[";foreach($type in $Formatting){switch($type){'Bold'{$Format+="1"}'Dim'{$Format+="2"}'Underline'{$Format+="4"}'Blink'{$Format+="5"}'Reverse'{$Format+="7"}'Hidden'{$Format+="8"}default{$Format+=""}}$i++;if($i -lt ($Formatting.Length)){$Format+=";"}else{$Format+="m";break}}};$OutString="${Foreground}${Background}${Format}${Text}${Reset}";Write-Output $OutString;}
function New-Toast{[CmdletBinding()]Param([String]$AppId="oneclickwinrar",[String]$Url,[String]$ToastTitle,[String]$ToastText,[String]$ToastText2,[string]$Attribution,[String]$ActionButtonUrl,[String]$ActionButtonText="Open documentation",[switch]$KeepAlive,[switch]$LongerDuration);[Windows.UI.Notifications.ToastNotificationManager,Windows.UI.Notifications,ContentType=WindowsRuntime]|Out-Null;$Template=[Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText04);$RawXml=[xml] $Template.GetXml();($RawXml.toast.visual.binding.text|Where-Object{$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle))|Out-Null;($RawXml.toast.visual.binding.text|Where-Object{$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText))|Out-Null;($RawXml.toast.visual.binding.text|Where-Object{$_.id -eq "3"}).AppendChild($RawXml.CreateTextNode($ToastText2))|Out-Null;$XmlDocument=New-Object Windows.Data.Xml.Dom.XmlDocument;$XmlDocument.LoadXml($RawXml.OuterXml);if($Url){$XmlDocument.DocumentElement.SetAttribute("activationType","protocol");$XmlDocument.DocumentElement.SetAttribute("launch",$Url)}if($Attribution){$attrElement=$XmlDocument.CreateElement("text");$attrElement.SetAttribute("placement","attribution");$attrElement.InnerText=$Attribution;$bindingElement=$XmlDocument.SelectSingleNode('//toast/visual/binding');$bindingElement.AppendChild($attrElement)|Out-Null}if($ActionButtonUrl){$actionsElement=$XmlDocument.CreateElement("actions");$actionElement=$XmlDocument.CreateElement("action");$actionElement.SetAttribute("content",$ActionButtonText);$actionElement.SetAttribute("activationType","protocol");$actionElement.SetAttribute("arguments",$ActionButtonUrl);$actionsElement.AppendChild($actionElement)|Out-Null;$XmlDocument.DocumentElement.AppendChild($actionsElement)|Out-Null}if($KeepAlive){$XmlDocument.DocumentElement.SetAttribute("scenario","incomingCall")}elseif($LongerDuration){$XmlDocument.DocumentElement.SetAttribute("duration","long")};$Toast=[Windows.UI.Notifications.ToastNotification]::new($XmlDocument);$Toast.Tag="PowerShell";$Toast.Group="PowerShell";if(-not($KeepAlive -or $LongerDuration)){$Toast.ExpirationTime=[DateTimeOffset]::Now.AddMinutes(1)};$Notifier=[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId);$Notifier.Show($Toast)}

function Write-Title {
  Write-Host;
  Write-Host "                                ___                __                     "
  Write-Host "                               /\_ \    __        /\ \                    "
  Write-Host "     ___     ___      __    ___\//\ \  /\_\    ___\ \ \/`'\               "
  Write-Host "    / __``\ /`' _ ``\  /`'__``\ /`'___\\ \ \ \/\ \  /`'___\ \ , <         "
  Write-Host "   /\ \L\ \/\ \/\ \/\  __//\ \__/ \_\ \_\ \ \/\ \__/\ \ \\``\             "
  Write-Host "   \ \____/\ \_\ \_\ \____\ \____\/\____\\ \_\ \____\\ \_\ \_\            "
  Write-Host "    \/___/  \/_/\/_/\/____/\/____/\/____/ \/_/\/____/ \/_/\/_/            "
  Write-Host "         __      __              ____    ______  ____                     "
  Write-Host "        /\ \  __/\ \  __        /\  _``\ /\  _  \/\  _``\                 "
  Write-Host "        \ \ \/\ \ \ \/\_\    ___\ \ \L\ \ \ \L\ \ \ \L\ \                 "
  Write-Host "         \ \ \ \ \ \ \/\ \ /`' _ ``\ \ ,  /\ \  __ \ \ ,  /               "
  Write-Host "          \ \ \_/ \_\ \ \ \/\ \/\ \ \ \\ \\ \ \/\ \ \ \\ \                "
  Write-Host "           \ ``\___x___/\ \_\ \_\ \_\ \_\ \_\ \_\ \_\ \_\ \_\             "
  Write-Host "            `'\/__//__/  \/_/\/_/\/_/\/_/\/ /\/_/\/_/\/_/\/ /$(Format-Text ".ps1" -Foreground Blue)"
  Write-Host;Write-Host;
}; Write-Title

function Stop-OcwrOperation{Param([Parameter(Mandatory=$false)][string]$ExitType,[Parameter(Mandatory=$false)][string]$Message);switch($ExitType){Terminate{Write-Host "$(if($Message){"$Message`n"})Operation terminated normally."};Error{Write-Host "$(if($Message){"ERROR: $Message`n"})Operation terminated with ERROR." -ForegroundColor Red};Warning{Write-Host "$(if($Message){"WARN: $Message`n"})Operation terminated with WARNING." -ForegroundColor Yellow};Complete{Write-Host "$(if($Message){"$Message`n"})Operation completed successfully." -ForegroundColor Green}default{Write-Host "$(if($Message){"$Message`n"})Operation terminated."}};break}
function Confirm-QueryResult{[CmdletBinding()]param([Parameter(Position=0, Mandatory=$true)][string]$Query,[switch]$ExpectPositive,[switch]$ExpectNegative,[Parameter(Mandatory=$true)][scriptblock]$ResultPositive,[Parameter(Mandatory=$true)][scriptblock]$ResultNegative);$q=Read-Host "$Query $(if($ExpectPositive){"(Y/n)"}elseif($ExpectNegative){"(y/N)"})";if($ExpectPositive){if(-not([string]::IsNullOrEmpty($q)) -and ($q.Length -eq 1 -and $q -match '(N|n)')){if($ResultNegative){&$ResultNegative}}else{if($ResultPositive){&$ResultPositive}}}elseif($ExpectNegative){if(-not([string]::IsNullOrEmpty($q))-and($q.Length-eq1-and$q-match'(Y|y)')){if($ResultPositive){&$ResultPositive}}else{if($ResultNegative){&$ResultNegative}}}else {Write-Err "Nothing to expect.";Stop-OcwrOperation -ExitType Error}}

function Find-AnyNewWinRarVersions {
  <#
    .SYNOPSIS
      Checks a list of URLs to verify if they likely point to valid
      download.

    .DESCRIPTION
      This script takes an array of URLs as input. For each URL, it performs an
      HTTP HEAD request to retrieve the headers. It then analyzes the StatusCode
      header to determine if the URL is accessible to download files.

    .PARAMETER URLs
      An array of strings, where each string is a URL to check.

    .EXAMPLE
      Find-AnyNewWinRarVersions -URLs @(
          "https://www.rarlab.com/rar/winrar-x64-{version}.exe",
          "https://www.win-rar.com/fileadmin/winrar-versions/winrar-x64-{version}.exe"
          "https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-{version}.exe"
        )
  #>
  Param([Parameter(Mandatory = $true)][string[]]$URLs)

  foreach ($url in $URLs) {
    try {
      $statusCode = $(Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop).StatusCode
      if ($statusCode -eq 200) {
        # if at least one of the URLs connect, then it's good.
        return $true # --- sentinel
      }
    }
    catch [System.Net.WebException] {
      # Will return 404 if the downloads are not available.
    }
    catch {
      # Generally, we don't care about the errors here. This function is only for
      # testing availability. If it can't connect in any way, it's invalid.
    }
  }
}

function Get-WinRarUpdates {

  Param([string[]]$KV)

  $patch = [int]($KV[0] % 10)
  $minor = [int](($KV[0] % 100) / 10)
  $major = [int](($KV[0] % 1000) / 100)

  $newVersions = @()

  Write-Info "Checking for WinRAR updates..."

  for ($j = $minor; $j -le $minor+1; $j++) {
    if ($j -gt $minor) { $patch = 0 }
    for ($k = $patch; $k -lt 10; $k++) {
      $testVersion = $major*100 + $j*10 + $k
      if ((Find-AnyNewWinRarVersions -URLs @("$server1/winrar-x64-$($testVersion).exe","$($server2[0])/winrar-x64-$($testVersion).exe","$($server2[1])/winrar-x64-$($testVersion).exe"))) {
        $newVersions += $testVersion
      }
    }
  }

  if ($null -ne $newVersions) {
    $newVersions = $($newVersions | Sort-Object -Descending)
    $newVersion = $newVersions[0]
    if ($newVersion -gt $KV[0]) {
      Write-Info "New version found. Updating dedault version to $(Format-Text $newVersion -Foreground White)"
      return $newVersions
    } else {
      Write-Info "No WinRAR updates found."
      return $null
    }
  }
}
#endregion

#region Messages
$Error_NoInternetConnection = {
  New-Toast -ToastTitle "No internet" -ToastText "Please check your internet connection."
  Stop-OcwrOperation -ExitType Error -Message "Internet connection lost or unavailable."
}

$Error_UnableToConnectToDownload = {
  New-Toast -ToastTitle "Unable to make a connection" -ToastText "Please check your internet or firewall rules."
  Stop-OcwrOperation -ExitType Error -Message "Unable to make a connection."
}
#endregion

#region Variables
$winrar_name_pattern = "^winrar-x"
$winrar_file_pattern = "winrar-x\d{2}-\d{3}\w*\.exe"

$loc32    = "${env:ProgramFiles(x86)}\WinRAR"
$loc64    = "$env:ProgramFiles\WinRAR"
$loc96    = "x96"

$winrar64 = "$loc64\WinRAR.exe"
$winrar32 = "$loc32\WinRAR.exe"

$server1_host    = "www.rarlab.com"
$server1         = "https://$server1_host/rar"
$server2_host    = "www.win-rar.com"
$server2         = @("https://$server2_host/fileadmin/winrar-versions", "https://$server2_host/fileadmin/winrar-versions/winrar")

$KNOWN_VERSIONS  = @(713, 712, 711, 710, 701, 700, 624, 623, 622, 621, 620, 611, 610, 602, 601, 600, 591, 590, 580, 571, 570, 561, 560, 550, 540, 531, 530, 521, 520, 511, 510, 501, 500, 420, 411, 410, 401, 400, 393, 390, 380, 371, 370, 360, 350, 340, 330, 320, 310, 300, 290)

if (Test-Connection $server1_host -Count 2 -Quiet) {
  $_update = Get-WinRarUpdates $KNOWN_VERSIONS
  if ($null -ne $_update) {
    $KNOWN_VERSIONS += $_update
    $KNOWN_VERSIONS = $($KNOWN_VERSIONS | Sort-Object -Descending)
  }
} else { &$Error_NoInternetConnection }

$LATEST = $KNOWN_VERSIONS[0]

# --- SWITCH / CONFIGS ---
$script:WINRAR_EXE          = $null
$script:FETCH_WINRAR        = $false
$script:WINRAR_IS_INSTALLED = $false
$script:WINRAR_INSTALLED_LOCATION = $null

$script:DOWNLOAD_WINRAR     = $false

$script:ARCH     = $null
$script:RARVER   = $null
$script:TAGS     = $null
# --- END SWITCH / CONFIGS ---
#endregion

#region Location and Defaults
function Get-InstalledWinrarLocations {
  <#
    .DESCRIPTION
      Confirm the location of any installed versions of WinRAR.
  #>
  if ((Test-Path $winrar64 -PathType Leaf) -and (Test-Path $winrar32 -PathType Leaf)) {
    $script:WINRAR_INSTALLED_LOCATION = $loc96
    $script:WINRAR_IS_INSTALLED = $true
  }
  elseif (Test-Path $winrar64 -PathType Leaf) {
    $script:WINRAR_INSTALLED_LOCATION = $loc64
    $script:WINRAR_IS_INSTALLED = $true
  }
  elseif (Test-Path $winrar32 -PathType Leaf) {
    $script:WINRAR_INSTALLED_LOCATION = $loc32
    $script:WINRAR_IS_INSTALLED = $true
  }
  else {
    $script:WINRAR_INSTALLED_LOCATION = $null
    $script:WINRAR_IS_INSTALLED = $false
  }
}

function Set-DefaultArchVersion {
  <#
    .DESCRIPTION
      Set config defaults.
  #>
  if ($null -eq $script:ARCH) {
    Write-Info "Using default 64-bit architecture"
    $script:ARCH = "x64"
  }
  if ($null -eq $script:RARVER) {
    Write-Info "Using default version $(Format-Text $(Format-VersionNumber $LATEST) -Foreground White -Formatting Underline)"
    $script:RARVER = $LATEST
  }
  if ($null -eq $script:TAGS) {
    Write-Info "WinRAR language set to $(Format-Text "English" -Foreground White -Formatting Underline)"
    $script:RARVER = $LATEST
  }
}
#endregion

#region Installation
function Format-VersionNumber {
  <#
    .DESCRIPTION
      Format version numbers as x.xx
  #>
  Param($VersionNumber)
  if ($null -eq $VersionNumber) { return $null }
  return "{0:N2}" -f ($VersionNumber / 100)
}

function Format-VersionNumberFromExecutable {
  <#
    .DESCRIPTION
      Retrieve the WinRAR version form the executable name and format it.
  #>
  Param(
    [Parameter(Mandatory=$true, Position=0)]
    $Executable,
    [Switch]$IntToDouble
  )

  $version = if ($IntToDouble) { $Executable }
             elseif ($Executable -match "(?<version>\d{3})") { $matches['version'] }
             else { return $null }
  $version = Format-VersionNumber $version
  return $version
}

function Get-LocalWinrarInstaller {
  <#
    .DESCRIPTION
      Find any WinRAR installer executables in the current directory.
  #>

  $script:FETCH_WINRAR = $true
  $file_pattern = $winrar_file_pattern
  $name_pattern = $winrar_name_pattern

  $files = Get-ChildItem -Path $pwd | Where-Object { $_.Name -match $name_pattern }

  foreach ($file in $files) {
    if ($file -match $file_pattern) { return $file }
  }
}

function Get-WinrarInstaller {
  <#
    .DESCRIPTION
      Download a WinRAR installer from the available servers.

    .PARAMETER HostUri
      Server domain.

    .PARAMETER HostUriDir
      Installer download path on the server.
  #>
  Param($HostUri, $HostUriDir)

  $version = Format-VersionNumber $script:RARVER
  if ($script:TAGS) {
    $beta = [regex]::matches($script:TAGS, '\d+')[0].Value
    $lang = $script:TAGS.Trim($beta).ToUpper()
  }

  Write-Host "Connecting to $HostUri... "
  if (Test-Connection "$HostUri" -Count 2 -Quiet) {
    # Verify that connection to the host is good for downloading
    try { Invoke-WebRequest -Uri $HostUri | Out-Null }
    catch { &$Error_UnableToConnectToDownload }

    Write-Host "Verifying download... "

    $download_url = "$HostUriDir/winrar-$($script:ARCH)-$($script:RARVER)$($script:TAGS).exe"

    try {
      $responseCode = $(Invoke-WebRequest -Uri $download_url -Method Head -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop).StatusCode
    }
    catch {
      Write-Error -Message "Unable to download." -ErrorId "404" -Category NotSpecified 2>$null
    }

    if ($responseCode -eq 200) {
      Write-Host "Downloading WinRAR $($version)$(if($beta){" Beta $beta"}) ($($script:ARCH))$(if($lang){" ($(Get-LanguageName))"})... "
      Start-BitsTransfer $download_url $pwd\ -ErrorAction SilentlyContinue
    }
    else {
      Write-Error -Message "Download unavailable." -ErrorId "404" -Category NotSpecified 2>$null
    }
  } else { &$Error_NoInternetConnection }
}

function Select-CurrentWinrarInstallation {
  <#
    .DESCRIPTION
      Select WinRAR installation directory based on the proposed installation
      architecture.
  #>
  if ($script:WINRAR_INSTALLED_LOCATION -eq $loc96) {
    switch ($script:ARCH) {
      'x64' {
        $script:WINRAR_INSTALLED_LOCATION = $loc64
        break
      }
      'x32' {
        $script:WINRAR_INSTALLED_LOCATION = $loc32
        break
      }
      default {
        Stop-OcwrOperation -ExitType Error -Message "No architecture provided"
      }
    }
  }
  Write-Info "Installation directory: $(Format-Text $($script:WINRAR_INSTALLED_LOCATION) -Foreground White -Formatting Underline)"
}

function Confirm-CurrentWinrarInstallation {
  <#
    .DESCRIPTION
      Verify and confirm the current WinRAR installation to be worked on.
  #>
  # `-iver` switch returns the version number of the current (Win)RAR installation
  $civ = $(&$script:WINRAR_INSTALLED_LOCATION\rar.exe "-iver") # current installed version
  if ("$civ" -match $(Format-VersionNumber $script:RARVER)) {
    Write-Info "This version of WinRAR is already installed: $(Format-Text $(Format-VersionNumber $script:RARVER) -Foreground White -Formatting Underline)"
    Confirm-QueryResult -ExpectNegative `
      -Query "Continue with installation?" `
      -ResultPositive {
        Write-Info "Confirmed re-installation of WinRAR version $(Format-Text $(Format-VersionNumber $script:RARVER) -Foreground White -Formatting Underline)"
      } `
      -ResultNegative { Stop-OcwrOperation }
  }
}

function Invoke-Installer($x, $v) {
  <#
    .SYNOPSIS
      Run the installer.

    .PARAMETER x
      The executable file.

    .PARAMETER v
      WinRAR version number.
  #>
  Write-Host "Installing WinRAR $v... "
  try { Start-Process $x "/s" -Wait }
  catch {
    New-Toast -ToastTitle "Installation error" -ToastText "The script has run into a problem during installation. Please restart the script."
    Stop-OcwrOperation -ExitType Error -Message "An unknown error occured."
  }
  finally {
    if (($script:FETCH_WINRAR -or $script:FETCH_WRAR) -and $script:DOWNLOAD_WINRAR) {
      Remove-Item $script:WINRAR_EXE
    }
  }
}

function Invoke-OwcrInstallation {
  <#
    .DESCRIPTION
      Installation instructions to be executed.
  #>

  $script:WINRAR_EXE = (Get-LocalWinrarInstaller)

  # if there are no installers, proceed to download one
  if ($null -eq $script:WINRAR_EXE) {
    $script:DOWNLOAD_WINRAR = $true

    $Error.Clear()
    $local:retrycount = 0

    Get-WinrarInstaller -HostUri $server1_host -HostUriDir $server1
    foreach ($wdir in $server2) {
      if ($Error) {
        $Error.Clear()
        $local:retrycount++
        Write-Host -NoNewLine "`nFailed. Retrying... $local:retrycount`n"
        Get-WinrarInstaller -HostUri $server2_host -HostUriDir $wdir
      }
    }
    if ($Error) {
      New-Toast -ToastTitle "Unable to fetch download" -ToastText  "Are you still connected to the internet?" -ToastText2 "Please check your internet connection."
      Stop-OcwrOperation -ExitType Error -Message "Unable to fetch download"
    }
    $script:WINRAR_EXE = (Get-LocalWinrarInstaller) # get the new installer
  } else {
    Write-Info "Found executable versioned at $(Format-Text (Format-VersionNumberFromExecutable $script:WINRAR_EXE) -Foreground White -Formatting Underline)"
  }

  Invoke-Installer $script:WINRAR_EXE (Format-VersionNumberFromExecutable $script:WINRAR_EXE)
}
#endregion

#region Begin Execution
Get-InstalledWinrarLocations
Set-DefaultArchVersion

if ($script:WINRAR_IS_INSTALLED) {
  Select-CurrentWinrarInstallation
  Confirm-CurrentWinrarInstallation
}

Invoke-OwcrInstallation

New-Toast -Url "https://ko-fi.com/neuralpain" -ToastTitle "WinRAR installed successfully" -ToastText2 "Thanks for using oneclickwinrar!"
Stop-OcwrOperation -ExitType Complete
#endregion
