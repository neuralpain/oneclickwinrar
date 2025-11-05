function Test-WinrarVersionAvailability {
  <#
    .SYNOPSIS
      Checks a list of URLs to verify if they likely point to valid
      download.

    .DESCRIPTION
      This script takes a version number as input. For each URL, it performs an
      HTTP HEAD request to retrieve the headers. It then analyzes the StatusCode
      header to determine if the URL is accessible to download files.

    .PARAMETER Version
      A version number to test for validation.

    .EXAMPLE
      Test-WinrarVersionAvailability -Version 712

    .OUTPUTS
      System.Boolean. The function returns $true if at least one URL returns a
      200 OK status code. Otherwise, it implicitly returns $null.
  #>
  Param([Parameter(Mandatory = $true)][int]$Version)

  $URLs = $(
    "$server1/winrar-x64-${Version}.exe",
    "$($server2[0])/winrar-x64-${Version}.exe",
    "$($server2[1])/winrar-x64-${Version}.exe"
  )

  foreach ($url in $URLs) {
    try {
      $statusCode = $(Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop).StatusCode
      if ($statusCode -eq 200) {
        # if at least one of the URLs connect, then it's good.
        return $true # --- sentinel
      }
    }
    catch [System.Net.WebException] {
      # Will return 404 if the downloads are not available.
    }
    catch {
      # Generally, we don't care about the errors here. This function is only for
      # testing availability. If it can't connect in any way, it's invalid.
    }
  }
}

function Find-WinrarUpdates {
  <#
    .SYNOPSIS
      Checks for new versions of WinRAR available for download.

    .DESCRIPTION
      This function takes an array of known versions `$kvList` and splits the latest
      known version (at index `0`) into the semantic pattern variables `$patch`,
      `$minor` and `$major`. The function then checks for the availability of
      the next 10 iterative versions. If a version is found, it is added to a
      `$newVersions` list that is then sorted, compared and returned if
      successful. If not, it returns $null.

    .PARAMETER kvList
      An array of strings containing the known version numbers to check for
      updates against.

    .OUTPUTS
      System.String[]. An array of strings containing the new version numbers
      found, sorted from newest to oldest. If no new versions are found, it
      returns $null.
  #>
  Param([string[]]$kvList)

  $patch = [int]($kvList[0] % 10)
  $minor = [int](($kvList[0] % 100) / 10)
  $major = [int](($kvList[0] % 1000) / 100)

  $newVersions = @()

  Write-Info "Checking for WinRAR updates..."

  for ($j = $minor; $j -le $minor+1; $j++) {
    if ($j -gt $minor) { $patch = 0 }
    for ($k = $patch; $k -lt 10; $k++) {
      $testVersion = $major*100 + $j*10 + $k
      if ((Test-WinrarVersionAvailability -Version $testVersion)) {
        $newVersions += $testVersion
      }
    }
  }

  if ($null -ne $newVersions) {
    $newVersions = $($newVersions | Sort-Object -Descending)
    $newVersion = $newVersions[0]
    if ($newVersion -gt $kvList[0]) {
      Write-Info "New version found. Updating dedault version to $(Format-Text $newVersion -Foreground White)"
      return $newVersions
    } else {
      Write-Info "No WinRAR updates found."
      return $null
    }
  }
}

function Get-WinrarLatestVersion {
  <#
    .SYNOPSIS
      Checks for latest version of WinRAR.

    .DESCRIPTION
      This function scrapes the www.rarlab.com website for the latest version of
      WinRAR listed in the "What's New" page context. If unsuccessful, the
      functiosn returns `0`.

    .OUTPUTS
      System.Int32. The latest version as an integer. If a new version has not
      been found, the function returns `0`.
  #>
  # Public changelog
  $url = "https://www.rarlab.com/WhatsNew.txt"
  # User agent to avoid being blocked
  $userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"

  Write-Info "Checking latest WinRAR version..."

  try {
    $htmlContent = Invoke-WebRequest -Uri $url -UserAgent $userAgent -UseBasicParsing | Select-Object -ExpandProperty Content
    $_matches = [regex]::Matches($htmlContent, '(?i)(?!\s+Version)\s+(\d+\.\d+)(?!\s+beta)')

    if (-not $_matches.Count) {
      Write-Err "Unable to find latest version. The page content might have changed or the request was blocked."
      return 0
    }

    $versions = $_matches | Select-Object -Unique | ForEach-Object {
      try {
        $_version = [double]$_.Value * 100

        if (Test-WinrarVersionAvailability $_version) {
          $_version
        } else {
          0 # return '0' as version value
        }
      }
      catch {
        # Skip any invalid version strings
      }
    }

    if ($versions.Count -eq 0) {
      Write-Err "No valid version numbers were found."
      return 0
    }

    $latestVersion = $versions | Sort-Object -Descending | Select-Object -First 1
    return $latestVersion
  }
  catch {
    Write-Err "$($_.Exception.Message)"
    return 2 # skip updates
  }
}

function Add-ToKnownVersionsList {
  Param([string]$Version)
  $script:KNOWN_VERSIONS += $Version
  $script:KNOWN_VERSIONS = $script:KNOWN_VERSIONS | Sort-Object -Descending
}

function Update-KnownVersionsList {
  $local:vl = Find-WinrarUpdates -kvList $script:KNOWN_VERSIONS
  if ($null -ne $local:vl) {
    Add-ToKnownVersionsList -Version $local:vl
  }
}

function Update-WinrarLatestVersion {
  if (Test-Connection $server1_host -Count 2 -Quiet) {
    $local:v = (Get-WinrarLatestVersion)

    switch ($local:v) {
      0 {
        Update-KnownVersionsList
      }
      2 {
        Write-Info "Skipping update checks..."
      }
      $script:LATEST {
        Write-Info "Default version is the latest version."
      }
      Default {
        Add-ToKnownVersionsList -Version $local:v
        Write-Info "Updated default version to latest version."
      }
    }

    $script:LATEST = $script:KNOWN_VERSIONS[0]
  } else {
    Write-Info "No internet connection found."
    Write-Info "Skipping update checks..."
  }
}