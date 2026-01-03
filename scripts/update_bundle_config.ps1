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

foreach ($sdk in $bundle.dotnet.sdks) {
    $channel = $sdk.channel
    Write-Host "Checking .NET SDK channel $channel"

    $latest = Get-LatestStableSdk -Channel $channel

    if ($sdk.version -ne $latest) {
        Write-Host "Updating $channel from $($sdk.version) to $latest"
        $sdk.version = $latest
        $changed = $true
    } else {
        Write-Host "$channel already up to date ($latest)"
    }
}

if ($changed) {
    $bundle | ConvertTo-Json -Depth 5 | Set-Content $bundlePath -Encoding UTF8
    Write-Host "bundle.config.json updated"
} else {
    Write-Host "No changes required"
}
