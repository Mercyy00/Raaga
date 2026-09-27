$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$in = 'D:\engineers\web-projects\newmusic product\limusic\brand\logo_icon_source.png'

# --- Build a transparent-background master by keying out the cream. ---
$src = [System.Drawing.Bitmap]::FromFile($in)
$w = $src.Width; $h = $src.Height
$bmp = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g0 = [System.Drawing.Graphics]::FromImage($bmp); $g0.DrawImage($src, 0, 0, $w, $h); $g0.Dispose(); $src.Dispose()

$rect = New-Object System.Drawing.Rectangle 0, 0, $w, $h
$data = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$stride = $data.Stride
$bytes = New-Object byte[] ($stride * $h)
[System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)

$bgB = $bytes[0]; $bgG = $bytes[1]; $bgR = $bytes[2]
$low = 30.0; $high = 95.0   # feather: <low fully transparent, >high fully opaque
for ($i = 0; $i -lt $bytes.Length; $i += 4) {
    $d = [Math]::Abs($bytes[$i + 2] - $bgR) + [Math]::Abs($bytes[$i + 1] - $bgG) + [Math]::Abs($bytes[$i] - $bgB)
    if ($d -le $low) {
        $a = 0
    } elseif ($d -ge $high) {
        $a = 255
    } else {
        $a = [int](255.0 * ($d - $low) / ($high - $low))
    }
    $bytes[$i + 3] = [byte]$a
}
[System.Runtime.InteropServices.Marshal]::Copy($bytes, 0, $data.Scan0, $bytes.Length)
$bmp.UnlockBits($data)

$master = 'D:\engineers\web-projects\newmusic product\limusic\brand\logo_mark_transparent.png'
$bmp.Save($master, [System.Drawing.Imaging.ImageFormat]::Png)

# --- Emit web-sized copies (transparent, 256px) for the site + favicon. ---
function Resize-Png([System.Drawing.Bitmap]$b, [int]$size, [string]$path) {
    $d = New-Object System.Drawing.Bitmap $size, $size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $gr = [System.Drawing.Graphics]::FromImage($d)
    $gr.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $gr.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $gr.DrawImage($b, 0, 0, $size, $size)
    $gr.Dispose()
    $d.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $d.Dispose()
}
Resize-Png $bmp 256 'D:\engineers\web-projects\newmusic product\limusic\website\src\assets\logo.png'
Resize-Png $bmp 256 'D:\engineers\web-projects\newmusic product\limusic\website\public\favicon.png'
$bmp.Dispose()
Write-Host "wrote transparent master + website logo.png + favicon.png"
