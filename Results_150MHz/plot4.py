import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression

# Load data from the Results_1DMA.txt file
pkt_sizes = []
times_us = []

with open("1 DMA.txt", "r") as file:
    for line in file:
        parts = line.strip().split(',')
        size = int(parts[0].split('=')[1])
        time = float(parts[2].split('=')[1].split()[0])
        pkt_sizes.append(size)
        times_us.append(time)

pkt_sizes = np.array(pkt_sizes, dtype=np.float64)
times_us = np.array(times_us)

# Reshape for sklearn
X = pkt_sizes.reshape(-1, 1)
y = times_us

# Fit linear regression model
model = LinearRegression().fit(X, y)

slope = model.coef_[0]
intercept = model.intercept_

# Calculate effective bandwidth (MB/s)
bandwidth_MBps = 1 / slope

print(f"Linear model: time = {slope:.6e} * size + {intercept:.6f} (us)")
print(f"Estimated fixed overhead (b): {intercept:.6f} us")
print(f"Effective data rate: {bandwidth_MBps:.2f} MB/s")

# Plotting
plt.figure(figsize=(10, 6))
plt.scatter(pkt_sizes, times_us, color='blue', label='Measured')
plt.plot(pkt_sizes, model.predict(X), color='red', label='Fitted Line')
plt.xlabel("Packet Size (Bytes)")
plt.ylabel("Average Transfer Time (us)")
plt.title("DMA Transfer Time vs Packet Size")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.show()
