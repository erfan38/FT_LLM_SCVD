import json
import os
import subprocess
import re
from pathlib import Path
from multiprocessing import Pool, cpu_count

# Configuration
JSON_FILE = Path("code_test.json")
OUTPUT_DIR = Path("slither_json_results")
TEMP_DIR = Path("temp_sol_files")
SLITHER_CMD = "slither"
TIMEOUT_SECONDS = 30

def preprocess_code(code):
    """Preprocesses Solidity code to make it compilable."""
    processed_code = code
    
    # 1. Add pragma if missing
    if "pragma solidity" not in processed_code:
        processed_code = "pragma solidity ^0.8.0;\n\n" + processed_code
        
    # 2. Wrap in contract if missing (heuristic)
    if not re.search(r"\b(contract|library|interface)\s+\w+", processed_code):
        # Indent
        indented_code = "\n".join(["    " + line for line in code.splitlines()])
        processed_code = f"pragma solidity ^0.8.0;\n\ncontract Vulnerable {{\n{indented_code}\n}}"

    # 3. Common fixes for 0.8.x compatibility
    # Fix: function () payable -> fallback() external payable
    processed_code = re.sub(r"function\s*\(\)\s*payable\s*public", "fallback() external payable", processed_code)
    processed_code = re.sub(r"function\s*\(\)\s*public\s*payable", "fallback() external payable", processed_code)
    
    # Fix: msg.sender.transfer/send -> payable(msg.sender).transfer/send
    # This is a naive replacement, might catch false positives but worth trying for snippets
    processed_code = re.sub(r"msg\.sender\.(transfer|send)", "payable(msg.sender).\\1", processed_code)

    return processed_code

def run_slither_on_entry(entry):
    """Runs slither on a single JSON entry."""
    entry_id = entry.get("id")
    code = entry.get("code", "")
    
    if entry_id is None:
        return {"error": "No ID found"}

    output_path = OUTPUT_DIR / f"test_{entry_id}.json"
    
    # Skip if already exists
    if output_path.exists():
        return {"id": entry_id, "skipped": True, "success": True}

    # Create temp file
    temp_file = TEMP_DIR / f"test_{entry_id}.sol"
    
    try:
        processed_code = preprocess_code(code)
        
        with open(temp_file, "w") as f:
            f.write(processed_code)
            
        # Run Slither
        cmd = [SLITHER_CMD, str(temp_file), "--json", str(output_path)]
        
        # Set SOLC_VERSION
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
        
        success = result.returncode == 0 or output_path.exists()
        
        return {
            "id": entry_id,
            "success": success,
            "return_code": result.returncode,
            "stderr": result.stderr if not success else ""
        }

    except subprocess.TimeoutExpired:
        return {"id": entry_id, "success": False, "error": "Timeout"}
    except Exception as e:
        return {"id": entry_id, "success": False, "error": str(e)}
    finally:
        # Cleanup temp file
        if temp_file.exists():
            temp_file.unlink()

def main():
    # Setup directories
    OUTPUT_DIR.mkdir(exist_ok=True)
    TEMP_DIR.mkdir(exist_ok=True)
    
    # Load JSON
    print(f"Loading {JSON_FILE}...")
    with open(JSON_FILE, "r") as f:
        data = json.load(f)
        
    print(f"Found {len(data)} entries.")
    
    # Run in parallel
    num_processes = cpu_count()
    print(f"Starting parallel execution with {num_processes} processes...")
    
    results_summary = []
    
    with Pool(processes=num_processes) as pool:
        for i, result in enumerate(pool.imap_unordered(run_slither_on_entry, data, chunksize=10)):
            results_summary.append(result)
            if (i + 1) % 50 == 0:
                print(f"Processed {i + 1}/{len(data)} entries...")
                
    # Save summary
    with open("slither_json_summary.json", "w") as f:
        json.dump(results_summary, f, indent=2)
        
    print("Done.")

if __name__ == "__main__":
    main()
