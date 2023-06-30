import os
import pandas as pd
import csv

# Set shuffle window size
SHUFFLE_WINDOW_SIZE = 20
# Set number of loops to be coherent with the shuffle window size
n_loops = 270 // SHUFFLE_WINDOW_SIZE

# Read csv and create dataframe
df = pd.read_csv("matlab/fake_packets_UE1_temp.csv")
# Create another empty dataframe with the same column names
df1 = pd.DataFrame(columns=list(df.columns))

# In this for loop we shuffle the rows of the original dataframe in groups of 
# ten and then we append them to the second dataframe. The row number sticks to 
# the row, then it is ignored while saving to csv file later.
for iter in range(n_loops):
    rows = df.loc[iter*SHUFFLE_WINDOW_SIZE:
        iter*SHUFFLE_WINDOW_SIZE+SHUFFLE_WINDOW_SIZE-1].sample(frac=1)
    df1 = pd.concat([df1,rows.sample(frac=1)], ignore_index=False)

print(df, df1)

os.remove("./matlab/fake_packets_UE1.csv")
df1.to_csv("./matlab/fake_packets_UE1.csv", index=False)
