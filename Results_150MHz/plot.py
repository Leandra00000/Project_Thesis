import matplotlib.pyplot as plt
from matplotlib.ticker import MultipleLocator

# Define human-readable X-axis labels manually
packet_lengths = [
    "32", "64", "128", "256", "512", "1K", "2K", "4K", "8K", "16K", "32K", "64K", 
    "128K", "256K", "512K", "1M", "2M", "4M", "8M"
]

# Read bandwidth values from the file
bandwidths = []
with open("1 DMA.txt", "r") as file:
    for line in file:
        if "Bandwith" in line:
            # Extract the value after 'Bandwith = ' and before 'MB/s'
            parts = line.strip().split("Bandwith = ")
            bw = float(parts[1].split(" ")[0])
            bandwidths.append(bw)

# Plotting
plt.figure(figsize=(10, 6))
plt.plot(packet_lengths, bandwidths, marker='o', linestyle='-')
plt.title('Bandwidth for different packet sizes')
plt.xlabel('Packet length')
plt.ylabel('Bandwidth (MB/s)')

# Add grid with less density
ax = plt.gca()
ax.yaxis.set_major_locator(MultipleLocator(200))  # major ticks every 200 MB/s
ax.yaxis.set_minor_locator(MultipleLocator(100))  # minor ticks every 100 MB/s

plt.grid(True, which='major', linestyle='--', linewidth=0.8, alpha=0.9)  # strong major grid
plt.grid(True, which='minor', linestyle=':', linewidth=0.5, alpha=0.6)   # light minor grid

plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
