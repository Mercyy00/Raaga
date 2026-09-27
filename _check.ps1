$ErrorActionPreference = 'Stop'
$env:CARGO_HOME  = 'D:\raaga-tools\cargo'
$env:RUSTUP_HOME = 'D:\raaga-tools\rustup'
$binDir = 'D:\raaga-tools\bin'
New-Item -ItemType Directory -Force -Path $binDir | Out-Null
corepack enable pnpm --install-directory $binDir | Out-Null
$env:Path = "$binDir;D:\raaga-tools\cargo\bin;$env:Path"
Set-Location 'D:\engineers\web-projects\newmusic product\limusic\ui'
pnpm run check
