import os
import re
import pandas as pd
import matplotlib.pyplot as plt

# --- CONFIGURATION ---
# Paths relative to src/evaluation/
base_path = '../../data/preprocessed_data'
no_pragma_base_path = 'no_pragma_contracts' 

# Regex for version extraction
version_pattern = re.compile(r'pragma\s+solidity\s*([^;]+);', re.IGNORECASE)

# Regex to find the FIRST version number (e.g., 0.4.24) inside the string
number_extractor = re.compile(r'(\d+)\.(\d+)\.(\d+)')

extracted_data = []

print(f"Scanning directory (with pragma): {base_path} ...")

# Filtering variables
SKIP_TARGET = 435
skipped_count = 0
TARGET_CATEGORY = '>=0.4.22 <0.6.0'

# ============================
# 1) CONTRACTS THAT HAVE PRAGMA
# ============================
for root, dirs, files in os.walk(base_path):
    for file in files:
        if not file.endswith(".sol"):
            continue

        file_path = os.path.join(root, file)

        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception:
            continue

        # --- EXTRACT VERSION ---
        match = version_pattern.search(content)

        # If there is NO pragma in the entire contract -> skip (do NOT count here, handled in no-pragma section if applicable)
        if not match:
            continue

        sol_version_raw = match.group(1).strip()

        # Extract Major.Minor.Patch numbers
        v_match = number_extractor.search(sol_version_raw)
        if not v_match:
            continue

        major = int(v_match.group(1))
        minor = int(v_match.group(2))
        patch = int(v_match.group(3))

        # --- CATEGORIZATION LOGIC ---
        category = None

        if major == 0 and minor == 4:
            if patch < 11:
                category = '^0.4.0'
            elif 11 <= patch < 19:
                category = '^0.4.11'
            elif 19 <= patch < 22:
                category = '^0.4.19'
            elif patch >= 22:
                category = '^0.4.22'
        elif major == 0 and minor == 5:
            # All 0.5.x versions: >=0.4.22 and <0.6.0
            category = '>=0.4.22 <0.6.0'

        if category is None:
            continue

        # --- FILTERING LOGIC ---
        if category == TARGET_CATEGORY and skipped_count < SKIP_TARGET:
            skipped_count += 1
            continue

        extracted_data.append({
            'Category': category,
            'File_Name': file,
            'Raw_Version': sol_version_raw,
            'Full_Path': file_path
        })

print("Done scanning contracts with pragma.\n")

# ============================
# 2) NO-PRAGMA CONTRACTS FOLDER
# ============================

print(f"Scanning directory (no pragma contracts): {no_pragma_base_path} ...")

# Map folder names to categories
no_pragma_folder_to_category = {
    '^0.4.24': '>=0.4.22 <0.6.0',  # as you requested
    '^0.4.19': '^0.4.19',
    '^0.4.11': '^0.4.11'
}

if os.path.isdir(no_pragma_base_path):
    for folder_name in os.listdir(no_pragma_base_path):
        folder_path = os.path.join(no_pragma_base_path, folder_name)
        if not os.path.isdir(folder_path):
            continue

        category = no_pragma_folder_to_category.get(folder_name)
        if category is None:
            print(f"Warning: folder '{folder_name}' not in mapping; skipping.")
            continue

        # Walk recursively through this folder and count .sol files
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                if not file.endswith(".sol"):
                    continue

                full_path = os.path.join(root, file)

                # --- FILTERING LOGIC ---
                if category == TARGET_CATEGORY and skipped_count < SKIP_TARGET:
                    skipped_count += 1
                    continue

                extracted_data.append({
                    'Category': category,
                    'File_Name': file,
                    'Raw_Version': f'no_pragma_{folder_name}',
                    'Full_Path': full_path
                })
else:
    print(f"Warning: no_pragma_contracts directory '{no_pragma_base_path}' not found.")

# ============================
# 3) OUTPUT & SUMMARY
# ============================

df = pd.DataFrame(extracted_data)

print(f"\nScanning complete. Total counted files: {len(df)}")
print(f"Total skipped files from {TARGET_CATEGORY}: {skipped_count}")

# 2. Calculate Totals (only requested categories)
order = [
    '^0.4.0',
    '^0.4.11',
    '^0.4.19',
    '^0.4.22',
    '>=0.4.22 <0.6.0'
]

counts = df['Category'].value_counts().reindex(order, fill_value=0)

summary_df = pd.DataFrame({
    'Group': counts.index,
    'Total Count': counts.values
})

total_files = summary_df['Total Count'].sum()
if total_files > 0:
    summary_df['Percentage'] = (
        summary_df['Total Count'] / total_files * 100
    ).round(2).astype(str) + '%'
else:
    summary_df['Percentage'] = '0.00%'

print("\n--- Final Categorization Table ---")
print(summary_df.to_string(index=False))

# ============================
# 4) PLOTTING
# ============================

# Rename for plotting
version_counts = counts.rename(index={'>=0.4.22 <0.6.0': '>=0.4.22 < newer'})

plt.figure(figsize=(8, 8))

# Create bar plot
ax = version_counts.plot(kind='bar', color='#4c72b0', edgecolor='black', width=0.8)

plt.title('', fontsize=10)
plt.xlabel('Solidity Version Category', fontsize=10)
plt.ylabel('Number of Contracts', fontsize=10)
plt.xticks(rotation=0, ha='center')
plt.grid(axis='y', linestyle='--', alpha=0.5)

# Add value labels on top of bars
for i, v in enumerate(version_counts.values):
    ax.text(i, v + max(version_counts.max() * 0.02, 1), str(v),
            ha='center', va='bottom', fontsize=9)

plt.tight_layout()

# Save
output_image = 'solidity_category_distribution_grouped_updated.png'
plt.savefig(output_image, dpi=300)
print(f"\nChart saved to: {os.path.abspath(output_image)}")
