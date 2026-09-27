$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$in = 'D:\engineers\web-projects\newmusic product\limusic\brand\logo_mark_transparent.png'
$src = [System.Drawing.Bitmap]::FromFile($in)

# Downscale to a compact 128px so the base64 payload stays small.
$size = 128
$d = New-Object System.Drawing.Bitmap $size, $size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gr = [System.Drawing.Graphics]::FromImage($d)
$gr.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gr.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$gr.DrawImage($src, 0, 0, $size, $size)
$gr.Dispose(); $src.Dispose()

$ms = New-Object System.IO.MemoryStream
$d.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
$d.Dispose()
$b64 = [System.Convert]::ToBase64String($ms.ToArray())
$ms.Dispose()

$svg = "<svg xmlns=`"http://www.w3.org/2000/svg`" xmlns:xlink=`"http://www.w3.org/1999/xlink`" width=`"200`" height=`"200`" viewBox=`"0 0 200 200`"><image width=`"200`" height=`"200`" xlink:href=`"data:image/png;base64,$b64`"/></svg>"
$out = 'D:\engineers\web-projects\newmusic product\limusic\ui\src\lib\assets\favicon.svg'
[System.IO.File]::WriteAllText($out, $svg, (New-Object System.Text.UTF8Encoding $false))
Write-Host "wrote favicon.svg ($($svg.Length) bytes)"
