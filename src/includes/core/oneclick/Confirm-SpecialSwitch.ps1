function Confirm-SpecialSwitch {
  <#
    .SYNOPSIS
      Verify and enable special functions.

    .DESCRIPTION
      Verifies whether or not an special function was specified by `-one-` or
      `-rar` and then enables the respective function.
  #>

  $switch_one = ([regex]::matches($script:custom_name, 'one-')).Count -gt 0
  $switch_rar = ([regex]::matches($script:custom_name, '-rar')).Count -gt 0

  if ($switch_one -and $switch_rar) {
    $script:custom_name = $script_name_download_only_overwrite
  } elseif ($switch_one) {
    $script:custom_name = $script_name_download_only
  } elseif ($switch_rar) {
    $script:custom_name = $script_name_overwrite
  } else {
    $script:custom_name = $script_name
  }
}