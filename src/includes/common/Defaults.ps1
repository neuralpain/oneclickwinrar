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
    Write-Info "Using default version $(Format-Text $(Format-VersionNumber $script:LATEST) -Foreground White -Formatting Underline)"
    $script:RARVER = $script:LATEST
  }
  if ($null -eq $script:TAGS) {
    Write-Info "WinRAR language set to $(Format-Text $default_lang_name -Foreground White -Formatting Underline)"
  }
}
