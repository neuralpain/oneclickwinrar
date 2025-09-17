function Confirm-QueryResult {
  <#
    .DESCRIPTION
      A function for structuring queries better within the code.
      The code does not have to be altered much to change the way the response
      is received; thereby enhancing readability and efficiency.

    .EXAMPLE
      Confirm-QueryResult -Expect[Positive|Negative] `
        -Query "...?" `
        -ResultPositive { ... } `
        -ResultNegative { ... }
  #>
  [CmdletBinding()]
  param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$Query,
    [switch]$ExpectPositive,
    [switch]$ExpectNegative,
    [Parameter(Mandatory=$true)]
    [scriptblock]$ResultPositive,
    [Parameter(Mandatory=$true)]
    [scriptblock]$ResultNegative
  )

  $q = Read-Host "$Query $(if($ExpectPositive){"(Y/n)"}elseif($ExpectNegative){"(y/N)"})"

  if($ExpectPositive){
    if (-not([string]::IsNullOrEmpty($q)) -and ($q.Length -eq 1 -and $q -match '(N|n)')) {
      if ($ResultNegative) { & $ResultNegative }
    } else {
      if ($ResultPositive) { & $ResultPositive } # Default is positive
    }
  }
  elseif($ExpectNegative){
    if (-not([string]::IsNullOrEmpty($q)) -and ($q.Length -eq 1 -and $q -match '(Y|y)')) {
      if ($ResultPositive) { & $ResultPositive }
    } else {
      if ($ResultNegative) { & $ResultNegative } # Default is negative
    }
  }
  else {
    Write-Err "Nothing to expect."
    Stop-OcwrOperation -ExitType Error
  }
}
