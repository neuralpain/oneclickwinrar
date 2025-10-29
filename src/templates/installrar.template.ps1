[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

#region Variables
$script_name = "installrar"

$winrar_name = "winrar"
$winrar_name_pattern = "^winrar-x"
$winrar_file_pattern = "winrar-x\d{2}-\d{3}\w*\.exe"

# old WinRAR name pattern
$wrar_name = "wrar"
$wrar_name_pattern = "^wrar"
$wrar_file_pattern = "wrar\d{3}\w*\.exe"

$loc32 = "${env:ProgramFiles(x86)}\WinRAR"
$loc64 = "$env:ProgramFiles\WinRAR"
$loc96 = "x96"

$winrar64 = "$loc64\WinRAR.exe"
$winrar32 = "$loc32\WinRAR.exe"

$server1_host = "www.rarlab.com"
$server1 = "https://$server1_host/rar"
$server2_host = "www.win-rar.com"
$server2 = @("https://$server2_host/fileadmin/winrar-versions", "https://$server2_host/fileadmin/winrar-versions/winrar")

#####KNOWN_VERSION_LIST#####

#####KNOWN_LANGUAGE_LIST#####

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
$script:WINRAR_EXE = $null
$script:FETCH_WINRAR = $false                     # Download standard WinRAR
$script:FETCH_WRAR = $false                       # Download old 32-bit WinRAR naming scheme
$script:WINRAR_IS_INSTALLED = $false
$script:WINRAR_INSTALLED_LOCATION = $null

$script:CUSTOM_INSTALLATION = $false
$script:DOWNLOAD_WINRAR = $false

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

#region Messages
#####MESSAGES#####
#endregion

#region Location and Defaults
#####LOCATIONS#####
#####DEFAULT_ARCH_VERSION#####
#endregion

#region WinRAR Updates
#####UPDATES#####
#endregion

#region Data Processing
#####LANG_PROCESSING#####
function Resolve-DownloadConfiguration {
  <#
    .DESCRIPTION
      Verify and validate download config data and reorder to correct data
      positions before executing any subsequent actions.
  #>

  # 1. Verify ARCH data. Copy the config to the correct variables (LIFO)
  # If ARCH has a value, but is not an architecture value
  if ($null -ne $script:ARCH -and $script:ARCH -notmatch 'x(64|32)') {
    # If the ARCH value is not RARVER, then it is TAGS
    if ($script:ARCH -notmatch '^\d{3,}$') {
      $script:TAGS = $script:ARCH
      # Defaults from here
      Write-Warn "No version provided"
      Write-Info "Using latest WinRAR version $(Format-VersionNumber $script:LATEST)"
      $script:RARVER = $script:LATEST
    }
    # If the ARCH value is RARVER
    else {
      $script:TAGS = $script:RARVER
      $script:RARVER = $script:ARCH
    }
    # Defaults from here
    Write-Warn "No architecture provided"
    if ($script:RARVER -lt $FIRST_64BIT) {
      Write-Warn "Version $(Format-VersionNumber $script:RARVER) is $(Format-Text "32-bit only" -Formatting Underline)"
      Write-Info "Using 32-bit for versions older than $(Format-Text $(Format-VersionNumber $FIRST_64BIT) -Formatting Underline)"
      $script:ARCH = "x32" # Assume 32-bit
    }
    else {
      Write-Info "Using default 64-bit architecture"
      $script:ARCH = "x64" # Assume 64-bit
    }
  }

  # 2. Verify RARVER data.
  # 2.1. Confirm correct version number for 32-bit installer
  if ($script:ARCH -eq "x32") {
    if ($null -eq $script:RARVER) {
      Write-Warn "No version provided"
      Write-Info "Using latest 32-bit version $(Format-VersionNumber $LATEST_32BIT)"
      $script:RARVER = $LATEST_32BIT
    }
    elseif ($script:RARVER -gt $LATEST_32BIT) {
      Write-Warn "No 32-bit installer available for WinRAR $(Format-VersionNumber $script:RARVER)"
      Confirm-QueryResult -ExpectPositive `
        -Query "Use latest 32-bit version $(Format-VersionNumber $LATEST_32BIT)?" `
        -ResultPositive {
          Write-Info "Confirmed use of version $(Format-VersionNumber $LATEST_32BIT)"
          $script:RARVER = $LATEST_32BIT
        } `
        -ResultNegative { &$Error_No32bitSupport }
    }
  }

  # 2.2. Confirm correct version number for 64-bit installer
  if ($script:ARCH -eq "x64") {
    if ($null -eq $script:RARVER) {
      Write-Warn "No version provided"
      Write-Info "Using latest 64-bit version $(Format-VersionNumber $script:LATEST)"
      $script:RARVER = $script:LATEST
    }
    elseif ($script:RARVER -lt $FIRST_64BIT) {
      Write-Warn "No 64-bit installer available for WinRAR $(Format-VersionNumber $script:RARVER)"
      Confirm-QueryResult -ExpectPositive `
        -Query "Use earliest 64-bit version $(Format-VersionNumber $FIRST_64BIT)?" `
        -ResultPositive {
          Write-Info "Confirmed use of version $(Format-VersionNumber $FIRST_64BIT)"
          $script:RARVER = $FIRST_64BIT
        } `
        -ResultNegative {
          Confirm-QueryResult -ExpectPositive `
            -Query "Use 32-bit for version $(Format-VersionNumber $script:RARVER)?" `
            -ResultPositive {
              Write-Info "Confirmed switch to 32-bit for version $(Format-VersionNumber $script:RARVER)"
              $script:ARCH = 'x32'
            } `
            -ResultNegative { &$Error_InvalidVersionNumber }
        }
    }
  }

  # 2.3. Sanity check for RARVER
  if ($script:RARVER -match '^\d{3,}$' -and $script:KNOWN_VERSIONS -notcontains $script:RARVER) {
    if ($script:RARVER -gt $script:LATEST) {
      Write-Warn "Version $(Format-VersionNumber $script:RARVER) is newer than the known latest $(Format-VersionNumber $script:LATEST)"
    }
    elseif ($script:RARVER -lt $OLDEST) {
      Write-Warn "Version $(Format-VersionNumber $OLDEST) is the earliest known available WinRAR version"
    }
    else {
      Write-Warn "Version $(Format-VersionNumber $script:RARVER) is not a known WinRAR version"
    }

    Confirm-QueryResult -ExpectNegative `
      -Query "Attempt to retrieve unknown version $(Format-VersionNumber $script:RARVER)?" `
      -ResultPositive {
        Write-Info "Confirmed retrieval of unknown version $(Format-VersionNumber $script:RARVER)"
        Write-Warn "Version $(Format-VersionNumber $script:RARVER) may not exist on the server"
      } `
      -ResultNegative { &$Error_InvalidVersionNumber }
  }

  # 3. Verify TAGS data.
  if ($null -eq (Get-LanguageName -Quiet)) { $script:TAGS = $null } # quick patch
  if ([string]::IsNullOrEmpty($script:TAGS)) {
    Write-Info "WinRAR language set to $(Format-Text $default_lang_name -Foreground White -Formatting Underline)"
  } else {
    Write-Info "WinRAR language set to $(Format-Text $(Get-LanguageName) -Foreground White -Formatting Underline)"
  }
}

function Resolve-ScriptConfiguration {
  <#
    .DESCRIPTION
      Parse the script name and determine the type of operation.
  #>

  $config = [regex]::matches($CMD_NAME, '[^_]+')

  if ($config.Count -gt 4) { &$Error_TooManyArgs }
  if ($config[0].Value -ne $script_name) { &$Error_UnknownScript }

  $script:ARCH = $config[1].Value
  $script:RARVER = $config[2].Value
  $script:TAGS = $config[3].Value

  if (($null -or 'x64') -eq $script:ARCH) {
    Update-WinrarLatestVersion
  }

  Resolve-DownloadConfiguration
}
#endregion



#region Installation
#####INSTALLATION#####
#endregion

#region Begin Execution
# Begin by retrieving any current installations of WinRAR
Get-InstalledWinrarLocations

# Grab the name of the script file and process any
# configuration data set by the user
if ($CMD_NAME -ne $script_name) {
  $script:CUSTOM_INSTALLATION = $true
  Resolve-ScriptConfiguration
} else {
  Update-WinrarLatestVersion
  Set-DefaultArchVersion
}

if ($script:WINRAR_IS_INSTALLED) {
  Set-InstallationTargetDirectory
  Confirm-InstallationOverwrite
}

Start-WinrarInstallation

New-Toast -Url "https://ko-fi.com/neuralpain" -ToastTitle "WinRAR installed successfully" -ToastText2 "Thanks for using oneclickwinrar!"
Stop-OcwrOperation -ExitType Complete
#endregion
