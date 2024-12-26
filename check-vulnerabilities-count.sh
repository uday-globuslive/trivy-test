  if jq '.Results[] | select(.Vulnerabilities != null) | .Vulnerabilities[] | select(.Severity == "HIGH" or .Severity == "CRITICAL")' trivy-results.json | grep .; then
          echo "High or critical vulnerabilities found"
          exit 1
        else
          echo "No high or critical vulnerabilities found"
        fi
