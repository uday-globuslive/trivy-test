#!/bin/bash

# Parse vulnerability counts from the JSON report
VULNERABILITY_SUMMARY=$(jq -r '
    [
        "Critical: " + ( .Vulnerabilities[] | select(.Severity == "CRITICAL") | length | tostring ),
        "High: " + ( .Vulnerabilities[] | select(.Severity == "HIGH") | length | tostring ),
        "Medium: " + ( .Vulnerabilities[] | select(.Severity == "MEDIUM") | length | tostring ),
        "Low: " + ( .Vulnerabilities[] | select(.Severity == "LOW") | length | tostring ),
        "Unknown: " + ( .Vulnerabilities[] | select(.Severity == "UNKNOWN") | length | tostring )
    ] | join("\n")
' trivy_report.json)

TOTAL_VULNERABILITIES=$(jq '[.Vulnerabilities[]] | length' trivy_report.json)
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
