#!/bin/bash

# Check if the JSON file has a valid 'Vulnerabilities' array
if jq -e '.Vulnerabilities' trivy_report.json >/dev/null 2>&1; then
    VULNERABILITY_SUMMARY=$(jq -r '
        if .Vulnerabilities == null then
            "Critical: 0\nHigh: 0\nMedium: 0\nLow: 0\nUnknown: 0"
        else
            [
                "Critical: " + ( [ .Vulnerabilities[] | select(.Severity == "CRITICAL") ] | length | tostring ),
                "High: " + ( [ .Vulnerabilities[] | select(.Severity == "HIGH") ] | length | tostring ),
                "Medium: " + ( [ .Vulnerabilities[] | select(.Severity == "MEDIUM") ] | length | tostring ),
                "Low: " + ( [ .Vulnerabilities[] | select(.Severity == "LOW") ] | length | tostring ),
                "Unknown: " + ( [ .Vulnerabilities[] | select(.Severity == "UNKNOWN") ] | length | tostring )
            ] | join("\n")
        end
    ' trivy_report.json)
else
    echo "Error: trivy_report.json is not valid or does not contain 'Vulnerabilities'."
    exit 1
fi

TOTAL_VULNERABILITIES=$(echo "$VULNERABILITY_SUMMARY" | awk '{s+=$2} END {print s}')
CRITICAL_COUNT=$(echo "$VULNERABILITY_SUMMARY" | grep "Critical:" | awk '{print $2}')
HIGH_COUNT=$(echo "$VULNERABILITY_SUMMARY" | grep "High:" | awk '{print $2}')

IMAGE_NAME="my-app:latest"
SCAN_TIME=$(date)

# Generate the final plain text report
cat <<EOF > final_trivy_report.txt
Trivy Vulnerability Scan Report

Total Vulnerabilities Found: $TOTAL_VULNERABILITIES

$VULNERABILITY_SUMMARY

Scanned Image: $IMAGE_NAME
Scan Time: $SCAN_TIME
EOF
