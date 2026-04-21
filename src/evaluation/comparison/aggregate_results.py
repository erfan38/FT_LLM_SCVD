import json
from pathlib import Path

OUTPUT_DIR = Path("slither_results")

def aggregate_results():
    results = []
    files = list(OUTPUT_DIR.glob("*.json"))
    print(f"Found {len(files)} result files.")
    
    for f in files:
        try:
            with open(f, "r") as fp:
                data = json.load(fp)
                results.append(data)
        except Exception as e:
            print(f"Error reading {f}: {e}")
            
    # Calculate stats
    total = len(results)
    success = sum(1 for r in results if r.get("success"))
    failed = total - success
    
    print(f"Total: {total}")
    print(f"Success: {success}")
    print(f"Failed: {failed}")
    
    # Extract vulnerabilities count
    vulns = 0
    for r in results:
        if r.get("success") and "results" in r and "detectors" in r["results"]:
            vulns += len(r["results"]["detectors"])
            
    print(f"Total Vulnerabilities: {vulns}")

if __name__ == "__main__":
    aggregate_results()
