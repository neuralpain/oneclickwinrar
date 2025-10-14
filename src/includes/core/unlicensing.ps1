if (Test-Path "$rarloc\rarreg.key" -PathType Leaf) {
  Write-Host "Un-licensing WinRAR... "
  Remove-Item "$rarloc\rarreg.key" -Force | Out-Null
  &$UnlicenseSuccess
} else {
  &$Error_UnlicenseFailed
}