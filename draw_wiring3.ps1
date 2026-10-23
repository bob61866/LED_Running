Add-Type -AssemblyName System.Drawing

$W = 2000; $H = 1500
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.Clear([System.Drawing.Color]::FromArgb(250, 250, 251))

function B([int]$r, [int]$gg, [int]$b) { New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($r, $gg, $b)) }
function P([System.Drawing.Color]$c, [int]$w) { New-Object System.Drawing.Pen($c, $w) }

$titleFont = New-Object System.Drawing.Font("Microsoft YaHei", 34, [System.Drawing.FontStyle]::Bold)
$subFont = New-Object System.Drawing.Font("Microsoft YaHei", 19)
$g.DrawString("STM32F103C8T6 流水灯 + 按键 实物接线图", $titleFont, [System.Drawing.Brushes]::Black, 60, 30)
$g.DrawString("元件插在面包板上；LED 长脚接电阻、短脚接 GND；按键一端接 PA4、另一端接 GND；板子引脚以丝印为准", $subFont, (B 90 90 90), 60, 100)

$panel = New-Object System.Drawing.Rectangle(50, 165, 1900, 1160)
$g.FillRectangle((B 247 248 250), $panel)
$g.DrawRectangle((P ([System.Drawing.Color]::FromArgb(215,215,220)) 3), $panel)

# ---------------- board ----------------
$boardRect = New-Object System.Drawing.Rectangle(140, 300, 500, 800)
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$rr = 22
$path.AddArc($boardRect.X, $boardRect.Y, $rr, $rr, 180, 90)
$path.AddArc($boardRect.Right - $rr, $boardRect.Y, $rr, $rr, 270, 90)
$path.AddArc($boardRect.Right - $rr, $boardRect.Bottom - $rr, $rr, $rr, 0, 90)
$path.AddArc($boardRect.X, $boardRect.Bottom - $rr, $rr, $rr, 90, 90)
$path.CloseFigure()
$g.FillPath((B 31 78 121), $path)
$g.DrawPath((P ([System.Drawing.Color]::FromArgb(12,40,70)) 4), $path)

$g.FillRectangle((B 190 190 195), 300, 1100, 180, 64)
$g.DrawRectangle((P ([System.Drawing.Color]::FromArgb(110,110,110)) 3), 300, 1100, 180, 64)
$g.FillRectangle((B 120 120 125), 335, 1122, 110, 22)
$g.DrawString("USB", (New-Object System.Drawing.Font("Microsoft YaHei", 15, [System.Drawing.FontStyle]::Bold)), (B 60 60 60), 318, 1132)

$g.FillRectangle((B 35 35 35), 300, 250, 64, 50); $g.FillRectangle((B 35 35 35), 420, 250, 64, 50)
$g.FillRectangle((B 200 40 40), 310, 262, 44, 26); $g.FillRectangle((B 200 40 40), 430, 262, 44, 26)
$g.DrawString("BOOT", (New-Object System.Drawing.Font("Microsoft YaHei", 13)), (B 80 80 80), 330, 305)

$g.FillRectangle((B 205 205 205), 500, 320, 58, 58)
$g.FillEllipse((B 150 150 150), 509, 329, 40, 40)

$g.FillRectangle((B 25 25 25), 230, 520, 180, 180)
for ($i = 0; $i -lt 12; $i++) {
    $yy = 538 + $i * 13
    $g.FillRectangle((B 185 185 190), 220, $yy, 12, 7)
    $g.FillRectangle((B 185 185 190), 408, $yy, 12, 7)
}
$g.DrawString("STM32F103C8T6", (New-Object System.Drawing.Font("Consolas", 11)), (B 215 215 215), 236, 600)

$g.FillEllipse((B 200 200 205), 250, 790, 150, 52)
$g.DrawEllipse((P ([System.Drawing.Color]::FromArgb(140,140,140)) 2), 250, 790, 150, 52)
$g.FillRectangle((B 35 35 35), 250, 880, 58, 42)

$pins = @(
    @("PA0", 380), @("PA1", 500), @("PA2", 620), @("PA3", 740), @("PA4", 860), @("GND", 940), @("3V3", 1020)
)
foreach ($p in $pins) {
    $nm = $p[0]; $yy = [int]$p[1]
    $g.FillRectangle((B 214 178 60), 640, $yy - 10, 28, 20)
    $g.DrawRectangle((P ([System.Drawing.Color]::FromArgb(150,120,30)) 2), 640, $yy - 10, 28, 20)
    $fmt = New-Object System.Drawing.StringFormat
    $fmt.Alignment = [System.Drawing.StringAlignment]::Far
    $rect = New-Object System.Drawing.RectangleF(400, ($yy - 17), 225, 34)
    $g.DrawString($nm, (New-Object System.Drawing.Font("Consolas", 19, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::White, $rect, $fmt)
}
$g.DrawString("3.3V 不用接", (New-Object System.Drawing.Font("Microsoft YaHei", 15)), (B 190 190 190), 430, 1035)

$rowColors = @(
    [System.Drawing.Color]::FromArgb(220,50,47),
    [System.Drawing.Color]::FromArgb(0,140,70),
    [System.Drawing.Color]::FromArgb(230,140,0),
    [System.Drawing.Color]::FromArgb(140,60,190)
)
$ledColors = @(
    [System.Drawing.Color]::FromArgb(235,45,45),
    [System.Drawing.Color]::FromArgb(45,200,90),
    [System.Drawing.Color]::FromArgb(250,205,10),
    [System.Drawing.Color]::FromArgb(60,120,240)
)
$rowY = @(380, 500, 620, 740)

for ($i = 0; $i -lt 4; $i++) {
    $y = [int]$rowY[$i]
    $wire = New-Object System.Drawing.Pen($rowColors[$i], 9)
    $wire.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $wire.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

    $g.DrawBezier($wire, 668, $y, 760, $y - 18, 840, $y + 18, 900, $y)
    $g.DrawLine((P ([System.Drawing.Color]::FromArgb(170,170,175)) 6), 900, $y, 940, $y)
    $g.FillRectangle((B 226 210 175), 940, $y - 21, 160, 42)
    $g.DrawRectangle((P ([System.Drawing.Color]::FromArgb(120,100,60)) 3), 940, $y - 21, 160, 42)
    $bandColors = @([System.Drawing.Color]::Orange, [System.Drawing.Color]::Orange, [System.Drawing.Color]::SaddleBrown, [System.Drawing.Color]::Goldenrod)
    for ($b = 0; $b -lt 4; $b++) {
        $bx = 962 + $b * 32
        $g.FillRectangle((New-Object System.Drawing.SolidBrush($bandColors[$b])), $bx, $y - 21, 15, 42)
    }
    $g.DrawLine((P ([System.Drawing.Color]::FromArgb(170,170,175)) 6), 1100, $y, 1140, $y)
    $g.DrawString("330Ω", (New-Object System.Drawing.Font("Microsoft YaHei", 15, [System.Drawing.FontStyle]::Bold)), (B 70 60 40), 985, $y + 27)

    $g.DrawLine($wire, 1140, $y, 1190, $y)
    $g.DrawLine((P ([System.Drawing.Color]::FromArgb(175,175,180)) 7), 1190, $y, 1225, $y)
    $g.DrawLine((P ([System.Drawing.Color]::FromArgb(175,175,180)) 7), 1335, $y, 1370, $y)
    $c = $ledColors[$i]
    $g.FillEllipse((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, $c.R, $c.G, $c.B))), 1215, $y - 55, 120, 110)
    $g.DrawEllipse((P ([System.Drawing.Color]::FromArgb(120, $c.R, $c.G, $c.B)) 4), 1215, $y - 55, 120, 110)
    $g.FillEllipse((B 255 255 255), 1240, $y - 38, 32, 24)
    $g.DrawString(("LED" + ($i + 1)), (New-Object System.Drawing.Font("Microsoft YaHei", 17, [System.Drawing.FontStyle]::Bold)), (B 80 80 80), 1085, $y - 82)
    $g.DrawLine($wire, 1370, $y, 1600, $y)
}

$gndPen = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 11)
$gndPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$gndPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($gndPen, 1600, 330, 1600, 1180)
$g.DrawString("GND", (New-Object System.Drawing.Font("Consolas", 24, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::Black, 1625, 700)

$g.DrawBezier($gndPen, 668, 940, 690, 1180, 1200, 1180, 1600, 1180)

$btnX = 900; $btnY = 960
$g.FillRectangle((B 45 45 45), $btnX, $btnY, 150, 130)
$g.FillEllipse((B 200 200 200), $btnX + 45, $btnY + 35, 60, 60)
$g.DrawLine((P ([System.Drawing.Color]::FromArgb(175,175,180)) 7), $btnX, $btnY + 30, $btnX - 30, $btnY + 30)
$g.DrawLine((P ([System.Drawing.Color]::FromArgb(175,175,180)) 7), $btnX + 150, $btnY + 100, $btnX + 180, $btnY + 100)
$g.DrawBezier($gndPen, 668, 860, 760, 900, 850, 1000, 870, 1000)
$g.DrawBezier($gndPen, 1080, 1060, 1250, 1110, 1450, 1120, 1600, 1120)
$g.DrawString("按键", (New-Object System.Drawing.Font("Microsoft YaHei", 18, [System.Drawing.FontStyle]::Bold)), (B 60 60 60), $btnX + 45, $btnY + 140)
$g.DrawString("（四脚按键，同侧两脚相通）", (New-Object System.Drawing.Font("Microsoft YaHei", 14)), (B 120 120 120), $btnX - 70, $btnY + 175)

$noteFont = New-Object System.Drawing.Font("Microsoft YaHei", 19)
$g.DrawString("接线检查：`n① PA0 / PA1 / PA2 / PA3 各接一个 330Ω 电阻，电阻另一端接 LED 长脚（左）；`n② LED 短脚（右）全部接到黑色的 GND 线；`n③ 按键两端分别接 PA4 和 GND；`n④ 板子的 GND 也要接到这条黑色 GND 线（共地）。", $noteFont, [System.Drawing.Brushes]::Black, 60, 1340)

$bmp.Save("D:\anger\Documents\stm32\LED_Running\实物接线图.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Save("D:\anger\Documents\stm32\LED_Running\wiring_physical.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Output "saved"
