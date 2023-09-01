#!/usr/bin/env python3
import matplotlib.pyplot as plt
import numpy as np
from topas2numpy import BinnedResult
import sys  # Import sys to access command line arguments
import os  # Import os to manipulate file paths

# Check if at least one command line argument is provided
if len(sys.argv) < 2:
    print("Usage: python script.py file1 [file2 ...]")
    sys.exit(1)

# Create a function to plot data from a file with the file name (without extension) as the label
def plot_file(filename):
    # Check the file extension to determine the format
    _, file_extension = os.path.splitext(filename)
    
    if file_extension == '.dat':
        # Process files in the new format (X, Y, YError)
        data = np.loadtxt(filename)
        x = data[:, 0]
        y = data[:, 1]
        label = os.path.splitext(os.path.basename(filename))[0]
        plt.errorbar(x, y/10, yerr=data[:, 2]/10, label=label)
    else:
        # Process Topas2 files
        dose = BinnedResult(filename)
        x = dose.dimensions[2].get_bin_centers()
        y = np.squeeze(dose.data['Sum'])
        label = os.path.splitext(os.path.basename(filename))[0]
        plt.plot(np.flip(x), y, label=label)

# Iterate over command line arguments starting from the second argument (file1 is the first argument)
for i in range(1, len(sys.argv)):
    file_name = sys.argv[i]
    plot_file(file_name)

plt.xlabel('X')
plt.ylabel('Y')
plt.grid()
plt.legend()
plt.show()

