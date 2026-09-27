$ErrorActionPreference = 'Stop'
$env:CARGO_HOME  = 'D:\raaga-tools\cargo'
$env:RUSTUP_HOME = 'D:\raaga-tools\rustup'
$env:Path = "D:\raaga-tools\cargo\bin;$env:Path"
Set-Location 'D:\engineers\web-projects\newmusic product\limusic'
cargo tauri icon 'brand\logo_icon_source.png'

# `cargo tauri icon` does not emit 64x64.png, but tauri.conf.json lists it. Generate it so the
# bundle doesn't ship the stale upstream 64x64 art.
Add-Type -AssemblyName System.Drawing
$src = [System.Drawing.Bitmap]::FromFile('D:\engineers\web-projects\newmusic product\limusic\brand\logo_icon_source.png')
$dst = New-Object System.Drawing.Bitmap 64, 64, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($dst)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($src, 0, 0, 64, 64)
$g.Dispose(); $src.Dispose()
$dst.Save('D:\engineers\web-projects\newmusic product\limusic\src-tauri\icons\64x64.png', [System.Drawing.Imaging.ImageFormat]::Png)
$dst.Dispose()
Write-Host "regenerated 64x64.png"
