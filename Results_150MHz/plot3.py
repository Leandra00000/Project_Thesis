import matplotlib.pyplot as plt
import numpy as np
import re

# === File Reading ===
file_path = 'Joined.txt'

max_pkt_len = []
tdma = []
parallel_time = []

reading_phase = 'tdma'
parallel_pkt_lens = []

with open(file_path, 'r') as f:
    for line in f:
        if 'Average Parallel total time for 4 DMA transfers' in line:
            reading_phase = 'parallel'

        if reading_phase == 'tdma':
            match = re.match(r"MAX_PKT_LEN = (\d+),.*Average time per operation = ([\d.]+) us", line)
            if match:
                pkt_len = int(match.group(1))
                if pkt_len <= 131072:
                    max_pkt_len.append(pkt_len)
                    tdma.append(float(match.group(2)))
        elif reading_phase == 'parallel':
            match_parallel = re.match(r"MAX_PKT_LEN = (\d+),.*Average Parallel total time for 4 DMA transfers = ([\d.]+) us", line)
            if match_parallel:
                pkt_len = int(match_parallel.group(1))
                if pkt_len <= 131072:
                    parallel_pkt_lens.append(pkt_len)
                    parallel_time.append(float(match_parallel.group(2)))

# Ensure that the packet lengths match for comparison
assert max_pkt_len == parallel_pkt_lens, "Mismatch in packet sizes between TDMA and parallel data."

# === Calculation ===
Tx = 15.0  # B/us

results = [
    Tx * (4 * td - (4 * td - pt)) + pkt
    for td, pt, pkt in zip(tdma, parallel_time, max_pkt_len)
]

def next_power_of_two(x):
    return 1 << (int(np.ceil(np.log2(x))))

next_pow2 = [next_power_of_two(r) for r in results]
x_indices = np.arange(len(max_pkt_len))

# Format X-axis labels
x_labels = []
for pkt in max_pkt_len:
    if pkt < 1024:
        x_labels.append(f"{pkt} B")
    elif pkt < 1024 * 1024:
        x_labels.append(f"{pkt // 1024} KB")
    else:
        x_labels.append(f"{pkt // (1024 * 1024)} MB")

# === Plotting ===
plt.figure(figsize=(12, 7))

# Increase font sizes globally
plt.rcParams.update({
    'font.size': 16,          # base font size
    'axes.titlesize': 20,     # title font size
    'axes.labelsize': 18,     # x and y label size
    'xtick.labelsize': 14,    # x tick labels
    'ytick.labelsize': 14,    # y tick labels
    'legend.fontsize': 16     # legend font size
})

plt.plot(x_indices, results, color='purple', linestyle='-', label='Original Result', zorder=1)
plt.plot(x_indices, next_pow2, color='orange', linestyle='--', label='Next Power of 2', zorder=1)

for x, y, np2, pkt in zip(x_indices, results, next_pow2, max_pkt_len):
    adjusted = y - pkt
    if adjusted < pkt:
        plt.scatter(x, y, color='green', s=60, zorder=2)
    else:
        plt.scatter(x, y, color='red', marker='x', s=100, zorder=2)

    plt.text(x, y - (0.05 * y), f"{y:.1f}", fontsize=12, ha='center', va='top', color='purple')
    plt.text(x, np2 + (0.05 * np2), f"{np2}", fontsize=12, ha='center', va='bottom', color='orange')

plt.xticks(x_indices, x_labels, rotation=45)
plt.title('Buffer Size for Different Transfer Sizes')
plt.xlabel('Packet Size')
plt.ylabel('Buffer Size (Bytes)')
plt.grid(True, linestyle='--', linewidth=0.7)
plt.legend()
plt.tight_layout()
plt.show()
