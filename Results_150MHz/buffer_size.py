import re
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
import numpy as np

# --- Choose your test Rin values (bytes/µs) ---
Rin_values = list(range(1, 1370))

# Load packet sizes and Ldma (µs) from file
packet_sizes = []
times = []
with open("4 DMA_parallel.txt", "r") as f:
    for line in f:
        match = re.search(r"MAX_PKT_LEN = (\d+).*?Average Parallel total time.*?= ([\d\.]+)", line)
        if match:
            pkt_len = int(match.group(1))
            time_us = float(match.group(2))
            packet_sizes.append(pkt_len)
            times.append(time_us)

# Check minimum Bs for each Rin
results = []
for Rin in Rin_values:
    chosen_size = None
    buffer_size = None
    for Bs, Ldma in zip(packet_sizes, times):
        if Rin * Ldma < Bs:  # condition satisfied
            chosen_size = Bs
            buffer_size = Rin * Ldma
            break
    if chosen_size is None or buffer_size is None:
        raise ValueError(f"No suitable Bs found for Rin = {Rin} bytes/µs. Aborting.")
    results.append((Rin, buffer_size, chosen_size))

# Extract data for plotting
Rin_plot = [r[0] for r in results if r[1] is not None]
Buffer_plot = [r[1] for r in results if r[1] is not None]
Bs_plot = [r[2] for r in results if r[1] is not None]

# Formatter for human-readable byte sizes
def human_format(x, pos):
    if x < 1024:
        return f"{int(x)} B"
    elif x < 1024**2:
        return f"{x/1024:.1f} KB"
    elif x < 1024**3:
        return f"{x/1024**2:.1f} MB"
    else:
        return f"{x/1024**3:.1f} GB"

# --- Define discrete Bs values from 32B to 128KB (doubling each step) ---
discrete_Bs = [32 * (2 ** i) for i in range(0, 13)]  # 32B, 64B, ..., 128KB

# Map each Bs to the closest discrete value
Bs_discrete_plot = []
for Bs in Bs_plot:
    closest = min(discrete_Bs, key=lambda x: abs(x-Bs))
    Bs_discrete_plot.append(closest)

# Assign a color to each discrete Bs
colors = plt.cm.tab20(np.linspace(0,1,len(discrete_Bs)))
color_map = {b:c for b,c in zip(discrete_Bs, colors)}

# Plot
plt.figure(figsize=(10,7))
for Bs_val in discrete_Bs:
    idx = [i for i, b in enumerate(Bs_discrete_plot) if b == Bs_val]
    if idx:  # Only plot if there are points
        plt.scatter([Rin_plot[i] for i in idx],
                    [Buffer_plot[i] for i in idx],
                    color=color_map[Bs_val],
                    label=human_format(Bs_val, None),
                    s=25)

plt.xlabel("Input rate Rin (bytes/µs)")
plt.ylabel("Required Buffer Size")
plt.title("Buffer Size Required For Different Input Rates")
plt.yscale("log", base=2)
plt.gca().yaxis.set_major_formatter(FuncFormatter(lambda x, _: human_format(x, _)))
plt.grid(True, which="both", ls="--", alpha=0.7)
plt.legend(title="Chosen Bs", bbox_to_anchor=(1.05, 1), loc='upper left')
plt.tight_layout()
plt.show()
