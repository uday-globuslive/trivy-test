SUBJECT="Trivy Scan Report"
BODY_TEMPLATE="final_trivy_report.html"
SENDER="you@example.com"
RECIPIENTS="user1@example.com user2@example.com"

mailx -a "Content-Type: text/html" -s "$SUBJECT" -r "$SENDER" $RECIPIENTS < "$BODY_TEMPLATE"
