import os
import subprocess
import json
import time
from pathlib import Path
from multiprocessing import Pool, cpu_count

# Configuration
SOL_FILES_DIR = Path("sol_files")
OUTPUT_DIR = Path("slither_results")
SLITHER_CMD = "slither"
TIMEOUT_SECONDS = 30 # Fail fast

def run_slither(file_path):
    """Runs slither on a single file and saves JSON output."""
    output_path = OUTPUT_DIR / f"{file_path.stem}.json"
    
    # Skip if already exists (resume capability)
    if output_path.exists():
        return {
            "file": str(file_path),
            "skipped": True,
            "success": True
        }

    try:
        # Construct command
        cmd = [SLITHER_CMD, str(file_path), "--json", str(output_path)]
        
        # Set SOLC_VERSION to avoid auto-detection overhead
        env = os.environ.copy()
        env["SOLC_VERSION"] = "0.8.23"
        
        result = subprocess.run(
            cmd, 
            capture_output=True, 
            text=True, 
            env=env,
            check=False,
            timeout=TIMEOUT_SECONDS
        )
        
        return {
            "file": str(file_path),
            "return_code": result.returncode,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "success": result.returncode == 0 or output_path.exists(),
            "skipped": False
        }

    except subprocess.TimeoutExpired:
        return {
            "file": str(file_path),
            "return_code": -2,
            "stdout": "",
            "stderr": "Timeout expired",
            "success": False,
            "skipped": False
        }
    except Exception as e:
        return {
            "file": str(file_path),
            "return_code": -1,
            "stdout": "",
            "stderr": str(e),
            "success": False,
            "skipped": False
        }

def main():
    # Create output directory
    OUTPUT_DIR.mkdir(exist_ok=True)
    
    # Get all .sol files
    sol_files = list(SOL_FILES_DIR.glob("*.sol"))
    print(f"Found {len(sol_files)} .sol files.")
    
    # Use all CPUs
    num_processes = cpu_count()
    print(f"Starting parallel execution with {num_processes} processes...")
    
    start_time = time.time()
    
    results_summary = []
    
    # Use chunksize to reduce IPC overhead? Default is 1.
    # With 1600 tasks, chunksize of 10 or 20 might be better.
    
    with Pool(processes=num_processes) as pool:
        # map returns results in order
        for i, result in enumerate(pool.imap_unordered(run_slither, sol_files, chunksize=10)):
            results_summary.append({
                "file": result["file"],
                "success": result["success"],
                "return_code": result.get("return_code"),
                "skipped": result.get("skipped", False)
            })
            
            if (i + 1) % 50 == 0:
                print(f"Processed {i + 1}/{len(sol_files)} files...")

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
