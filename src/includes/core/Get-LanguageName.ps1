function Get-LanguageName {
  <#
    .DESCRIPTION
      Return the full language name based on the code provided in the
      configuration via TAGS.

    .PARAMETER LangCode
      Specify a language code to get the name of.
  #>
  Param(
    [Parameter(Mandatory=$false)][string]$LangCode,
    [switch]$Quiet
  )

  # if ([string]::IsNullOrEmpty($script:TAGS)) { return $null } # leaving this here JIC
  if ([string]::IsNullOrEmpty($LangCode)) { $LangCode = $script:TAGS }

  $extractedLangCode = $null
  $betaCodeMatch = [regex]::matches($LangCode, 'b\d+')

  if ($betaCodeMatch.Count -gt 0) {
    $extractedLangCode = $LangCode.Trim($betaCodeMatch[0].Value)
  } else {
    $extractedLangCode = $LangCode # LangCode has the language code.
  }

  $defaultTags = {
    $script:TAGS = if ($betaCodeMatch.Count -gt 0) { $betaCodeMatch[0].Value } else { $null }
    (Get-LanguageName -LangCode $default_lang_code)
  }

  # If the extracted language code is null or empty (e.g., if $script:TAGS was
  # "b1", Trim("b1") results in ""), then it's not a valid code to search for.
  if ([string]::IsNullOrEmpty($extractedLangCode)) {
    # This verification will be handled by Resolve-DownloadConfiguration
    # In theory, this block should only be visited once throughout the runtime
    # of the program
    return &$defaultTags
  }

  # idiot prevention
  if ($extractedLangCode -eq 'en') {
    $script:TAGS = if ($betaCodeMatch.Count -gt 0) { $betaCodeMatch[0].Value } else { $null }
    return 'English'
  }

  $position = 0
  $isFound = $false

  # Iterate through the known language codes to find a match.
  foreach ($code in $LANG_CODE_LIST) {
    if ($code -eq $extractedLangCode) {
      $isFound = $true
      break
    }
    $position++
  }

  if ($isFound) {
    if ($position -lt $LANG_NAME_LIST.Count) {
      return $LANG_NAME_LIST[$position] # return the language name
    } else {
      # "Internal error: Language code found, but index $position is out of
      # bounds for LANG_NAME_LIST."
      if (-not $Quiet) { Write-Error "Unable to process language requirements. Using default language." }
      return &$defaultTags
    }
  } else {
    if (-not $Quiet) { Write-Info "Requested language not found. Using default language." }
    return &$defaultTags
  }
}
