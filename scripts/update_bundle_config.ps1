$ErrorActionPreference = "Stop"

$root = Resolve-Path "$PSScriptRoot\.."
$configPath = Join-Path $root "bundle.config.json"

$config = Get-Content $configPath -Raw | ConvertFrom-Json

function Get-LatestSdkVersionForChannel {
  param(
    [Parameter(Mandatory=$true)][string]$Channel
  )

  $metaUrl = "https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/$Channel/releases.json"
  $meta = Invoke-RestMethod -Uri $metaUrl

  $versions = @()
  foreach ($rel in $meta.releases) {
    if ($rel.sdk -and $rel.sdk.version) {
      $versions += [Version]$rel.sdk.version
    }
  }

  if (-not $versions.Count) {
    throw "No SDK versions found for channel $Channel"
  }

  ($versions | Sort-Object -Descending | Select-Object -First 1).ToString()
}

$existing = @($config.dotnet_sdk_versions)
$channels = $existing |
  ForEach-Object { ($_ -split "\.")[0..1] -join "." } |
  Select-Object -Unique

$latest = @()
foreach ($ch in $channels) {
  $latest += Get-LatestSdkVersionForChannel -Channel $ch
}

$latest = $latest | Sort-Object { [Version]$_ }

$config.dotnet_sdk_versions = $latest

$config | ConvertTo-Json -Depth 10 | Set-Content -Encoding utf8 $configPath

Write-Host "Updated dotnet_sdk_versions:"
$latest | ForEach-Object { Write-Host " - $_" }
