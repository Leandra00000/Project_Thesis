import matplotlib.pyplot as plt

# Define human-readable X-axis labels manually
packet_lengths = [
    "32", "64", "128", "256", "512", "1K", "2K", "4K", "8K", "16K", "32K", "64K", 
    "128K", "256K", "512K", "1M", "2M", "4M", "8M"
]

# Read bandwidth values from the file
bandwidths = []
with open("Results_1DMA.txt", "r") as file:
    for line in file:
        if "Bandwith" in line:
            # Extract the value after 'Bandwith = ' and before 'MB/s'
            parts = line.strip().split("Bandwith = ")
            bw = float(parts[1].split(" ")[0])
            bandwidths.append(bw)

# Plotting
plt.figure(figsize=(10, 6))
plt.plot(packet_lengths, bandwidths, marker='o', linestyle='-')
plt.title('Bandwidth for diferent packet length')
plt.xlabel('Packet length')
plt.ylabel('Bandwidth (MB/s)')
plt.yticks([500, 1000, 1500])
plt.grid(True)
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
