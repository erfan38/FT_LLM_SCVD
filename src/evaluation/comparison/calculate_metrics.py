import json
import os
from pathlib import Path

CODE_TEST_FILE = Path("code_test.json")
RESULTS_DIR = Path("slither_json_results")

def is_vulnerable_ground_truth(entry):
    """
    Determines if a file is vulnerable based on ground_truth.
    Ground truth is a JSON string containing 'vulnerableLines' or 'vulnerableCode'.
    """
    gt_str = entry.get("ground_truth", "{}")
    try:
        gt = json.loads(gt_str)
        # Check if vulnerableLines is not empty or vulnerableCode is not empty
        if gt.get("vulnerableLines") or gt.get("vulnerableCode"):
            return True
    except json.JSONDecodeError:
        pass
    return False

def is_vulnerable_slither(result_file):
    """
    Determines if Slither found a vulnerability.
    Filters out 'Informational' and 'Optimization' impacts.
    """
    try:
        with open(result_file, "r") as f:
            data = json.load(f)
            
        if not data.get("success", False):
            return False # Compilation failed or other error -> Treat as negative (or maybe ignore?)
            
        detectors = data.get("results", {}).get("detectors", [])
        for d in detectors:
            impact = d.get("impact", "")
            if impact not in ["Informational", "Optimization"]:
                return True
    except Exception:
        pass
    return False

def calculate_metrics():
    # Load ground truth
    print(f"Loading {CODE_TEST_FILE}...")
    with open(CODE_TEST_FILE, "r") as f:
        code_test_data = json.load(f)
        
    # Map ID to ground truth status
    gt_map = {entry["id"]: is_vulnerable_ground_truth(entry) for entry in code_test_data}
    
    tp = 0
    fp = 0
    tn = 0
    fn = 0
    
    compilation_failures = 0
    fn_samples = []
    processed_count = 0
    
    # Load summary
    SUMMARY_FILE = Path("slither_json_summary.json")
    print(f"Loading {SUMMARY_FILE}...")
    with open(SUMMARY_FILE, "r") as f:
        summary_data = json.load(f)
        
    # Iterate over summary
    for result in summary_data:
        file_id = result.get("id")
        
        if file_id not in gt_map:
            continue
            
        processed_count += 1
        
        actual_vulnerable = gt_map[file_id]
        
        # Check success
        if not result.get("success", False):
            compilation_failures += 1
            slither_vulnerable = False # Treat error as negative (or separate category)
        else:
            # If success, we need to check the JSON file for findings
            # OR we could have stored findings in summary, but we didn't.
            # So we still need to read the JSON file if success is True.
            json_path = RESULTS_DIR / f"test_{file_id}.json"
            if json_path.exists():
                slither_vulnerable = is_vulnerable_slither(json_path)
            else:
                slither_vulnerable = False
        
        if actual_vulnerable and slither_vulnerable:
            tp += 1
        elif not actual_vulnerable and slither_vulnerable:
            fp += 1
        elif not actual_vulnerable and not slither_vulnerable:
            tn += 1
        elif actual_vulnerable and not slither_vulnerable:
            fn += 1
            if len(fn_samples) < 5:
                fn_samples.append(file_id)
            
    print(f"Processed {processed_count} files.")
    print(f"Compilation/Execution Failures: {compilation_failures} ({compilation_failures/processed_count*100:.1f}%)")
    
    accuracy = (tp + tn) / processed_count if processed_count > 0 else 0
    precision = tp / (tp + fp) if (tp + fp) > 0 else 0
    recall = tp / (tp + fn) if (tp + fn) > 0 else 0
    f1 = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0
    
    print("-" * 30)
    print(f"True Positives (TP): {tp}")
    print(f"False Positives (FP): {fp}")
    print(f"True Negatives (TN): {tn}")
    print(f"False Negatives (FN): {fn}")
    print("-" * 30)
    print(f"Accuracy: {accuracy:.4f}")
    print(f"Precision: {precision:.4f}")
    print(f"Recall: {recall:.4f}")
    print(f"F1 Score: {f1:.4f}")
    print("-" * 30)
    
    if fn_samples:
        print("Sample False Negatives (IDs):", fn_samples)

if __name__ == "__main__":
    calculate_metrics()
