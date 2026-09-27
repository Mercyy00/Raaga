$ErrorActionPreference = 'Stop'
$env:CARGO_HOME  = 'D:\raaga-tools\cargo'
$env:RUSTUP_HOME = 'D:\raaga-tools\rustup'

# tauri's beforeBuildCommand runs `pnpm build`, so pnpm must be a real command on PATH.
# corepack enable normally writes shims into C:\Program Files\nodejs (needs admin, fails silently),
# so instead point corepack's shims at a writable dir on D: and prepend it to PATH.
$binDir = 'D:\raaga-tools\bin'
New-Item -ItemType Directory -Force -Path $binDir | Out-Null
corepack enable pnpm --install-directory $binDir
$env:Path = "$binDir;D:\raaga-tools\cargo\bin;$env:Path"

Write-Host "pnpm: $((Get-Command pnpm -ErrorAction SilentlyContinue).Source)"
Write-Host "cargo-tauri: $((Get-Command cargo-tauri -ErrorAction SilentlyContinue).Source)"

Set-Location 'D:\engineers\web-projects\newmusic product\limusic'
cargo tauri build
