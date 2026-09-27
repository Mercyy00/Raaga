# Regenerates website/public/og.png in the Raaga "Ivory Editorial" brand.
# GDI+ only (no imagemagick/sharp on this box). Outputs 1280x640 PNG.
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'

$root   = 'D:\engineers\web-projects\newmusic product\limusic'
$logoP  = Join-Path $root 'website\src\assets\logo.png'
$shotP  = Join-Path $root 'website\src\assets\screen-playlist.png'
$outP   = Join-Path $root 'website\public\og.png'

$W = 1280; $H = 640

# Ivory-editorial palette (approximated from the site's oklch tokens)
$ivory   = [System.Drawing.Color]::FromArgb(244, 238, 225)
$ivory2  = [System.Drawing.Color]::FromArgb(236, 228, 212)
$ink     = [System.Drawing.Color]::FromArgb(51, 40, 30)
$muted   = [System.Drawing.Color]::FromArgb(112, 96, 78)
$gold    = [System.Drawing.Color]::FromArgb(184, 137, 62)
$crimson = [System.Drawing.Color]::FromArgb(190, 30, 48)
$paper   = [System.Drawing.Color]::FromArgb(252, 250, 245)

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Background: flat ivory + a soft warm gold glow in the top-right corner.
$g.Clear($ivory)
$glow = New-Object System.Drawing.Drawing2D.GraphicsPath
$glow.AddEllipse(760, -280, 900, 760)
$pgb = New-Object System.Drawing.Drawing2D.PathGradientBrush($glow)
$pgb.CenterColor = [System.Drawing.Color]::FromArgb(70, $gold)
$pgb.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $gold))
$g.FillPath($pgb, $glow)
$pgb.Dispose(); $glow.Dispose()

function New-RoundedRect([int]$x,[int]$y,[int]$w,[int]$h,[int]$r){
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $p.AddArc($x, $y, $d, $d, 180, 90)
  $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $p.CloseFigure()
  return $p
}

# ── Right: the playlist screenshot, framed, bleeding off the right edge ──
$shot = [System.Drawing.Image]::FromFile($shotP)
$fw = 720
$fh = [int]($fw * $shot.Height / $shot.Width)   # 720 * 867/1600 ≈ 390
$fx = 636
$fy = [int](($H - $fh) / 2)

# Soft espresso shadow beneath the frame.
for ($i = 6; $i -ge 1; $i--) {
  $a = [int](14 - $i)
  if ($a -lt 1) { $a = 1 }
  $sp = New-RoundedRect ($fx - $i) ($fy + $i + 6) ($fw + 2*$i) ($fh + 2*$i) (22 + $i)
  $sb = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($a, $ink))
  $g.FillPath($sb, $sp); $sb.Dispose(); $sp.Dispose()
}

# Outer bezel (paper tray) + inner screenshot with concentric radii.
$outer = New-RoundedRect $fx $fy $fw $fh 24
$ob = New-Object System.Drawing.SolidBrush($paper)
$g.FillPath($ob, $outer); $ob.Dispose()
$pad = 10
$inner = New-RoundedRect ($fx + $pad) ($fy + $pad) ($fw - 2*$pad) ($fh - 2*$pad) 16
$g.SetClip($inner)
$g.DrawImage($shot, $fx + $pad, $fy + $pad, $fw - 2*$pad, $fh - 2*$pad)
$g.ResetClip()
# Gold hairlines on both frames.
$goldPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, $gold), 1.5)
$g.DrawPath($goldPen, $outer)
$g.DrawPath($goldPen, $inner)
$goldPen.Dispose(); $outer.Dispose(); $inner.Dispose()
$shot.Dispose()

# ── Brand lockup, top-left: ink disc with the logo + "Raaga" wordmark ──
$discX = 80; $discY = 62; $discD = 54
$discBrush = New-Object System.Drawing.SolidBrush($ink)
$g.FillEllipse($discBrush, $discX, $discY, $discD, $discD); $discBrush.Dispose()
$logo = [System.Drawing.Image]::FromFile($logoP)
$ls = 34; $lo = [int](($discD - $ls) / 2)
$g.DrawImage($logo, $discX + $lo, $discY + $lo, $ls, $ls)
$logo.Dispose()

$wordFont = New-Object System.Drawing.Font('Georgia', 25, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$inkBrush = New-Object System.Drawing.SolidBrush($ink)
$g.DrawString('Raaga', $wordFont, $inkBrush, ($discX + $discD + 16), ($discY + 11))
$wordFont.Dispose()

# ── Left copy block ──
$eyebrowFont = New-Object System.Drawing.Font('Segoe UI Semibold', 15, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$goldBrush = New-Object System.Drawing.SolidBrush($gold)
$g.DrawString('AD-FREE  /  OPEN SOURCE', $eyebrowFont, $goldBrush, 80, 250)
$eyebrowFont.Dispose(); $goldBrush.Dispose()

$headFont = New-Object System.Drawing.Font('Georgia', 52, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString('The desktop player', $headFont, $inkBrush, 74, 285)
$g.DrawString('for YouTube Music.', $headFont, $inkBrush, 74, 345)
$headFont.Dispose()

$subFont = New-Object System.Drawing.Font('Segoe UI', 20, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$mutedBrush = New-Object System.Drawing.SolidBrush($muted)
$g.DrawString('Synced lyrics, your own files, Listen Together,', $subFont, $mutedBrush, 80, 428)
$g.DrawString('native on Linux, Windows and macOS.', $subFont, $mutedBrush, 80, 458)

# Footer URL in gold.
$urlFont = New-Object System.Drawing.Font('Segoe UI Semibold', 16, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$goldBrush2 = New-Object System.Drawing.SolidBrush($gold)
$g.DrawString('mercyy00.github.io/Raaga', $urlFont, $goldBrush2, 80, 528)
$urlFont.Dispose(); $goldBrush2.Dispose()
$subFont.Dispose(); $mutedBrush.Dispose(); $inkBrush.Dispose()

# Save as PNG.
if (Test-Path $outP) { Remove-Item $outP -Force }
$bmp.Save($outP, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Output "wrote $outP ($W x $H)"
