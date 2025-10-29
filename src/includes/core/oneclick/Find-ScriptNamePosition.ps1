function Find-ScriptNamePosition {
  <#
    .SYNOPSIS
      Verify and validate the script name.

    .DESCRIPTION
      Verifies the position of the script name from a custom config.
      The script name is at either position [0] or position [2].
      Extra verification is done to ensure that a valid script name exists.
  #>
  Param($Config)

  $position = 0

  foreach ($data in $Config) {
    $data = $data.Value

    if ($position -notin (0,1,2)) {
      # 0     --- General use
      # 1, 2  --- Licensing requetsed
      $position++  # Increment conceptual position
      continue     # Skip this data item
    }

    $one = ([regex]::matches($data, 'one')).Count -gt 0
    $rar = ([regex]::matches($data, 'rar')).Count -gt 0
    $d_code = ([regex]::matches($data, '\d{1}')).Count -gt 0
    $i_char = ([regex]::matches($data, 'i')).Count -gt 0

    if ($one -and $rar) {
      if (($i_char -and $d_code) -or (-not $i_char -and -not $d_code)) {
        &$Error_UnknownScript; exit
      }
      $script:custom_name = $data # Assign the STRING value
      $script:SCRIPT_NAME_LOCATION = $position
      break
    }
    else {
      $position++  # Increment conceptual position
    }
  }

  if ($null -eq $script:custom_name) {
    &$Error_UnknownScript; exit
  }
}