param([Parameter(Mandatory=$true)][string]$TitleLike)  # e.g. -TitleLike "*차고 타이쿤*" (pass it from the shell: this file is read as ANSI)
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class W {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);
  [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr h);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, IntPtr p);
  [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
  [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool f);
}
"@
$p = Get-Process RobloxStudioBeta | Where-Object { $_.MainWindowTitle -like $TitleLike } | Select-Object -First 1
if (-not $p) { "no window"; exit 1 }
$h = $p.MainWindowHandle
$fg = [W]::GetForegroundWindow()
$t1 = [W]::GetWindowThreadProcessId($fg, [IntPtr]::Zero)
$t2 = [W]::GetCurrentThreadId()
[W]::AttachThreadInput($t2, $t1, $true) | Out-Null
[W]::ShowWindow($h, 3) | Out-Null
[W]::BringWindowToTop($h) | Out-Null
[W]::SetForegroundWindow($h) | Out-Null
[W]::AttachThreadInput($t2, $t1, $false) | Out-Null
Start-Sleep -Milliseconds 700
if ([W]::GetForegroundWindow() -ne $h) { "not foreground"; exit 2 }
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("^s")
"sent ctrl+s to " + $p.MainWindowTitle
