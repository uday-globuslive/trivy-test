@echo off
set https_proxy=proxy.mccamish.com:443
REM Check if the project folder is provided
if "%1"=="" (
    echo [ERROR] Please provide the project folder to scan.
    exit /b 1
)

set PROJECT_FOLDER=%1
set REPORT_FILE=trivy-report.json

REM Run Trivy to scan the folder and generate a JSON report
c:\temp\trivy.exe fs %PROJECT_FOLDER% --format json --output %REPORT_FILE%
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Trivy scan failed.
    exit /b 1
)

REM Parse the JSON report to count vulnerabilities using PowerShell
for /f "delims=" %%A in ('powershell -NoProfile -Command ^
    "Get-Content %REPORT_FILE% | ConvertFrom-Json | %{$_.Results.Vulnerabilities.Count -ne $null -and $_.Results.Vulnerabilities} | Measure-Object -Sum | ForEach-Object {$_.Sum}"') do set VULNERABILITY_COUNT=%%A

REM Handle cases where vulnerabilities are not found
if "%VULNERABILITY_COUNT%"=="" set VULNERABILITY_COUNT=0

echo [INFO] Total vulnerabilities found: %VULNERABILITY_COUNT%

REM Decide success or failure based on the vulnerability count
if %VULNERABILITY_COUNT% gtr 0 (
    echo [ERROR] Vulnerabilities detected. Failing the process.
    exit /b 1
) else (
    echo [INFO] No vulnerabilities detected. Process successful.
    exit /b 0
)
