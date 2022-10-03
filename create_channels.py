
import numpy as np 
import pandas as pd
from scipy.spatial import distance
from scipy.spatial.distance import pdist, squareform
from sklearn.metrics.pairwise import euclidean_distances
from scipy.spatial.distance import cdist, euclidean

def mid_point(array1,array2):
    x1, y1, z1, x2, y2, z2 = array1[0],array1[1],array1[2], array2[0],array2[1],array2[2]
    return np.array(((x1+x2 )/2,(y1+y2 )/2,(z1+z2 )/2))

def create_channels(csv_file):
    df = pd.read_csv(csv_file)
    print(df)
    x_y_z = df.iloc[:, 1:].to_numpy()
    first_4_ch = x_y_z[:6] # S1,D1,S2,D2,S3
    CH1 = mid_point(first_4_ch[0],first_4_ch[1])



    print(CH1)



    # ary = cdist(df.iloc[:, 1:], df.iloc[:, 1:], metric='euclidean')
    # pd.DataFrame(ary)


print(create_channels('Data/S11/probe1_channel_montage.csv'))