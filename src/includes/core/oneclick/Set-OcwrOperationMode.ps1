function Set-OcwrOperationMode {
  <#
    .SYNOPSIS
      Determine the primary operation mode.

    .DESCRIPTION
      This function determines the primary operation mode based on
      $script:custom_name, which would have been standardized by
      `Confirm-SpecialSwitch` if it was a variant.

      If $script:custom_name still contains a special code (e.g. "onecl0ckrar"),
      it will fall to the 'default' case here if not matched by specific
      variants. The special code itself is handled by `Get-SpecialCode`.
  #>

  switch ($script:custom_name) {
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
      # When both overwrite and download-only is set, the function is changed
      # to keep the download but allow installation
      $script:DOWNLOAD_ONLY = $false
      $script:KEEP_DOWNLOAD = $true
      break
    }
    default { &$Error_UnknownScript }
  }
}