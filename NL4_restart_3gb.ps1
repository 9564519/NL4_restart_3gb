# Задаем пороговое значение 3246157568 - 3 Гб+ тестируем при 6157568

$threshold = 3246157568 

# Получаем текущее время для создания уникального имени класса
$currentDateTime = Get-Date -Format "yyyyMMdd_HHmmss"
$className = "User32_$currentDateTime"

# Определяем класс User32 единожды
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class User32 {
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    public const int SW_MINIMIZE = 2;
}
"@ 

while ($true) {
    # Проверяем размер рабочего набора
    $processMemory = (Get-WmiObject Win32_Process | Where-Object { $_.Name -eq "NLClientApp.exe" }).WorkingSetSize

    if ($processMemory -gt $threshold) {
        # Если размер рабочего набора больше порога, выполняем код X
        $fullProcessPath = "C:\Program Files\Locktime Software\NetLimiter 4\NLClientApp.exe"
		# $fullProcessPath = "D:\NET_L\Instal\NLClientApp.exe"

        # Завершение предыдущего экземпляра, если он запущен
        $process = Get-WmiObject Win32_Process | Where-Object { $_.CommandLine -like "*$fullProcessPath*" }
        if ($process) {
            Stop-Process -Id $process.ProcessId -Force
            Start-Sleep -Seconds 2
        }

        # Запуск процесса
        $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processStartInfo.FileName = $fullProcessPath
        $proc = [System.Diagnostics.Process]::Start($processStartInfo)

        # Задержка, чтобы дать время на запуск
        Start-Sleep -Seconds 2

        # Попытка найти главное окно и свернуть его, используя статический класс User32
        $hwnd = (Get-Process | Where-Object { $_.Id -eq $proc.Id }).MainWindowHandle
        if ($hwnd -ne [IntPtr]::Zero) {
            # Свернуть окно
            [User32]::ShowWindow($hwnd, [User32]::SW_MINIMIZE)
        }

    } else {
        # Если меньше порога, ждем 50 секунд и повторяем проверку.
        Start-Sleep -Seconds 50
    }
}