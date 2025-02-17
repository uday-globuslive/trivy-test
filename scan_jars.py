## Run using: python3 scan_jars.py jars
import os
import subprocess

JARS_DIR = "jars"
REPORTS_DIR = "reports"  # Single reports folder at root level
TRIVY_PATH = "/tmp/trivy1/trivy"
TEMPLATE_PATH = "@/tmp/trivy1/contrib/html.tpl"

# Ensure the main reports directory exists
os.makedirs(REPORTS_DIR, exist_ok=True)

def run_trivy_scan(jar_path, jar_name):
    """Runs Trivy scan in multiple formats for a JAR file and saves reports in a single folder."""
    formats = {
        "html": f"{jar_name}.html",
        "json": f"{jar_name}.json",
        "cyclonedx": f"{jar_name}_cyclonedx.json",
        "spdx": f"{jar_name}_spdx.txt"
    }

    commands = {
        "html": [TRIVY_PATH, "rootfs", jar_path, "--format", "template", "-t", TEMPLATE_PATH, "--output", os.path.join(REPORTS_DIR, formats["html"])],
        "json": [TRIVY_PATH, "rootfs", jar_path, "--format", "json", "--output", os.path.join(REPORTS_DIR, formats["json"])],
        "cyclonedx": [TRIVY_PATH, "rootfs", jar_path, "--format", "cyclonedx", "--output", os.path.join(REPORTS_DIR, formats["cyclonedx"])],
        "spdx": [TRIVY_PATH, "rootfs", jar_path, "--format", "spdx", "--output", os.path.join(REPORTS_DIR, formats["spdx"])]
    }

    for fmt, cmd in commands.items():
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ {fmt.upper()} report generated: {formats[fmt]}")
        else:
            print(f"❌ Failed to generate {fmt.upper()} report for {jar_name}: {result.stderr}")

def process_jars():
    """Scans each JAR file found in any subfolder under 'jars/' and stores reports in a single 'reports/' folder."""
    for root, _, files in os.walk(JARS_DIR):
        for file in files:
            if file.endswith(".jar"):
                jar_path = os.path.join(root, file)
                jar_name, remaining_name = file.rsplit(".", 1)
                full_report_name = f"{jar_name}_{remaining_name}"

                print(f"\n🔍 Scanning {file} in {root}...")
                run_trivy_scan(jar_path, full_report_name)

if __name__ == "__main__":
    process_jars()
