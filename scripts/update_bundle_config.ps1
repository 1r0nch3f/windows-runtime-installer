# update_bundle_config.ps1
# Safe updater for bundle.config.json
# - Ignores preview / rc SDKs
# - Does NOT cast to System.Version
# - Stable-only, production safe

$ErrorActionPreference = "Stop"

$bundlePath = "bundle.config.json"
if (-not (Test-Path $bundlePath)) {
    Write-Error "bundle.config.json not found"
}

$bundle = Get-Content $bundlePath | ConvertFrom-Json

if (-not $bundle.dotnet_sdk_versions) {
    Write-Error "bundle.config.json is missing dotnet_sdk_versions"
}

function Get-LatestStableSdk {
    param (
        [string]$Channel
    )

    $url = "https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/$Channel/releases.json"
    $data = Invoke-RestMethod $url

    $stable = $data.releases |
        Where-Object { $_.sdk.version -notmatch "-" } |
        Sort-Object { $_.sdk.version } -Descending |
        Select-Object -First 1

    return $stable.sdk.version
}

$changed = $false
$updatedVersions = @()
$channelCache = @{}

foreach ($sdkVersion in $bundle.dotnet_sdk_versions) {
    if (-not $sdkVersion) {
        continue
    }

    $parts = $sdkVersion.Split(".")
    if ($parts.Length -lt 2) {
        Write-Host "Skipping invalid SDK version entry: $sdkVersion"
        $updatedVersions += $sdkVersion
        continue
    }

    $channel = "$($parts[0]).$($parts[1])"

    if (-not $channelCache.ContainsKey($channel)) {
        Write-Host "Checking .NET SDK channel $channel"
        $channelCache[$channel] = Get-LatestStableSdk -Channel $channel
    }

    $latest = $channelCache[$channel]

    if ($sdkVersion -ne $latest) {
        Write-Host "Updating $channel from $sdkVersion to $latest"
        $updatedVersions += $latest
        $changed = $true
    } else {
        Write-Host "$channel already up to date ($latest)"
        $updatedVersions += $sdkVersion
    }
}

if ($changed) {
    $bundle.dotnet_sdk_versions = $updatedVersions
    $bundle | ConvertTo-Json -Depth 5 | Set-Content $bundlePath -Encoding UTF8
    Write-Host "bundle.config.json updated"
} else {
    Write-Host "No changes required"
}
