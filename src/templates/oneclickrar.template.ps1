<#
  .SYNOPSIS
    Install and license WinRAR Archiver.

  .DESCRIPTION
    oneclickrar.cmd is a combination of installrar.cmd and licenserar.cmd with
    modifications and added functionality.

  .NOTES
    Complete naming pattern:

    <licensee>_<license-type>_<script-name>_<architecture>_<version>_<tags>.cmd

  .EXAMPLE
    oneclickrar.cmd             --- Install latest English 64-bit version with
                                    default license information
    oneclickrar_x32.cmd         --- Install latest English 32-bit version with
                                    default license information
    oneclickrar_700.cmd         --- Install English 64-bit version 7.00
                                    with default license information
    one-clickrar_624.cmd        --- Download English 64-bit version 6.24
    oneclickrar_x32_701_fr.cmd  --- Install French 32-bit version 7.01
    one-click-rar_x64_700.cmd   --- Install English 64-bit version 7.00 and keep
                                    the downloaded installer
    My Name_My License Type_oneclickrar.cmd
                                --- Custom license with default installation
    My Name_oneclick-rar.cmd    --- Overwrite current license with "My Name" as
                                    the licensee and use default license type
    My Name_My License Type_oneclick-rar_x64_700_ru.cmd
                                --- Full configuration to install Russian 64-bit
                                    version 7.00 and overwrite any existing
                                    license with the custom license information
#>

# ([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -contains "S-1-5-32-544"
# ([System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

#region Variables
$script_name = "oneclickrar"
$script_name_overwrite = "oneclick-rar"
$script_name_download_only = "one-clickrar"
$script_name_download_only_overwrite = "one-click-rar"

$winrar_name = "winrar"
$winrar_name_pattern = "^winrar-x"
$winrar_file_pattern = "winrar-x\d{2}-\d{3}\w*\.exe"

# old WinRAR name pattern
$wrar_name = "wrar"
$wrar_name_pattern = "^wrar"
$wrar_file_pattern = "wrar\d{3}\w*\.exe"

$rarloc = $null
$loc32 = "${env:ProgramFiles(x86)}\WinRAR"
$loc64 = "$env:ProgramFiles\WinRAR"
$loc96 = "x96"

$winrar64 = "$loc64\WinRAR.exe"
$winrar32 = "$loc32\WinRAR.exe"

$rarreg = $null
$rarkey = "RAR registration data`r`nEveryone`r`nGeneral Public License`r`nUID=119fdd47b4dbe9a41555`r`n6412212250155514920287d3b1cc8d9e41dfd22b78aaace2ba4386`r`n9152c1ac6639addbb73c60800b745269020dd21becbc46390d7cee`r`ncce48183d6d73d5e42e4605ab530f6edf8629596821ca042db83dd`r`n68035141fb21e5da4dcaf7bf57494e5455608abc8a9916ffd8e23d`r`n0a68ab79088aa7d5d5c2a0add4c9b3c27255740277f6edf8629596`r`n821ca04340a7c91e88b14ba087e0bfb04b57824193d842e660c419`r`nb8af4562cb13609a2ca469bf36fb8da2eda6f5e978bf1205660302"
$rarreg64 = "$loc64\rarreg.key"
$rarreg32 = "$loc32\rarreg.key"

$keygen = $null
$keygenUrl = $null
$keygen64 = "./bin/winrar-keygen/winrar-keygen-x64.exe"
$keygen32 = "./bin/winrar-keygen/winrar-keygen-x86.exe"
$keygenUrl32 = "https://github.com/bitcookies/winrar-keygen/releases/latest/download/winrar-keygen-x86.exe"
$keygenUrl64 = "https://github.com/bitcookies/winrar-keygen/releases/latest/download/winrar-keygen-x64.exe"

$server1_host = "www.rarlab.com"
$server1 = "https://$server1_host/rar"
$server2_host = "www.win-rar.com"
$server2 = @("https://$server2_host/fileadmin/winrar-versions", "https://$server2_host/fileadmin/winrar-versions/winrar")

#####KNOWN_VERSION_LIST#####

#####KNOWN_LANGUAGE_LIST#####

$link_freedom_universe_yt = "https://youtu.be/OD_WIKht0U0?t=450"
$link_overwriting = "https://github.com/neuralpain/oneclickwinrar#overwriting-licenses"
$link_howtouse = "https://github.com/neuralpain/oneclickwinrar#how-to-use"
$link_configuration = "https://github.com/neuralpain/oneclickwinrar#configuration"
$link_endof32bitsupport = "https://www.win-rar.com/singlenewsview.html?&L=0&tx_ttnews%5Btt_news%5D=266&cHash=44c8cdb0ff6581307702dfe4892a3fb5"

$OLDEST = 290
$script:LATEST = $script:KNOWN_VERSIONS[0]
$FIRST_64BIT = 390
$LATEST_32BIT = 701
$LATEST_OLD_WRAR = 611

#####STATUS_CODES#####
#endregion

#region Switch Configs
$script:custom_name = $null
$script:custom_code = $null
$script:SCRIPT_NAME_LOCATION = $null

$script:WINRAR_EXE = $null
$script:FETCH_WINRAR = $false                     # Download standard WinRAR
$script:FETCH_WRAR = $false                       # Download old 32-bit WinRAR naming scheme
$script:WINRAR_IS_INSTALLED = $false
$script:WINRAR_INSTALLED_LOCATION = $null

$script:CUSTOM_INSTALLATION = $false
$script:DOWNLOAD_ONLY = $false
$script:DOWNLOAD_WINRAR = $false
$script:KEEP_DOWNLOAD = $false

$script:licensee = $null
$script:license_type = "Single User License"
$script:LICENSE_ONLY = $false                     # SKIP INSTALLATION
$script:CUSTOM_LICENSE = $false
$script:SKIP_LICENSING = $false                   # INSTALL ONLY
$script:OVERWRITE_LICENSE = $false

$script:SPECIAL_CODE_ACTIVE = $false

$script:ARCH = $null                              # Download architecture
$script:RARVER = $null                            # WinRAR version
$script:TAGS = $null                              # Other download types, i.e. beta, language
#endregion

#region Utility
#####UTILITIES#####
#####CONFIRM_QUERY#####
#####VERSION_FORMAT#####
#endregion

#region Title
#####TITLE_HEADER#####
#endregion

#####MESSAGES#####

#region Location and Defaults
#####LOCATIONS#####
#####DEFAULT_ARCH_VERSION#####
#endregion

#region WinRAR Updates
#####UPDATES#####
#endregion

#region Data Processing
#####LANG_PROCESSING#####
#####ONECLICK_DATA_PROCESSING#####
function Resolve-ScriptConfiguration {
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

  $config = [regex]::matches($CMD_NAME, '[^_]+')

  <# Step 1 #> Find-ScriptNamePosition $config
  <# Step 2 #> Resolve-SpecialCode
  <# Step 3 #> Resolve-OperationMode
  <# Step 4 #> Set-OcwrOperationMode
  <# Step 5 #> Set-ConfigurationFromData $config
  if ($script:CUSTOM_INSTALLATION) {
    <# Opt. #> Resolve-DownloadConfiguration
  } else { Set-DefaultArchVersion }
}
#endregion

#region Installation
#####SELECT_WINRAR_INSTALLATION#####
#####INSTALLATION#####
#endregion

#region Licensing
#####LICENSING#####
#endregion

#region Begin Execution
# Begin by retrieving any current installations of WinRAR
Get-InstalledWinrarLocations

# Grab the name of the script file and process any
# configuration data set by the user
if ($CMD_NAME -ne $script_name) {
  Resolve-ScriptConfiguration
} else {
  Set-DefaultArchVersion
}

if ($script:LICENSE_ONLY) {
  Select-WinrarInstallation
}
elseif ($script:WINRAR_IS_INSTALLED -and ((-not $script:DOWNLOAD_ONLY) -or $script:OVERWRITE_LICENSE)) {
  Set-InstallationTargetDirectory
  Confirm-InstallationOverwrite
}

if (-not $script:LICENSE_ONLY) {
  Start-WinrarInstallation
}

if (-not $script:SKIP_LICENSING) {
  Start-WinrarLicensing
}

# --- SUCCESSFUL EXIT TOAST MESSAGES

if ($script:SKIP_LICENSING) {
    New-Toast -Url $link_freedom_universe_yt `
              -ToastTitle "WinRAR installed successfully" `
              -ToastText  "Freedom throughout the universe!"
} elseif ($script:LICENSE_ONLY) {
  if ($script:CUSTOM_LICENSE) {
    Write-Host "`nLicensee:`t$($script:licensee)`nLicense:`t$($script:license_type)`n"
    New-Toast -Url $link_freedom_universe_yt `
              -ToastTitle "WinRAR licensed successfully" `
              -ToastText  "Licensee: $($script:licensee)`nLicense: $($script:license_type)" `
              -ToastText2 "Freedom throughout the universe!"
  } else {
    New-Toast -Url $link_freedom_universe_yt `
              -ToastTitle "WinRAR licensed successfully" `
              -ToastText  "Freedom throughout the universe!"
  }
} elseif ($script:CUSTOM_LICENSE) {
    Write-Host "`nLicensee:`t$($script:licensee)`nLicense:`t$($script:license_type)`n"
    New-Toast -Url $link_freedom_universe_yt `
              -ToastTitle "WinRAR installed and licensed successfully" `
              -ToastText  "Licensee: $($script:licensee)`nLicense: $($script:license_type)" `
              -ToastText2 "Freedom throughout the universe!"
} else {
    New-Toast -Url $link_freedom_universe_yt `
              -ToastTitle "WinRAR installed and licensed successfully" `
              -ToastText  "Freedom throughout the universe!"
}

Stop-OcwrOperation -ExitType Complete
#endregion
