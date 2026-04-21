import matplotlib.pyplot as plt
import os

# Original contract-based distribution (from your table)
categories = [
    '^0.4.0',
    '^0.4.11',
    '^0.4.19',
    '^0.4.22',
    '>=0.4.22 < newer'
]

original_counts = [128, 3063, 523, 497, 4686]
original_total = 8897

# New total (function-based dataset)
new_total = 11290

# Scaling ratio
scale_factor = new_total / original_total

# Compute new proportioned counts
new_counts = [round(c * scale_factor) for c in original_counts]

# Fix rounding error to ensure exact total = 11290
difference = new_total - sum(new_counts)
new_counts[-1] += difference

# Print new table
print("New Proportioned Solidity Version Distribution (Total = 11290):\n")
print(f"{'Category':20s} {'Count':6s}  {'Percent':6s}")
for cat, cnt in zip(categories, new_counts):
    percent = (cnt / new_total) * 100
    print(f"{cat:20s} {cnt:6d}  {percent:6.2f}%")

print(f"\nTotal: {sum(new_counts)}")

# Plot
plt.figure(figsize=(10, 6))
bars = plt.bar(categories, new_counts, color='#4c72b0', edgecolor='black', width=0.6)
plt.xlabel('Solidity Version Category')
plt.ylabel('Number of contracts')
# plt.title('Proportioned Solidity Version Distribution (Function-Based Dataset)')
plt.grid(axis='y', linestyle='--', alpha=0.6)

# Add value labels
for bar in bars:
    height = bar.get_height()
    plt.text(bar.get_x() + bar.get_width()/2., height,
             f'{int(height)}',
             ha='center', va='bottom')

plt.tight_layout()

# Save the figure
output_path = 'solidity_distribution_scaled.png'
plt.savefig(output_path, dpi=300)
print(f"\nPlot saved to {os.path.abspath(output_path)}")
