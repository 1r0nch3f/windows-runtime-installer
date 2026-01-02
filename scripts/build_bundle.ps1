param(
  [string]$Tag = "v1.0"
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path "$PSScriptRoot\.."
$configPath = Join-Path $root "bundle.config.json"
$config = Get-Content $configPath -Raw | ConvertFrom-Json

$outRoot = Join-Path $root "out"
$bundle = Join-Path $outRoot "bundle"
$zipName = "windows-runtime-installer-$Tag.zip"
$zipPath = Join-Path $outRoot $zipName

# Clean output
if (Test-Path $outRoot) { Remove-Item $outRoot -Recurse -Force }
New-Item -ItemType Directory -Path $bundle | Out-Null

# Create expected folder layout
$dotnetDir = Join-Path $bundle "DotNet-SDK"
$vcDir     = Join-Path $bundle "Microsoft-Visual-C-Runtimes-ALL-Install"

New-Item -ItemType Directory -Path $dotnetDir, $vcDir | Out-Null

# Copy repo files into the bundle root
Copy-Item (Join-Path $root "RunMe.bat") -Destination $bundle
if (Test-Path (Join-Path $root "README.md")) {
  Copy-Item (Join-Path $root "README.md") -Destination $bundle
}

# Copy helper bat files if present in repo
$dotnetBat = Join-Path $root "DotNet-SDK\dotnet.bat"
if (Test-Path $dotnetBat) { Copy-Item $dotnetBat -Destination $dotnetDir }

$mstBat = Join-Path $root "Microsoft-Visual-C-Runtimes-ALL-Install\mst.bat"
if (Test-Path $mstBat) { Copy-Item $mstBat -Destination $vcDir }

function Download-File {
  param(
    [Parameter(Mandatory=$true)][string]$Url,
    [Parameter(Mandatory=$true)][string]$OutFile
  )
  Write-Host "Downloading: $Url"
  Invoke-WebRequest -Uri $Url -OutFile $OutFile
}

# VC++ Redist (official stable links)
if ($config.include_vc_redist) {
  Download-File "https://aka.ms/vs/17/release/vc_redist.x64.exe" (Join-Path $vcDir "vc_redist.x64.exe")
  Download-File "https://aka.ms/vs/17/release/vc_redist.x86.exe" (Join-Path $vcDir "vc_redist.x86.exe")
}

# NOTE:
# DirectX June 2010 is intentionally NOT downloaded in CI.
# RunMe.bat can handle DirectX locally if you keep it in your repo for offline installs.

# .NET SDK installers via official release metadata
function Get-DotNetSdkInstallerUrl {
  param(
    [Parameter(Mandatory=$true)][string]$SdkVersion
  )

  $parts = $SdkVersion.Split(".")
  $channel = "$($parts[0]).$($parts[1])"

  $metaUrl = "https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/$channel/releases.json"
  Write-Host "Fetching .NET metadata: $metaUrl"
  $meta = Invoke-RestMethod -Uri $metaUrl

  foreach ($rel in $meta.releases) {
    if ($rel.sdk.version -eq $SdkVersion) {
      foreach ($file in $rel.sdk.files) {
        if ($file.rid -eq "win-x64" -and $file.name -like "*.exe" -and $file.url) {
          return $file.url
        }
      }
    }
  }

  throw "Could not find installer URL for SDK $SdkVersion in channel $channel metadata."
}

foreach ($v in $config.dotnet_sdk_versions) {
  $url = Get-DotNetSdkInstallerUrl -SdkVersion $v
  $out = Join-Path $dotnetDir ("dotnet-sdk-$v-win-x64.exe")
  Download-File $url $out
}

# Zip bundle
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path (Join-Path $bundle "*") -DestinationPath $zipPath

Write-Host "Created: $zipPath"
