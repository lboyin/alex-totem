# setup-fork.ps1 — clones keypeek into ../keypeek, applies the combo patch,
# wires up your GitHub fork, and shows next steps.
#
# Usage (from PowerShell in C:\Users\AlexLai\Documents\Totem):
#   ./keypeek-combos/setup-fork.ps1 -GithubUser <your-github-username>
#
# Prereqs:
#   * git installed and on PATH
#   * a fork of srwi/keypeek already created in your GitHub account
#     (go to https://github.com/srwi/keypeek and click "Fork")

param(
    [Parameter(Mandatory=$true)][string]$GithubUser
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$keypeekDir = Join-Path $root "keypeek"
$patch = Join-Path $PSScriptRoot "combo-display.patch"
$combos = Join-Path $PSScriptRoot "combos.yaml"

Write-Host "Cleaning any leftover keypeek folder..." -ForegroundColor Cyan
if (Test-Path $keypeekDir) {
    Remove-Item -Recurse -Force $keypeekDir
}

Write-Host "Cloning srwi/keypeek..." -ForegroundColor Cyan
git clone https://github.com/srwi/keypeek.git $keypeekDir
if ($LASTEXITCODE -ne 0) { throw "git clone failed" }

Push-Location $keypeekDir
try {
    Write-Host "Creating combo-display branch..." -ForegroundColor Cyan
    git checkout -b combo-display

    Write-Host "Applying combo patch..." -ForegroundColor Cyan
    git apply $patch
    if ($LASTEXITCODE -ne 0) { throw "patch failed" }

    git add -A
    git commit -m "Add combo overlay rendered from combos.yaml"

    Write-Host "Pointing origin at your fork (github.com/$GithubUser/keypeek)..." -ForegroundColor Cyan
    git remote set-url origin "https://github.com/$GithubUser/keypeek.git"
    git remote add upstream "https://github.com/srwi/keypeek.git" 2>$null

    Write-Host ""
    Write-Host "Done." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Push to your fork:"
    Write-Host "       cd ..\keypeek"
    Write-Host "       git push -u origin combo-display"
    Write-Host ""
    Write-Host "  2. Build (requires Rust from https://rustup.rs/):"
    Write-Host "       cargo build --release"
    Write-Host ""
    Write-Host "  3. Copy combos.yaml next to the built exe:"
    Write-Host "       Copy-Item ..\keypeek-combos\combos.yaml target\release\"
    Write-Host ""
    Write-Host "  4. Run it:"
    Write-Host "       .\target\release\keypeek.exe"
} finally {
    Pop-Location
}
