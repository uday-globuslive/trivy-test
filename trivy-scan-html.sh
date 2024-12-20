#!/bin/bash

# Set the HTTPS proxy environment variable
export https_proxy="proxy.mccamish.com:443"

# Check if the project folder is provided as an argument
ProjectFolder="$1"

if [ -z "$ProjectFolder" ]; then
    echo "[ERROR] Please provide the project folder to scan."
    exit 1
fi

# Define the Trivy executable path and output report files
TrivyPath="/temp/trivy"
JsonReportFile="trivy-report.json"
HtmlReportFile="trivy-report.html"

# Ensure Trivy exists
if [ ! -f "$TrivyPath" ]; then
    echo "[ERROR] Trivy executable not found at $TrivyPath."
    exit 1
fi

# Run Trivy scan and generate both JSON and HTML reports
echo "[INFO] Scanning the project folder: $ProjectFolder"
"$TrivyPath" fs "$ProjectFolder" --format json --output "$JsonReportFile" --format html --output "$HtmlReportFile"

if [ $? -ne 0 ]; then
    echo "[ERROR] Trivy scan failed."
    exit 1
fi

# Parse the JSON report to count vulnerabilities
VulnerabilityCount=0
if jq -e . > /dev/null 2>&1 <<< "$JsonReportFile"; then
    Result=$(cat "$JsonReportFile")
    # Loop through the report and count vulnerabilities
    for row in $(echo "$Result" | jq -r '.Results[]'); do
        Vulnerabilities=$(echo "$row" | jq -r '.Vulnerabilities')
        if [ "$Vulnerabilities" != "null" ] && [ ${#Vulnerabilities[@]} -gt 0 ]; then
            VulnerabilityCount=$(($VulnerabilityCount + $(echo "$Vulnerabilities" | jq length)))
        fi
    done

    echo "[INFO] Total vulnerabilities found: $VulnerabilityCount"

    # Determine success or failure based on the number of vulnerabilities
    if [ "$VulnerabilityCount" -gt 0 ]; then
        echo "[ERROR] Vulnerabilities detected. Failing the process."
        exit 1
    else
        echo "[INFO] No vulnerabilities detected. Process successful."
        exit 0
    fi
else
    echo "[ERROR] Failed to parse the Trivy report."
    exit 1
fi
