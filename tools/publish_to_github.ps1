# Run from a PowerShell terminal inside the extracted AtlasLab_X directory.
# Requires git and GitHub authentication (e.g., Git Credential Manager).
# Replaces the previous AtlasLab-iOS contents. The repository history remains.
$ErrorActionPreference = 'Stop'
$repo = 'https://github.com/Kelsonya/AtlasLab-iOS.git'
$src = Split-Path -Parent $PSScriptRoot
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git is not installed. Install Git for Windows or use GitHub Desktop.'
}
Write-Host 'This will replace tracked files in the existing AtlasLab-iOS repository.' -ForegroundColor Yellow
$confirmation = Read-Host 'Type REPLACE to confirm'
if ($confirmation -cne 'REPLACE') { Write-Host 'Cancelled'; exit 0 }
$target = Join-Path $env:TEMP 'AtlasLabX-publish'
if (Test-Path $target) { throw "Please remove the old temporary folder first: $target" }
& git clone $repo $target
if ($LASTEXITCODE -ne 0) { throw 'Failed to clone the repository' }
Push-Location $target
try {
    & git rm -r -- .
    if ($LASTEXITCODE -ne 0) { throw 'git rm failed' }
    Get-ChildItem -LiteralPath $src -Force | ForEach-Object {
        if ($_.Name -ne '.git') { Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force }
    }
    & git add -A
    if ($LASTEXITCODE -ne 0) { throw 'git add failed' }
    & git commit -m 'Atlas Lab X: multi-module reverse engineering laboratory'
    if ($LASTEXITCODE -ne 0) { throw 'git commit failed' }
    & git push origin main
    if ($LASTEXITCODE -ne 0) { throw 'git push failed; local commit retained' }
    Write-Host 'Published successfully. Open GitHub -> Actions.' -ForegroundColor Green
}
finally { Pop-Location }
