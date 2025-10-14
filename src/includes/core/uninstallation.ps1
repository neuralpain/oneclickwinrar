if ($rarloc -eq $loc96) {
  Write-Warn "Both 32-bit and 64-bit versions of WinRAR exist on the system. $(Format-Text "Select one to remove." -Foreground Red -Formatting Underline)"
  do {
    $query = Read-Host "Enter `"1`" for 32-bit and `"2`" for 64-bit"
    if ($query -eq 1) { $rarloc = $loc32; break }
    elseif ($query -eq 2) { $rarloc = $loc32; break }
  } while ($true)
}

if (Test-Path "$rarloc\Uninstall.exe" -PathType Leaf) {
  Write-Host "Uninstalling WinRAR ($(if($rarloc -eq $loc64){'x64'}else{'x32'}))... "
  Start-Process "$rarloc\Uninstall.exe" "/s" -Wait
  &$UninstallSuccess
} else {
  &$Error_UninstallerMissing
}