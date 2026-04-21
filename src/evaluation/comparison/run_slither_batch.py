import os
import subprocess
import json
import time
from pathlib import Path

# Configuration
SOL_FILES_DIR = Path("sol_files")
OUTPUT_DIR = Path("slither_results")
SLITHER_CMD = "slither"

def run_slither(file_path, output_path):
    """Runs slither on a single file and saves JSON output."""
    try:
        # Construct command: slither <file> --json <output>
        # We use --json - to capture stdout if needed, but better to let slither write to file
        # Actually slither <file> --json <output_file> works well.
        cmd = [SLITHER_CMD, str(file_path), "--json", str(output_path)]
        
        # Run command
        result = subprocess.run(
            cmd, 
            capture_output=True, 
            text=True, 
            check=False # Don't raise on error, we want to capture it
        )
        
        return {
            "file": str(file_path),
            "return_code": result.returncode,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "success": result.returncode == 0 or os.path.exists(output_path)
        }

    except Exception as e:
        return {
            "file": str(file_path),
            "return_code": -1,
            "stdout": "",
            "stderr": str(e),
            "success": False
        }

def main():
    # Create output directory
    OUTPUT_DIR.mkdir(exist_ok=True)
    
    # Get all .sol files
    sol_files = list(SOL_FILES_DIR.glob("*.sol"))
    print(f"Found {len(sol_files)} .sol files.")
    
    results_summary = []
    
    start_time = time.time()
    
    for i, sol_file in enumerate(sol_files):
        output_file = OUTPUT_DIR / f"{sol_file.stem}.json"
        
        print(f"[{i+1}/{len(sol_files)}] Processing {sol_file.name}...")
        
        result = run_slither(sol_file, output_file)
        
        # Minimal summary info
        summary_entry = {
            "file": result["file"],
            "success": result["success"],
            "return_code": result["return_code"]
        }
        
        if not result["success"]:
             # If failed, maybe store stderr snippet
             summary_entry["error"] = result["stderr"][:200] # First 200 chars
        
        results_summary.append(summary_entry)

    end_time = time.time()
    duration = end_time - start_time
    
    # Save summary report
    with open("slither_batch_summary.json", "w") as f:
        json.dump(results_summary, f, indent=2)
        
    print(f"\nFinished processing {len(sol_files)} files in {duration:.2f} seconds.")
    print(f"Results saved to {OUTPUT_DIR}")
    print("Summary saved to slither_batch_summary.json")

if __name__ == "__main__":
    main()
