# setup-windows.ps1 - one-shot dev setup for building Raaga on Windows.
#
# What it does, in order:
#   1. Verifies (or installs) the Rust MSVC toolchain + the Tauri CLI.
#   2. Enables pnpm through corepack (bundled with Node).
#   3. Downloads a prebuilt libmpv dev package (shinchiro), extracts libmpv-2.dll.
#   4. Builds an MSVC import library (mpv.lib) from the DLL's export table.
#   5. Copies libmpv-2.dll into src-tauri\ and points Cargo's linker at the lib dir.
#   6. Builds the UI and launches the app with `cargo tauri dev`.
#
# Run from a normal PowerShell in the repo root:
#     powershell -ExecutionPolicy Bypass -File .\setup-windows.ps1
#
# Re-runnable: each step skips itself if already done. Pass -SkipRun to set up
# without launching, or -Build for a release build instead of dev.
#
# Low on C: space? Rust and the VS Build Tools install to D:\raaga-tools by default
# (change with -InstallDir 'X:\somewhere'). ~1-2 GB of VS shared components + the
# Windows SDK still go to C: no matter what - that part can't be relocated.

param(
    [switch]$SkipRun,
    [switch]$Build,
    [string]$InstallDir = 'D:\raaga-tools'   # C: is tight - put Rust + VS Build Tools here
)

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$mpvDir = Join-Path $repo '.mpv-dev'   # gitignored scratch dir for the libmpv package

# --- Keep the big installs off C: -------------------------------------------------------------
# Rust's toolchain + crate cache and the VS Build Tools payload are the space hogs; point them at
# $InstallDir on D:. Note: a ~1-2 GB slice of VS (the Windows SDK + shared MSBuild) always lands
# on C: regardless of --installPath - that half can't be moved.
$cargoHome  = Join-Path $InstallDir 'cargo'
$rustupHome = Join-Path $InstallDir 'rustup'
$vsInstall  = Join-Path $InstallDir 'BuildTools'
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
$env:CARGO_HOME  = $cargoHome
$env:RUSTUP_HOME = $rustupHome
$env:Path = "$cargoHome\bin;$env:Path"
# Persist so future shells (and later `cargo tauri` runs) use the D: locations too.
[Environment]::SetEnvironmentVariable('CARGO_HOME',  $cargoHome,  'User')
[Environment]::SetEnvironmentVariable('RUSTUP_HOME', $rustupHome, 'User')

function Step($msg) { Write-Host "`n=== $msg ===" -ForegroundColor Cyan }
function Have($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

# --- 1. Rust + Tauri CLI ----------------------------------------------------------------------
Step 'Rust toolchain'
if (-not (Have 'cargo')) {
    if (Have 'winget') {
        Write-Host 'Installing Rustup via winget...'
        winget install --id Rustlang.Rustup -e --accept-source-agreements --accept-package-agreements
    } else {
        throw 'cargo not found and winget unavailable. Install Rust from https://rustup.rs then re-run.'
    }
    # rustup honors CARGO_HOME/RUSTUP_HOME (set above); cargo lands in $cargoHome\bin.
    $env:Path = "$cargoHome\bin;$env:Path"
}
if (-not (Have 'cargo')) { throw 'Rust still not on PATH. Close and reopen PowerShell, then re-run this script.' }
rustup default stable-msvc | Out-Host
Write-Host "cargo: $(cargo --version)"

Step 'C++ build tools (for the MSVC linker: link.exe / dumpbin / lib)'
# vswhere ships with any recent VS/BuildTools, but its mere presence does NOT mean the C++
# workload is installed - VS Code or a prior partial install can leave vswhere behind with no
# VC tools. So probe for the actual VC.Tools component, not just for vswhere.
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vsSetup = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\setup.exe"
function Get-VCToolsPath {
    if (-not (Test-Path $vswhere)) { return $null }
    return (& $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath | Select-Object -First 1)
}
function Get-AnyVSPath {
    # Any VS/BuildTools install, regardless of workloads (used to modify one that lacks C++).
    # -all (not -latest) is required: -latest hides installs that are incomplete/broken - which
    # is exactly the state of a BuildTools install that has no workload yet.
    if (-not (Test-Path $vswhere)) { return $null }
    return (& $vswhere -all -products * -property installationPath | Select-Object -First 1)
}
if (-not (Get-VCToolsPath)) {
    $existingVS = Get-AnyVSPath
    if ($existingVS -and (Test-Path $vsSetup)) {
        # A VS/BuildTools install exists but WITHOUT the C++ workload. winget won't add a
        # workload to an install it thinks is up to date ("No available upgrade found"), so drive
        # the VS Installer's `modify` verb directly to add VCTools to the existing installation.
        Write-Host "Existing VS install found at $existingVS but the C++ workload is missing."
        Write-Host "Adding 'Desktop development with C++' (VCTools) to it - downloads ~2-4 GB. Be patient..."
        $p = Start-Process -FilePath $vsSetup -Wait -PassThru -ArgumentList @(
            'modify', '--installPath', "`"$existingVS`"",
            '--add', 'Microsoft.VisualStudio.Workload.VCTools', '--includeRecommended',
            '--quiet', '--norestart'
        )
        Write-Host "VS Installer exit code: $($p.ExitCode)"
        # setup.exe can hand off to a detached vs_installer process and return early; wait for any
        # lingering installer processes so the workload is fully in place before we re-check.
        Get-Process -Name 'vs_installer', 'vs_installershell', 'setup' -ErrorAction SilentlyContinue |
            Wait-Process -Timeout 3600 -ErrorAction SilentlyContinue
    } elseif (Have 'winget') {
        Write-Host "Installing VS 2022 Build Tools (C++ workload) to $vsInstall - large (~2-3 GB here, plus ~1-2 GB of Windows SDK that always lands on C:). Be patient..."
        winget install --id Microsoft.VisualStudio.2022.BuildTools -e --accept-source-agreements --accept-package-agreements `
            --override "--quiet --wait --norestart --installPath `"$vsInstall`" --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
    } else {
        throw 'C++ build tools (VC.Tools) not installed and winget unavailable. Install "Desktop development with C++" from the VS Build Tools installer, then re-run.'
    }
    if (-not (Get-VCToolsPath)) {
        throw 'VS Build Tools finished but the C++ tools are still not detected. Open a NEW PowerShell and re-run this script; if it persists, launch the Visual Studio Installer and add the "Desktop development with C++" workload.'
    }
}
Write-Host "C++ tools: $(Get-VCToolsPath)"

Step 'Tauri CLI'
if (-not (Have 'cargo-tauri')) {
    cargo install tauri-cli --version "^2" | Out-Host
} else {
    Write-Host "tauri: $(cargo tauri --version)"
}

# --- 2. pnpm via corepack ---------------------------------------------------------------------
Step 'pnpm (via corepack)'
if (-not (Have 'node')) { throw 'Node.js not found. Install it from https://nodejs.org (LTS) then re-run.' }
corepack enable | Out-Null
corepack prepare pnpm@latest --activate | Out-Host
# --- 3. Download libmpv dev package (shinchiro) -----------------------------------------------
Step 'libmpv dev package'
$dll = Join-Path $mpvDir 'libmpv-2.dll'
if (-not (Test-Path $dll)) {
    New-Item -ItemType Directory -Force -Path $mpvDir | Out-Null
    Write-Host 'Resolving latest mpv-dev x86_64 release...'
    $rel = Invoke-RestMethod -Uri 'https://api.github.com/repos/shinchiro/mpv-winbuild-cmake/releases/latest' `
        -Headers @{ 'User-Agent' = 'raaga-setup' }
    # Plain x86_64 dev package - NOT -v3- (that one needs AVX2), NOT the player builds.
    $asset = $rel.assets | Where-Object { $_.name -match '^mpv-dev-x86_64-\d' -and $_.name -notmatch 'v3' } | Select-Object -First 1
    if (-not $asset) { throw 'Could not find an mpv-dev-x86_64 asset in the latest release.' }
    $archive = Join-Path $mpvDir $asset.name
    Write-Host "Downloading $($asset.name) ..."
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $archive

    # Extract the .7z. Windows has no native 7z; use 7-Zip (install via winget if missing).
    if (-not (Have '7z')) {
        $sevenZ = "$env:ProgramFiles\7-Zip\7z.exe"
        if (-not (Test-Path $sevenZ)) {
            if (Have 'winget') {
                Write-Host 'Installing 7-Zip...'
                winget install --id 7zip.7zip -e --accept-source-agreements --accept-package-agreements
            } else { throw '7-Zip needed to extract the .7z and winget unavailable. Install 7-Zip, then re-run.' }
        }
        Set-Alias 7z $sevenZ -Scope Script
    }
    7z x $archive "-o$mpvDir" -y | Out-Null
    if (-not (Test-Path $dll)) { throw "libmpv-2.dll not found after extraction in $mpvDir." }
}
Write-Host "libmpv-2.dll ready: $dll"

# --- 4. Build the MSVC import library (mpv.lib) -----------------------------------------------
Step 'MSVC import library'
$lib = Join-Path $mpvDir 'mpv.lib'
if (-not (Test-Path $lib)) {
    # dumpbin / lib live under the VS install; import their environment via vcvars64.bat.
    if (-not (Test-Path $vswhere)) { throw 'vswhere not found; VS Build Tools install may have failed.' }
    $vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if (-not $vsPath) { throw 'No VS install with the C++ tools found. Re-run after the Build Tools finish installing.' }
    $vcvars = Join-Path $vsPath 'VC\Auxiliary\Build\vcvars64.bat'

    # Emit exported symbol names -> mpv.def -> mpv.lib, all inside the vcvars environment.
    $script = @"
call "$vcvars" >nul
cd /d "$mpvDir"
dumpbin /exports libmpv-2.dll > exports.txt
"@
    $bat = Join-Path $mpvDir '_mkdef.bat'
    Set-Content -Path $bat -Value $script -Encoding ascii
    cmd /c $bat | Out-Null

    # Parse the export table for the symbol names (column 4 of the numbered rows).
    $names = Select-String -Path (Join-Path $mpvDir 'exports.txt') -Pattern '^\s+\d+\s+[0-9A-Fa-f]+\s+[0-9A-Fa-f]+\s+(\w+)' |
        ForEach-Object { $_.Matches[0].Groups[1].Value }
    if (-not $names) { throw 'No exports parsed from libmpv-2.dll.' }
    (@('EXPORTS') + ($names | ForEach-Object { "    $_" })) | Set-Content (Join-Path $mpvDir 'mpv.def') -Encoding ascii

    $script2 = @"
call "$vcvars" >nul
cd /d "$mpvDir"
lib /def:mpv.def /name:libmpv-2.dll /out:mpv.lib /machine:x64
"@
    Set-Content -Path $bat -Value $script2 -Encoding ascii
    cmd /c $bat | Out-Host
    if (-not (Test-Path $lib)) { throw 'Failed to build mpv.lib.' }
}
Write-Host "mpv.lib ready: $lib"

# --- 5. Wire the DLL + linker path ------------------------------------------------------------
Step 'DLL placement + Cargo linker path'
Copy-Item $dll (Join-Path $repo 'src-tauri\libmpv-2.dll') -Force
# Cargo config in CARGO_HOME (on D:) so every build finds mpv.lib (machine-specific: never committed).
New-Item -ItemType Directory -Force -Path $cargoHome | Out-Null
$cargoCfg = Join-Path $cargoHome 'config.toml'
$mpvEsc = $mpvDir -replace '\\', '\\'
$line = "rustflags = [`"-L`", `"native=$mpvEsc`"]"
$existing = if (Test-Path $cargoCfg) { Get-Content $cargoCfg -Raw } else { '' }
if ($existing -notmatch [regex]::Escape($mpvEsc)) {
    Add-Content -Path $cargoCfg -Value "`n[build]`n$line"
    Write-Host "Added linker path to $cargoCfg"
} else {
    Write-Host "Linker path already in $cargoCfg"
}

# --- 6. Build UI + run ------------------------------------------------------------------------
Step 'Build UI'
Push-Location (Join-Path $repo 'ui')
try {
    corepack pnpm install | Out-Host
    corepack pnpm build | Out-Host
} finally { Pop-Location }

if ($SkipRun) {
    Write-Host "`nSetup complete. Run 'cargo tauri dev' from $repo to launch." -ForegroundColor Green
    return
}

Step ($(if ($Build) { 'cargo tauri build (release)' } else { 'cargo tauri dev' }))
Push-Location $repo
try {
    if ($Build) { cargo tauri build | Out-Host } else { cargo tauri dev | Out-Host }
} finally { Pop-Location }

