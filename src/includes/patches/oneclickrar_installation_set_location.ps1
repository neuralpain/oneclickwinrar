  switch ($script:ARCH) {
    'x64' {
      $script:WINRAR_INSTALLED_LOCATION = $loc64
      break
    }
    'x32' {
      $script:WINRAR_INSTALLED_LOCATION = $loc64
      break
    }
  }
