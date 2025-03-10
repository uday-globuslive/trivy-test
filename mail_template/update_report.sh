#!/bin/bash

# Extract and count vulnerabilities properly
VULNERABILITY_SUMMARY=$(jq -r '
    if .Results then
        [
            "Critical: " + ( [ .Results[].Vulnerabilities[]? | select(.Severity == "CRITICAL") ] | length | tostring ),
            "High: " + ( [ .Results[].Vulnerabilities[]? | select(.Severity == "HIGH") ] | length | tostring ),
            "Medium: " + ( [ .Results[].Vulnerabilities[]? | select(.Severity == "MEDIUM") ] | length | tostring ),
            "Low: " + ( [ .Results[].Vulnerabilities[]? | select(.Severity == "LOW") ] | length | tostring ),
            "Unknown: " + ( [ .Results[].Vulnerabilities[]? | select(.Severity == "UNKNOWN") ] | length | tostring )
        ] | join("\n")
    else
        "Critical: 0\nHigh: 0\nMedium: 0\nLow: 0\nUnknown: 0"
    end
' trivy_report.json)

# Get total count
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
