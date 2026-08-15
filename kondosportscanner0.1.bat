@echo off
title Kondos Port Scanner
color 0A
setlocal enabledelayedexpansion

echo ==============================================
echo        KONDOS PORT SCANNER
echo ==============================================
echo.

:: Get target
set /p target="Enter target IP or hostname: "
if "%target%"=="" (
    echo [ERROR] Target cannot be empty.
    pause
    exit /b
)

:: Get port range
set /p startPort="Enter starting port: "
set /p endPort="Enter ending port: "

:: Validate numeric input
set "numCheck=" & for /f "delims=0123456789" %%a in ("%startPort%") do set "numCheck=%%a"
if defined numCheck (
    echo [ERROR] Starting port must be a number.
    pause
    exit /b
)
set "numCheck=" & for /f "delims=0123456789" %%a in ("%endPort%") do set "numCheck=%%a"
if defined numCheck (
    echo [ERROR] Ending port must be a number.
    pause
    exit /b
)

if %startPort% GTR %endPort% (
    echo [ERROR] Starting port cannot be greater than ending port.
    pause
    exit /b
)

echo.
echo Scanning %target% from port %startPort% to %endPort%...
echo.

:: Run PowerShell scanning command
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$target = '%target%';" ^
  "$startPort = %startPort%;" ^
  "$endPort = %endPort%;" ^
  "$timeout = 1000;" ^
  "for ($port = $startPort; $port -le $endPort; $port++) {" ^
  "    $tcpClient = New-Object System.Net.Sockets.TcpClient;" ^
  "    $asyncResult = $tcpClient.BeginConnect($target, $port, $null, $null);" ^
  "    $wait = $asyncResult.AsyncWaitHandle.WaitOne($timeout, $false);" ^
  "    if ($wait -and $tcpClient.Connected) {" ^
  "        try { $tcpClient.EndConnect($asyncResult); Write-Host \"Port $port : OPEN\" -ForegroundColor Green }" ^
  "        catch { Write-Host \"Port $port : CLOSED\" -ForegroundColor Red }" ^
  "    } else {" ^
  "        Write-Host \"Port $port : CLOSED\" -ForegroundColor Red" ^
  "    }" ^
  "    $tcpClient.Close();" ^
  "}"

echo.
echo Scan complete.
pause