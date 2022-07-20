
import csv
import pandas as pd
import os
# output csv:  4 columns containing ch_name, x, y, and z.

with open('Data/S01/0001.pos', 'r') as file:
    with open('Data/S01/0001.csv', 'w') as out_f:
        writer = csv.writer(out_f)
        lines = file.readlines()
        lines = [line.replace('\n','') for line in lines]
        header = []
        indi = []
        c = []
        for l in lines:
            if '[' and ']' in l:
                header.append(l)
        for i in header:
            ind = lines.index(i)
            indi.append(ind)
        in_val = list(zip(header, indi))
        in_val = in_val[10:40]
        h = ['ch_name', 'x', 'y', 'z']
        writer.writerow(h)
        for i in range(len(in_val)):
            if i != len(in_val)-1:
                tup = in_val[i]
                tup2 = in_val[i+1]
                cont = lines[tup[1]:tup2[1]]
                ch_n = cont[0]
                ch_n = ch_n.lstrip('[').rstrip(']')
                content = cont[1::]
                x = content[0]
                x = x.lstrip('X=')
                y = content[1]
                y = y.lstrip('Y=')
                z = content[2]
                z = z.lstrip('Z=')
                list_content = [str(ch_n), str(x), str(y), str(z)]
                writer.writerow(list_content)
            else:
                tup = in_val[i]
                cont = lines[tup[1]::]
                head = cont[0]
                content = cont[1::]
                ch_n = cont[0]
                ch_n = ch_n.lstrip('[').rstrip(']')
                x = content[0]
                x = x.lstrip('X=')
                y = content[1]
                y = y.lstrip('Y=')
                z = content[2]
                z = z.lstrip('Z=')
                list_content = [str(ch_n), str(x), str(y), str(z)]
                writer.writerow(list_content)
os.makedirs('C:/Users/rebec/fNIRS-project/Data/S01', exist_ok=True)
df = pd.read_csv('Data/S01/0001.csv')
df.to_csv('Data/S01/0001.csv', index=False, sep=',')
df = pd.read_csv('Data/S01/0001.csv')
probe1 = df[df['ch_name'].str.startswith('Probe1')]
probe2 = df[df['ch_name'].str.startswith('Probe2')]
probe1.to_csv('Data/S01/probe1_channel_montage.csv', index=False, sep=',')
probe2.to_csv('Data/S01/probe2_channel_montage.csv', index=False, sep=',')




