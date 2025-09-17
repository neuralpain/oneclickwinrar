  if ($script:WINRAR_INSTALLED_LOCATION -eq $loc96) {
    Select-WinrarInstallation # confirm 32/64-bit
  }

  switch ($script:WINRAR_INSTALLED_LOCATION) {
    $loc64 {
      $rarreg = $rarreg64
      $keygen = $keygen64
      $keygenUrl = $keygenUrl64
      break
    }
    $loc32 {
      $rarreg = $rarreg32
      $keygen = $keygen32
      $keygenUrl = $keygenUrl32
      break
    }
  }