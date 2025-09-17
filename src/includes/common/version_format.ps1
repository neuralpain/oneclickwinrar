function Format-VersionNumber {
  <#
    .DESCRIPTION
      Format version numbers as x.xx

    .EXAMPLE
      Format-VersionNumber -Version 710
  #>
  Param($VersionNumber)
  if ($null -eq $VersionNumber) { return $null }
  return "{0:N2}" -f ($VersionNumber / 100)
}

function Format-VersionNumberFromExecutable {
  <#
    .DESCRIPTION
      Retrieve the WinRAR version form the executable name and format it.

    .EXAMPLE
      Format-VersionNumberFromExecutable -Executable winrar-x64-712.exe
  #>
  Param(
    [Parameter(Mandatory=$true, Position=0)]
    $Executable
  )

  $version = if ($Executable -match "(?<version>\d{3})") { $matches['version'] }
             else { return $null }
  $version = Format-VersionNumber $version
  return $version
}
