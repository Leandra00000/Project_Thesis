import matplotlib.pyplot as plt
import re

# Read file
with open("Results_4DMAs.txt", "r") as f:
    lines = f.readlines()

# Initialize data containers
single_dma_pktlen = []
single_dma_bw = []
single_dma_time = []

parallel_dma_pktlen = []
parallel_dma_bw = []
parallel_dma_time = []

# Regex patterns
single_re = re.compile(r"MAX_PKT_LEN = (\d+), Bandwith = ([\d\.]+) MB/s, Average time per operation = ([\d\.]+) us")
parallel_re = re.compile(r"MAX_PKT_LEN = (\d+), Bandwith = ([\d\.]+) MB/s, Average Parallel total time for 4 DMA transfers = ([\d\.]+) us")

# Parse the file
for line in lines:
    match = single_re.match(line)
    if match:
        pktlen = int(match.group(1))
        if pktlen <= 131072:
            single_dma_pktlen.append(pktlen)
            single_dma_bw.append(float(match.group(2)))
            single_dma_time.append(float(match.group(3)))
    match = parallel_re.match(line)
    if match:
        pktlen = int(match.group(1))
        if pktlen <= 131072:
            parallel_dma_pktlen.append(pktlen)
            parallel_dma_bw.append(float(match.group(2)))
            parallel_dma_time.append(float(match.group(3)))

# Calculate derived values
single_dma_time_4x = [t * 4 for t in single_dma_time]
time_saved = [s - p for s, p in zip(single_dma_time_4x, parallel_dma_time)]

# --- Plot 1: Bandwidth ---
plt.figure(figsize=(10, 5))
plt.plot(single_dma_pktlen, single_dma_bw, label='4× 1 DMA Bandwidth', marker='o')
plt.plot(parallel_dma_pktlen, parallel_dma_bw, label='4 Parallel DMA Bandwidth', marker='x')
plt.xlabel('MAX_PKT_LEN (bytes)')
plt.ylabel('Bandwidth (MB/s)')
plt.title('Bandwidth vs. MAX_PKT_LEN (Up to 131072)')
plt.legend()
plt.grid(True)
plt.xscale('log', base=2)
plt.tight_layout()
plt.show()

# --- Plot 2: Time ---
plt.figure(figsize=(10, 5))
plt.plot(single_dma_pktlen, single_dma_time_4x, label='4× 1 DMA Time', marker='o')
plt.plot(parallel_dma_pktlen, parallel_dma_time, label='4 Parallel DMA Time', marker='x')
plt.plot(parallel_dma_pktlen, time_saved, label='Time Saved', marker='s')
plt.xlabel('MAX_PKT_LEN (bytes)')
plt.ylabel('Time (µs)')
plt.title('Time Comparison vs. MAX_PKT_LEN (Up to 131072)')
plt.legend()
plt.grid(True)
plt.xscale('log', base=2)
plt.tight_layout()
plt.show()
