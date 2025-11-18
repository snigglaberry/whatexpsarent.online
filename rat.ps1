Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Click G to stop"
$form.Width = 300
$form.Height = 150
$form.FormBorderStyle = 'FixedDialog'
$form.TopMost = $true
$form.StartPosition = 'Manual'

$label = New-Object System.Windows.Forms.Label
$label.Text = "DVD"
$label.Font = New-Object System.Drawing.Font("Arial", 24, [System.Drawing.FontStyle]::Bold)
$label.AutoSize = $true
$label.Left = ($form.ClientSize.Width - $label.Width)/2
$label.Top = ($form.ClientSize.Height - $label.Height)/2
$form.Controls.Add($label)

$form.Show()
$form.Refresh()
Start-Sleep -Milliseconds 200

$mouseAPI = @"
using System;
using System.Runtime.InteropServices;

public class MouseMove {
    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int X, int Y);

    [DllImport("user32.dll")]
    public static extern void mouse_event(int flags, int dx, int dy, int data, int extra);

    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);

    public const int LEFTDOWN = 0x0002;
    public const int LEFTUP   = 0x0004;
}
"@
Add-Type $mouseAPI

$x = $form.Left + ($form.Width / 2)
$y = $form.Top + 15
[MouseMove]::SetCursorPos($x, $y)
Start-Sleep -Milliseconds 100
[MouseMove]::mouse_event([MouseMove]::LEFTDOWN,0,0,0,0)

$dx = 5
$dy = 5
$screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
Write-Host "Press G to stop" -ForegroundColor Cyan

while ($true) {

    $key = [MouseMove]::GetAsyncKeyState(0x47)
    if ($key -ne 0) { break }

    $x += $dx
    $y += $dy

    if ($x -le 0 -or $x + $form.Width -ge $screenWidth) { $dx = -$dx }
    if ($y -le 0 -or $y + $form.Height -ge $screenHeight) { $dy = -$dy }

    [MouseMove]::SetCursorPos([int]$x, [int]$y)
    $form.Location = New-Object System.Drawing.Point([int]$x, [int]$y)
    Start-Sleep -Milliseconds 15
}

[MouseMove]::mouse_event([MouseMove]::LEFTUP,0,0,0,0)
