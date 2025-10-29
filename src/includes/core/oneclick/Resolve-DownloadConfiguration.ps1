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