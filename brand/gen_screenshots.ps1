$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$shots = 'C:\Users\Perfect\Pictures\slideshow 1\Screenshots'
$out   = 'D:\engineers\web-projects\newmusic product\limusic\website\src\assets'

# source screenshot -> target asset name (no ext); maxw caps width (downscale only)
$map = @(
  @{ src = 'Screenshot 2026-09-27 090359.png'; name = 'screen-playlist';        maxw = 1600 },
  @{ src = 'Screenshot 2026-09-27 091554.png'; name = 'screen-album';           maxw = 1500 },
  @{ src = 'Screenshot 2026-09-27 090538.png'; name = 'screen-lyrics';          maxw = 1500 },
  @{ src = 'Screenshot 2026-09-27 090420.png'; name = 'screen-queue';           maxw = 1500 },
  @{ src = 'Screenshot 2026-09-27 090837.png'; name = 'screen-listen-together'; maxw = 1500 },
  @{ src = 'Screenshot 2026-09-27 090621.png'; name = 'screen-mini';            maxw = 1300 }
)

foreach ($m in $map) {
    $inPath = Join-Path $shots $m.src
    $src = [System.Drawing.Bitmap]::FromFile($inPath)
    $w = $src.Width; $h = $src.Height
    $scale = 1.0
    if ($w -gt $m.maxw) { $scale = $m.maxw / [double]$w }
    $nw = [int]($w * $scale); $nh = [int]($h * $scale)

    $dst = New-Object System.Drawing.Bitmap $nw, $nh, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($dst)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($src, 0, 0, $nw, $nh)
    $g.Dispose(); $src.Dispose()

    $outPath = Join-Path $out ($m.name + '.png')
    $dst.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $dst.Dispose()
    $kb = [int]((Get-Item $outPath).Length / 1024)
    Write-Host "$($m.name).png  ${nw}x${nh}  ${kb}KB"
}
Write-Host "done"
