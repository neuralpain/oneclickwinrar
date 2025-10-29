function Get-DataFromConfig {
  <#
    .SYNOPSIS
      Retrieve the config data.

    .DESCRIPTION
      Copy custom specified license and installation configuration data
      based on the position of the script name.
  #>
  Param($Config)

  if ($null -eq $Config.Count -or $null -eq $script:SCRIPT_NAME_LOCATION -or $script:SCRIPT_NAME_LOCATION -notin (0,1,2)) {
    &$Error_UnableToProcess
  }
  if ($script:SCRIPT_NAME_LOCATION -eq 0) {
    # Download/install
    # e.g. oneclickrar_x64_700.cmd
    if ($Config.Count -eq 1) {
      # do nothing; only capture the condition
    }
    elseif ($Config.Count -gt 1 -and $Config.Count -le 4) {                     # GET DOWNLOAD-ONLY DATA
      $script:CUSTOM_INSTALLATION = $true
      # `$Config[0]` is the script name # 1
      $script:ARCH   = $Config[1].Value # 2
      $script:RARVER = $Config[2].Value # 3                                     # Not required for download
      $script:TAGS   = $Config[3].Value # 4                                     # Not required for download
    }
    # elseif (-not $script:SPECIAL_CODE_ACTIVE) {
    else {
      &$Error_TooManyArgs
    }
  }
  elseif ($script:SCRIPT_NAME_LOCATION -eq 1) {
    # Download/install, license
    if ($Config.Count -gt 1 -and $Config.Count -eq 2) {                         # GET LICENSE-ONLY DATA
      # e.g. John Doe_oneclickrar.cmd
      $script:CUSTOM_LICENSE = $true
      $script:licensee       = $Config[0].Value # 1
      # `$Config[1]` is the script name         # 2
      # $script:license_type => Default license type
    }
    elseif ($Config.Count -ge 3 -and $Config.Count -le 5) {                     # GET DOWNLOAD AND LICENSE DATA
      # e.g. John Doe_oneclickrar_x64_700_ru.cmd
      $script:CUSTOM_LICENSE = $true
      $script:CUSTOM_INSTALLATION = $true
      $script:licensee       = $Config[0].Value # 1
      # `$Config[1]` is the script name         # 2
      # $script:license_type => Default license type
      $script:ARCH   = $Config[2].Value # 3
      $script:RARVER = $Config[3].Value # 4                                     # Not required for download
      $script:TAGS   = $Config[4].Value # 5                                     # Not required for download
    }
    else { &$Error_TooManyArgs }
  }
  elseif ($script:SCRIPT_NAME_LOCATION -eq 2) {
    # Download/install, license
    if ($Config.Count -gt 1 -and $Config.Count -eq 3) {                     # GET LICENSE-ONLY DATA
      # e.g. John Doe_License_oneclickrar.cmd
      $script:CUSTOM_LICENSE = $true
      $script:licensee       = $Config[0].Value # 1
      $script:license_type   = $Config[1].Value # 2
      # `$Config[2]` is the script name         # 3
    }
    elseif ($Config.Count -ge 4 -and $Config.Count -le 6) {                     # GET DOWNLOAD AND LICENSE DATA
      # e.g. John Doe_License_oneclickrar_x64_700_ru.cmd
      $script:CUSTOM_LICENSE = $true
      $script:CUSTOM_INSTALLATION = $true
      $script:licensee       = $Config[0].Value # 1
      $script:license_type   = $Config[1].Value # 2
      # `$Config[2]` is the script name # 3
      $script:ARCH   = $Config[3].Value # 4
      $script:RARVER = $Config[4].Value # 5                                     # Not required for download
      $script:TAGS   = $Config[5].Value # 6                                     # Not required for download
    }
    else { &$Error_TooManyArgs }
  } else { &$Error_UnableToProcess }
}
