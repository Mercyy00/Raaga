$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$in  = 'D:\engineers\web-projects\newmusic product\limusic\brand\logo_image.png'
$out = 'D:\engineers\web-projects\newmusic product\limusic\brand\logo_icon_source.png'

$src = [System.Drawing.Bitmap]::FromFile($in)
$w = $src.Width; $h = $src.Height
Write-Host "source ${w}x${h}"

# Normalize to 32bppArgb so LockBits has a known layout (BGRA).
$bmp = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g0 = [System.Drawing.Graphics]::FromImage($bmp)
$g0.DrawImage($src, 0, 0, $w, $h); $g0.Dispose(); $src.Dispose()

$rect = New-Object System.Drawing.Rectangle 0, 0, $w, $h
$data = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$stride = $data.Stride
$bytes = New-Object byte[] ($stride * $h)
[System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)
$bmp.UnlockBits($data)

# Background = corner pixel (cream). Find bbox of everything that differs from it.
$bgB = $bytes[0]; $bgG = $bytes[1]; $bgR = $bytes[2]
$minx = $w; $miny = $h; $maxx = 0; $maxy = 0
$thr = 45
for ($y = 0; $y -lt $h; $y += 2) {
    $row = $y * $stride
    for ($x = 0; $x -lt $w; $x += 2) {
        $i = $row + $x * 4
        $d = [Math]::Abs($bytes[$i + 2] - $bgR) + [Math]::Abs($bytes[$i + 1] - $bgG) + [Math]::Abs($bytes[$i] - $bgB)
        if ($d -gt $thr) {
            if ($x -lt $minx) { $minx = $x }
            if ($x -gt $maxx) { $maxx = $x }
            if ($y -lt $miny) { $miny = $y }
            if ($y -gt $maxy) { $maxy = $y }
        }
    }
}
Write-Host "content bbox x[$minx..$maxx] y[$miny..$maxy]"

$bw = $maxx - $minx + 1; $bh = $maxy - $miny + 1
$cx = ($minx + $maxx) / 2.0; $cy = ($miny + $maxy) / 2.0
$boxSize = [Math]::Max($bw, $bh)
$side = [int]($boxSize * 1.34)   # ~17% padding each side
$left = [int]($cx - $side / 2.0)
$top  = [int]($cy - $side / 2.0)

$outSize = 1024
$dst = New-Object System.Drawing.Bitmap $outSize, $outSize, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($dst)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.Clear([System.Drawing.Color]::FromArgb(255, $bgR, $bgG, $bgB))
$destRect = New-Object System.Drawing.Rectangle 0, 0, $outSize, $outSize
$g.DrawImage($bmp, $destRect, $left, $top, $side, $side, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose(); $bmp.Dispose()
$dst.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$dst.Dispose()
Write-Host "wrote $out (${outSize}x${outSize})"
