#!/bin/bash

SUBJECT=""
BODY_FILE="final_trivy_report.txt"
SENDER="you@example.com"
RECIPIENTS="user1@example.com user2@example.com"

# Read critical and high counts
CRITICAL_COUNT=$(grep "Critical:" $BODY_FILE | awk '{print $2}')
HIGH_COUNT=$(grep "High:" $BODY_FILE | awk '{print $2}')

# Decide if the email should be sent
if [ "$CRITICAL_COUNT" -gt 0 ]; then
    SUBJECT="Trivy Scan Report - Critical Vulnerabilities Found"
elif [ "$HIGH_COUNT" -gt 0 ]; then
    SUBJECT="Trivy Scan Report - High Vulnerabilities Found"
else
    echo "No Critical or High vulnerabilities found. Skipping email."
    exit 0
fi

# Send email in plain text format
mailx -s "$SUBJECT" -r "$SENDER" $RECIPIENTS < "$BODY_FILE"
