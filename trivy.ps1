# Set the HTTPS proxy environment variable
$env:https_proxy = "proxy.mccamish.com"

# Check if the project folder is provided as an argument
param(
    [string]$ProjectFolder
)

if (-not $ProjectFolder) {
    Write-Host "[ERROR] Please provide the project folder to scan." -ForegroundColor Red
    exit 1
}

# Define the Trivy executable path and output report file
$TrivyPath = "C:\temp\trivy.exe"
$ReportFile = "trivy-report.json"

# Ensure Trivy exists
if (-not (Test-Path $TrivyPath)) {
    Write-Host "[ERROR] Trivy executable not found at $TrivyPath." -ForegroundColor Red
    exit 1
}

# Run Trivy scan and generate a JSON report
Write-Host "[INFO] Scanning the project folder: $ProjectFolder" -ForegroundColor Yellow
& $TrivyPath fs $ProjectFolder --format json --output $ReportFile
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Trivy scan failed." -ForegroundColor Red
    exit 1
}

# Parse the JSON report to count vulnerabilities
try {
    $ReportContent = Get-Content $ReportFile | ConvertFrom-Json
    $VulnerabilityCount = 0

    foreach ($Result in $ReportContent.Results) {
        if ($Result.Vulnerabilities) {
            $VulnerabilityCount += $Result.Vulnerabilities.Count
        }
    }

    Write-Host "[INFO] Total vulnerabilities found: $VulnerabilityCount" -ForegroundColor Cyan

    # Determine success or failure based on the number of vulnerabilities
    if ($VulnerabilityCount -gt 0) {
        Write-Host "[ERROR] Vulnerabilities detected. Failing the process." -ForegroundColor Red
        exit 1
    } else {
        Write-Host "[INFO] No vulnerabilities detected. Process successful." -ForegroundColor Green
        exit 0
    }
} catch {
    Write-Host "[ERROR] Failed to parse the Trivy report." -ForegroundColor Red
    exit 1
}
