﻿Import-Module AU

$releases = 'https://www.blender.org/download/'
$softwareName = 'Blender'

function global:au_BeforeUpdate { 
    $Latest.Checksum64 = Get-RemoteChecksum $Latest.URL64 
}

function global:au_SearchReplace {
  @{
    ".\tools\chocolateyInstall.ps1" = @{
      "(?i)^(\s*softwareName\s*=\s*)'.*'" = "`${1}'$softwareName'"
      "(?i)^(\s*url64\s*=\s*)'.*'"        = "`${1}'$($Latest.URL64)'"
      "(?i)^(\s*checksum64\s*=\s*)'.*'"   = "`${1}'$($Latest.Checksum64)'"
    }
    ".\tools\chocolateyUninstall.ps1" = @{
      "(?i)^(\s*softwareName\s*=\s*)'.*'" = "`${1}'$softwareName'"
    }
  }
}
function global:au_GetLatest {
  $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing

  $re = 'windows-x64\.msi\/$'
  $url64 = $download_page.links | ? href -match $re | select -first 1 -expand href

  $verRe = '-'
  $version64 = $url64 -split "$verRe" | select -First 1 -Skip 1

  if ($version64 -match '[a-z]$') {
    [char]$letter = $version64[$version64.Length - 1]
    [int]$num = $letter - [char]'a'
    $num++
    $version64 = $version64 -replace $letter,".$num"
  }

  @{
    URL64 = Get-ActualUrl $url64
    Version = $version64
  }
}

function Get-ActualUrl() {
  param([string]$url)

  $request = [System.Net.WebRequest]::Create($url)

  $response = $request.GetResponse()

  $headers = $response.Headers

  if ($headers["refresh"]) {
    $res = $headers["refresh"] -split '[;=]' | select -last 1
  } else {
    $res = $url
  }

  $response.Dispose()
  return $res
}

update -ChecksumFor none
