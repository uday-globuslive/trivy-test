$json = Get-Content -Path "trivy-report.json" | ConvertFrom-Json
$htmlContent = "<html><head><title>Trivy Report</title></head><body><h1>Trivy Vulnerability Report</h1>"

foreach ($result in $json.Results) {
    $htmlContent += "<h2>Target: $($result.Target)</h2><table border='1'><tr><th>Vulnerability ID</th><th>Package</th><th>Severity</th></tr>"
    foreach ($vuln in $result.Vulnerabilities) {
        $htmlContent += "<tr><td>$($vuln.VulnerabilityID)</td><td>$($vuln.PkgName)</td><td>$($vuln.Severity)</td></tr>"
    }
    $htmlContent += "</table>"
}

$htmlContent += "</body></html>"
Set-Content -Path "trivy-report.html" -Value $htmlContent
