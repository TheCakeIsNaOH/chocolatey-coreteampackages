﻿$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName            = 'mattermost-desktop'
  fileType               = 'msi'
  file                   = "$toolsDir\mattermost-desktop-5.10.0-win-arm64.msi"
  file64                 = "$toolsDir\mattermost-desktop-5.10.0-win-x64.msi"
  checksum               = '4E98AE04E3B64422CA4D222EE9CB13E8D097DD8B2FAD384782DCDAA8CBEFAC6D'
  checksum64             = 'BBE85376C3FF14D1FEE8467A34985DA938A051518C7E26E6BCAF371BBFFC39C1'
  checksumType           = 'sha256'
  checksumType64         = 'sha256'
  silentArgs             = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
  validExitCodes         = @(0, 3010, 1641)
  softwareName           = 'Mattermost*'
}

Install-ChocolateyInstallPackage @packageArgs

# Lets remove the installer and ignore files as there is no more need for them
Get-ChildItem $toolsDir\*.msi | ForEach-Object { Remove-Item $_ -ea 0; if (Test-Path $_) { Set-Content "$_.ignore" '' } }
