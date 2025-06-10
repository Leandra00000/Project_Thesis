import os
import re
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter

def parse_packet_size(label):
    """Convert '1K' to 1024, '2K' to 2048, etc."""
    label = label.upper()
    if label.endswith('K'):
        return int(label[:-1]) * 1024
    return int(label)

# Original packet labels to use on X-axis
packet_files = ["32", "64", "128", "256", "512", "1K", "2K", "4K", "8K", "16K"]

pkt_labels = []
avg_times_per_byte = []
avg_times_per_op = []

for label in packet_files:
    filename = f"{label}.txt"
    if not os.path.isfile(filename):
        continue

    pkt_labels.append(label)  # Use for X-axis labels

    with open(filename, 'r') as f:
        content = f.read()

    # Extract Average time per Byte
    match_byte = re.search(r'Average time per Byte\s*=\s*([\d.]+)', content)
    if match_byte:
        avg_time_byte = float(match_byte.group(1)) * 1000  # μs → ns
        avg_times_per_byte.append(avg_time_byte)
    else:
        avg_times_per_byte.append(None)

    # Extract Average time per Operation
    match_op = re.search(r'Average time per operation\s*=\s*([\d.]+)', content)
    if match_op:
        avg_time_op = float(match_op.group(1)) * 1000  # μs → ns
        avg_times_per_op.append(avg_time_op)
    else:
        avg_times_per_op.append(None)

# --- Plot Average Time per Byte ---
x = np.arange(len(pkt_labels))  # Index-based X-axis for plotting

plt.figure(figsize=(10, 6))
plt.plot(x, avg_times_per_byte, marker='o')
plt.title('Average Time per Byte vs Packet Size')
plt.xlabel('Packet Size')
plt.xticks(x, pkt_labels)  # Show original labels like "1K", "2K"
plt.ylabel('Average Time per Byte (ns)')

# Add numeric labels above each point
for xi, yi in zip(x, avg_times_per_byte):
    if yi is not None:
        plt.text(xi, yi + 2, f'{yi:.3f}', ha='center', va='bottom',
                 bbox=dict(boxstyle='round,pad=0.3', facecolor='white', edgecolor='gray', alpha=0.7), fontsize=9)

plt.gca().yaxis.set_major_formatter(FuncFormatter(lambda y, _: f'{int(y)}' if y == int(y) else f'{y:.2f}'))
plt.grid(True, linestyle='--', linewidth=0.5)
plt.tight_layout()
plt.show()

# --- Create Table Image for Average Time per Operation ---
table_data = []
for label, avg_op in zip(pkt_labels, avg_times_per_op):
    if avg_op is not None:
        avg_str = f"{avg_op:.4f}".rstrip('0').rstrip('.')  # Clean format
        table_data.append([label, avg_str])

fig, ax = plt.subplots(figsize=(6, 0.5 * len(table_data) + 1))
ax.axis('off')

table = ax.table(cellText=table_data,
                 colLabels=["Packet Size", "Avg Time per Operation (ns)"],
                 cellLoc='center',
                 loc='center')

table.auto_set_font_size(False)
table.set_fontsize(12)
table.scale(1, 1.5)

plt.tight_layout()
plt.savefig("avg_time_per_operation_table.png", dpi=300)
plt.show()
