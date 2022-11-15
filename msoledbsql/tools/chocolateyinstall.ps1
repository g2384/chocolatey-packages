$ErrorActionPreference = 'Stop'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$url        = 'https://download.microsoft.com/download/b/e/5/be58d85a-66dd-4dac-87d4-30d224a317b9/en-US/19.1.0.0/x86/msoledbsql.msi'
$url64      = 'https://download.microsoft.com/download/b/e/5/be58d85a-66dd-4dac-87d4-30d224a317b9/en-US/19.1.0.0/x64/msoledbsql.msi'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  fileType      = 'msi'
  url           = $url
  url64bit      = $url64

  softwareName  = 'Microsoft OLE DB Driver for SQL Server'

  checksum      = '0B33D8BF3E54BF8DBD8E94D0EB26780F25E4EE7668B832C78E17406A361A480F'
  checksumType  = 'sha256'
  checksum64    = '28E74AEBA43C220FA52A93D26546381C3095C0B5D71A6A2B4AF540548ED2B725'
  checksumType64= 'sha256'

  # MSI
  silentArgs    = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`" IACCEPTMSOLEDBSQLLICENSETERMS=YES"
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
