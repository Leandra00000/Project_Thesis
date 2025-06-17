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
bandwidths = []

pkt_labels = []
avg_times_per_byte = []
avg_times_per_op = []


fifo_sizes_exact = []
fifo_sizes_power2 = []

Tx = 10_000_000  # 10 MB/s
num_fifos = 4

valid_x = []
valid_exact = []
valid_power2 = []

invalid_x = []
invalid_reasons = []


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

    match_bw = re.search(r'Bandwith\s*=\s*([\d.]+)', content)
    if match_bw:
        bandwidth = float(match_bw.group(1))
        bandwidths.append(bandwidth)
    else:
        bandwidths.append(None)


    

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

# --- Plot Bandwidth ---
plt.figure(figsize=(10, 6))
plt.plot(x, bandwidths, marker='x', color='green')
plt.title('Bandwidth vs Packet Size')
plt.xlabel('Packet Size')
plt.xticks(x, pkt_labels)
plt.ylabel('Bandwidth (MB/s)')

# Add value labels
for xi, yi in zip(x, bandwidths):
    if yi is not None:
        plt.text(xi, yi + 0.5, f'{yi:.2f}', ha='center', va='bottom',
                 bbox=dict(boxstyle='round,pad=0.3', facecolor='white', edgecolor='gray', alpha=0.7), fontsize=9)

plt.grid(True, linestyle='--', linewidth=0.5)
plt.tight_layout()
plt.show()





for idx, (label, avg_op_ns) in enumerate(zip(pkt_labels, avg_times_per_op)):
    if avg_op_ns is None:
        fifo_sizes_exact.append(None)
        fifo_sizes_power2.append(None)
        invalid_x.append(idx)
        invalid_reasons.append("No data")
        continue

    bsize = parse_packet_size(label)
    aT_sec = avg_op_ns / 1e9
    Q = num_fifos * Tx * aT_sec

    if Q >= bsize:
        fifo_sizes_exact.append(None)
        fifo_sizes_power2.append(None)
        invalid_x.append(idx)
        invalid_reasons.append("Q ≥ Bsize")
        continue

    S_exact = Q + bsize
    S_power2 = 2 ** int(np.ceil(np.log2(S_exact)))

    fifo_sizes_exact.append(S_exact)
    fifo_sizes_power2.append(S_power2)

    valid_x.append(idx)
    valid_exact.append(S_exact)
    valid_power2.append(S_power2)


plt.figure(figsize=(10, 6))

# Plot valid results
plt.plot(valid_x, valid_exact, marker='o', label='Exact FIFO Size')
plt.plot(valid_x, valid_power2, marker='s', linestyle='--', label='FIFO Size (Power of 2)')

# Mark invalids as red Xs
plt.scatter(invalid_x, [0]*len(invalid_x), color='red', marker='x', label='Invalid (Q ≥ Bsize)')

# Labeling
plt.title('FIFO Size Per Packet Size (Valid & Invalid)')
plt.xlabel('Packet Size')
plt.xticks(x, pkt_labels)
plt.ylabel('FIFO Size (Bytes)')

# Annotate valid values
for xi, se, sp in zip(valid_x, valid_exact, valid_power2):
    plt.text(xi, se + 20, f'{int(se)}', ha='center', fontsize=8, color='blue')
    plt.text(xi, sp + 40, f'{int(sp)}', ha='center', fontsize=8, color='darkorange')

# Annotate invalids
for xi, reason in zip(invalid_x, invalid_reasons):
    plt.text(xi, 30, reason, ha='center', fontsize=8, color='red')

plt.legend()
plt.grid(True, linestyle='--', linewidth=0.5)
plt.tight_layout()
plt.show()
