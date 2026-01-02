# windows-runtime-installer automation pack

This adds a GitHub Actions workflow that:
- downloads installers from official Microsoft sources
- assembles a bundle with the expected folder layout
- zips it
- publishes it as a GitHub Release asset

## Files in this pack
- bundle.config.json: versions/toggles
- scripts/build_bundle.ps1: builds the ZIP under out/
- .github/workflows/release.yml: workflow you run from Actions
- DotNet-SDK/dotnet.bat: installs all *.exe in DotNet-SDK (version-agnostic)

## How to use
1. Copy these folders/files into the ROOT of your repo (same folder as RunMe.bat).
2. Commit and push.
3. In GitHub: Actions -> "Build and publish release" -> Run workflow -> enter tag like v1.1.
4. The Release will contain a ZIP asset you can download.

## Notes
- The workflow downloads vc_redist.x64.exe and vc_redist.x86.exe (2015-2022) via official aka.ms links.
- DirectX June 2010 redist is downloaded and extracted from Microsoft's download site.
- .NET SDK installers are discovered via the official releases.json metadata and downloaded.
