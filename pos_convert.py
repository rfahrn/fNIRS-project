import csv
import pandas as pd
import os

# output csv:  4 columns containing ch_name, x, y, and z.

def create_csv(read_filename, outfile):
    """
    Creates a .csv file out of .pos data
    :param read_filename: input file path that gets read
    :param outfile: path to which the output gets written
    :return:
    """

    with open(read_filename, 'r') as file:
        with open(outfile, 'w') as out_f:
            writer = csv.writer(out_f)
            lines = file.readlines()
            lines = [line.replace('\n', '') for line in lines]
            header = []
            indi = []
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

    # read .csv of positional .csv file
    df = pd.read_csv(outfile)
    df.to_csv(outfile, index=False, sep=',')  # restructure
    return


# test on participant S01
os.makedirs('C:/Users/rebec/fNIRS-project/Data/S01', exist_ok=True)

# write .pos to .csv
create_csv('Data/S01/0001.pos', 'Data/S01/0001.csv')

# read .csv file with columns: ch_name,x,y,z and create a dataframe
df = pd.read_csv('Data/S01/0001.csv')
print(df)

# segmentation of Probe1 and Probe2 to new .csv files
probe1 = df[df['ch_name'].str.startswith('Probe1')]
probe2 = df[df['ch_name'].str.startswith('Probe2')]
probe1.to_csv('Data/S01/probe1_channel_montage.csv', index=False, sep=',')
probe2.to_csv('Data/S01/probe2_channel_montage.csv', index=False, sep=',')
