Add-Type -AssemblyName System.Drawing

$W = 2000; $H = 1500
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.Clear([System.Drawing.Color]::FromArgb(245, 246, 248))

function Brush([int]$r, [int]$gg, [int]$b) { New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($r, $gg, $b)) }
function Pen([System.Drawing.Color]$c, [int]$w) { New-Object System.Drawing.Pen($c, $w) }

# title
$titleFont = New-Object System.Drawing.Font("Microsoft YaHei", 34, [System.Drawing.FontStyle]::Bold)
$subFont = New-Object System.Drawing.Font("Microsoft YaHei", 20)
$g.DrawString("STM32F103C8T6 流水灯 + 按键 实物接线图", $titleFont, [System.Drawing.Brushes]::Black, 60, 40)
$g.DrawString("（LED 长脚接电阻、短脚接 GND；按键一端接 PA4、另一端接 GND；板子引脚以丝印为准）", $subFont, (Brush 90 90 90), 60, 110)

# ---------- breadboard base ----------
$bb = New-Object System.Drawing.Rectangle(60, 200, 1880, 1240)
$g.FillRectangle((Brush 235 236 238), $bb)
$g.DrawRectangle((Pen ([System.Drawing.Color]::FromArgb(200,200,200)) 3), $bb)
# holes
$holeBrush = Brush 205 206 210
for ($r = 0; $r -lt 24; $r++) {
    for ($c = 0; $c -lt 44; $c++) {
        $x = 100 + $c * 42; $y = 250 + $r * 48
        $g.FillEllipse($holeBrush, $x, $y, 9, 9)
    }
}
# center channel
$g.FillRectangle((Brush 225 226 228), 80, 760, 1840, 28)

# ---------- board ----------
$boardRect = New-Object System.Drawing.Rectangle(140, 300, 480, 780)
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$rr = 24
$path.AddArc($boardRect.X, $boardRect.Y, $rr, $rr, 180, 90)
$path.AddArc($boardRect.Right - $rr, $boardRect.Y, $rr, $rr, 270, 90)
$path.AddArc($boardRect.Right - $rr, $boardRect.Bottom - $rr, $rr, $rr, 0, 90)
$path.AddArc($boardRect.X, $boardRect.Bottom - $rr, $rr, $rr, 90, 90)
$path.CloseFigure()
$g.FillPath((Brush 31 78 121), $path)
$g.DrawPath((Pen ([System.Drawing.Color]::FromArgb(12,40,70)) 4), $path)

# usb at bottom
$g.FillRectangle((Brush 190 190 195), 300, 1080, 160, 70)
$g.DrawRectangle((Pen ([System.Drawing.Color]::FromArgb(120,120,120)) 3), 300, 1080, 160, 70)
$g.FillRectangle((Brush 120 120 125), 330, 1100, 100, 26)
$g.DrawString("USB", (New-Object System.Drawing.Font("Microsoft YaHei", 16, [System.Drawing.FontStyle]::Bold)), (Brush 60 60 60), 322, 1116)

# boot jumpers at top
$g.FillRectangle((Brush 40 40 40), 300, 250, 60, 50); $g.FillRectangle((Brush 40 40 40), 400, 250, 60, 50)
$g.FillRectangle((Brush 200 40 40), 310, 262, 40, 26); $g.FillRectangle((Brush 200 40 40), 410, 262, 40, 26)
$g.DrawString("BOOT", (New-Object System.Drawing.Font("Microsoft YaHei", 14)), (Brush 80 80 80), 330, 310)

# reset button
$g.FillRectangle((Brush 210 210 210), 480, 320, 60, 60)
$g.FillEllipse((Brush 160 160 160), 490, 330, 40, 40)

# chip
$g.FillRectangle((Brush 25 25 25), 260, 560, 240, 240)
$g.DrawRectangle((Pen ([System.Drawing.Color]::FromArgb(80,80,80)) 2), 260, 560, 240, 240)
# chip pins
for ($i = 0; $i -lt 12; $i++) {
    $yy = 580 + $i * 18
    $g.FillRectangle((Brush 190 190 195), 250, $yy, 12, 8)
    $g.FillRectangle((Brush 190 190 195), 498, $yy, 12, 8)
}
$g.DrawString("STM32F103C8T6", (New-Object System.Drawing.Font("Consolas", 13)), (Brush 220 220 220), 272, 650)

# crystal
$g.FillEllipse((Brush 200 200 205), 300, 870, 160, 60)
$g.DrawEllipse((Pen ([System.Drawing.Color]::FromArgb(140,140,140)) 2), 300, 870, 160, 60)

# voltage regulator
$g.FillRectangle((Brush 35 35 35), 300, 950, 60, 45)

# pin pads + labels on right edge
$pins = @(
    @("PA0", 400), @("PA1", 480), @("PA2", 560), @("PA3", 640), @("PA4", 720), @("GND", 800), @("3V3", 880)
)
foreach ($p in $pins) {
    $nm = $p[0]; $yy = [int]$p[1]
    $g.FillRectangle((Brush 212 175 55), 620, $yy - 10, 26, 20)
    $g.DrawRectangle((Pen ([System.Drawing.Color]::FromArgb(150,120,30)) 2), 620, $yy - 10, 26, 20)
    $g.DrawString($nm, (New-Object System.Drawing.Font("Consolas", 20, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::White, 470, $yy - 16)
}

# ---------- resistors / LEDs ----------
$rowColors = @(
    [System.Drawing.Color]::FromArgb(220,50,47),
    [System.Drawing.Color]::FromArgb(0,140,70),
    [System.Drawing.Color]::FromArgb(230,140,0),
    [System.Drawing.Color]::FromArgb(140,60,190)
)
$ledColors = @(
    [System.Drawing.Color]::FromArgb(230,40,40),
    [System.Drawing.Color]::FromArgb(40,200,90),
    [System.Drawing.Color]::FromArgb(250,200,0),
    [System.Drawing.Color]::FromArgb(60,120,240)
)
$rowY = @(400, 480, 560, 640)

for ($i = 0; $i -lt 4; $i++) {
    $y = [int]$rowY[$i]
    $wire = New-Object System.Drawing.Pen($rowColors[$i], 9)
    $wire.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $wire.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    # wire board -> resistor (gentle curve)
    $g.DrawBezier($wire, 646, $y, 760, $y - 22, 860, $y + 22, 950, $y)
    # resistor body
    $g.FillRectangle((Brush 222 205 170), 950, $y - 22, 170, 44)
    $g.DrawRectangle((Pen ([System.Drawing.Color]::FromArgb(120,100,60)) 3), 950, $y - 22, 170, 44)
    # color bands 330 ohm: orange orange brown gold
    $bandColors = @([System.Drawing.Color]::Orange, [System.Drawing.Color]::Orange, [System.Drawing.Color]::SaddleBrown, [System.Drawing.Color]::Goldenrod)
    for ($b = 0; $b -lt 4; $b++) {
        $bx = 975 + $b * 34
        $g.FillRectangle((New-Object System.Drawing.SolidBrush($bandColors[$b])), $bx, $y - 22, 16, 44)
    }
    $g.DrawString("330Ω", (New-Object System.Drawing.Font("Microsoft YaHei", 16, [System.Drawing.FontStyle]::Bold)), (Brush 70 60 40), 990, $y + 28)
    # wire resistor -> led
    $g.DrawBezier($wire, 1120, $y, 1160, $y, 1170, $y, 1200, $y)
    # LED body (bulb) with legs
    $ledX = 1260; $ledY = $y - 60
    $c = $ledColors[$i]
    $g.FillEllipse((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, $c.R, $c.G, $c.B))), $ledX, $ledY, 120, 120)
    $g.DrawEllipse((Pen ([System.Drawing.Color]::FromArgb(120, $c.R, $c.G, $c.B)) 4), $ledX, $ledY, 120, 120)
    # highlight
    $g.FillEllipse((Brush 255 255 255), $ledX + 22, $ledY + 18, 34, 26)
    # legs
    $g.DrawLine((Pen ([System.Drawing.Color]::FromArgb(180,180,180)) 7), $ledX + 30, $ledY + 118, $ledX + 30, $ledY + 170)
    $g.DrawLine((Pen ([System.Drawing.Color]::FromArgb(180,180,180)) 7), $ledX + 88, $ledY + 118, $ledX + 88, $ledY + 170)
    # connect left leg to resistor wire
    $g.DrawLine($wire, 1200, $y, $ledX + 30, $ledY + 170)
    # right leg to GND bus
    $g.DrawLine($wire, $ledX + 88, $ledY + 170, 1600, $ledY + 170)
    $g.DrawString(("LED" + ($i + 1)), (New-Object System.Drawing.Font("Microsoft YaHei", 18, [System.Drawing.FontStyle]::Bold)), (Brush 80 80 80), $ledX + 30, $ledY - 42)
}

# GND bus
$gndPen = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 10)
$gndPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$gndPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($gndPen, 1600, 340, 1600, 1060)
$g.DrawString("GND", (New-Object System.Drawing.Font("Consolas", 24, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::Black, 1620, 700)
# board GND to bus
$g.DrawBezier($gndPen, 646, 800, 800, 900, 1200, 980, 1600, 980)
# 3v3 not connected note
$g.DrawString("3.3V 不用接", (New-Object System.Drawing.Font("Microsoft YaHei", 16)), (Brush 120 120 120), 430, 900)

# ---------- button ----------
$btnX = 900; $btnY = 900
$g.FillRectangle((Brush 40 40 40), $btnX, $btnY, 150, 150)
$g.FillEllipse((Brush 190 190 190), $btnX + 40, $btnY + 40, 70, 70)
$g.DrawString("按键", (New-Object System.Drawing.Font("Microsoft YaHei", 18, [System.Drawing.FontStyle]::Bold)), (Brush 60 60 60), $btnX + 30, $btnY + 160)
# button wires: PA4 -> button, button -> GND bus
$btnWire = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 9)
$g.DrawBezier($btnWire, 646, 720, 760, 780, 840, 900, 900, 940)
$g.DrawBezier($btnWire, 1050, 1000, 1200, 1040, 1400, 1020, 1600, 1010)

# ---------- legend ----------
$legendFont = New-Object System.Drawing.Font("Microsoft YaHei", 19)
$g.DrawString("接线检查：`n① PA0/PA1/PA2/PA3 各接一个 330Ω 电阻，电阻另一端接 LED 长脚；`n② LED 短脚全部接 GND；`n③ 按键两端分别接 PA4 和 GND；`n④ 板子的 GND 必须和上面这条黑色 GND 线连在一起。", $legendFont, [System.Drawing.Brushes]::Black, 60, 1360)

$bmp.Save("D:\anger\Documents\stm32\LED_Running\实物接线图.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Save("D:\anger\Documents\stm32\LED_Running\wiring_physical.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Output "saved"
