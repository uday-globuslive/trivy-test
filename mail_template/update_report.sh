VULNERABILITY_COUNT=$(cat trivy_report.json | jq '.Vulnerabilities | length')
IMAGE_NAME="my-app:latest"
SCAN_TIME=$(date)

# Determine background color
if [ "$VULNERABILITY_COUNT" -eq 0 ]; then
    BG_COLOR="green"
else
    BG_COLOR="red"
fi

# Generate final HTML report
sed "s/{{VULNERABILITY_COUNT}}/$VULNERABILITY_COUNT/g; \
     s/{{IMAGE_NAME}}/$IMAGE_NAME/g; \
     s/{{SCAN_TIME}}/$SCAN_TIME/g; \
     s/{{BG_COLOR}}/$BG_COLOR/g" trivy_report.html > final_trivy_report.html
