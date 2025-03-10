- create a file in repo: .git/hooks/pre-commit

```
#!/bin/bash
export https_proxy=proxy.mccamish.com:443
echo "Running trivy scan before commit"
# Scan the local repository directory
/msc/trivy/trivy fs --exit-code 1 --severity HIGH,CRITICAL .

#Check if Trivy foundvulnerabilities
if [ $? -ne 0 ]; then
 echo "Trivy found vulnerabilities! Fix them before committing."
 exit 1 # Prevent the commit
fi

echo "Trivy scan passed. Proceeding with commit."
```

- when creating a commit, it will run above script and commits only if it is succesful
