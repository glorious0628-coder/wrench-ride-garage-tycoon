# Waits until the laptop battery is at or below the limit, then exits (main 10-22: user "배터리 20퍼센트되면 정리하고 컴퓨터 꺼줘").
param([int]$Limit = 20, [int]$EverySeconds = 60)
while ($true) {
    $b = Get-CimInstance Win32_Battery | Select-Object -First 1
    $pct = [int]$b.EstimatedChargeRemaining
    if ($pct -le $Limit) {
        Write-Output ("BATTERY {0}% at {1}" -f $pct, (Get-Date -Format "HH:mm:ss"))
        break
    }
    Start-Sleep -Seconds $EverySeconds
}
