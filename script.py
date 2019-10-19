import numpy as np
import pandas as pd 

def load_data(filename):
    data = []
    f = pd.read_csv(filename, sep = " ", usecols=[0,39], names=["time_coordinates", "value"])
    data.append(f)
    return data

files = ["ldex_20161118/data_housekeeping/primary/housekeeping_13297_13304.tab", "ldex_20161118/data_housekeeping/primary/housekeeping_13305_13314.tab"]

dataset = [load_data(f) for f in files]


