import csv
import pandas as pd
import os

# output csv:  4 columns containing ch_name, x, y, and z.

def create_csv(read_filename, outfile):
    """
    Creates a .csv file out of .pos data
    :param read_filename: input file path that gets read
    :param outfile: path to which the output gets written
    :return: None (just creates an output-file)
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
            pre = in_val[0:10]
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
                    x = float(x.lstrip('X=')) / 1000
                    y = content[1] 
                    y = float(y.lstrip('Y=')) / 1000
                    z = content[2] 
                    z = float(z.lstrip('Z=')) / 1000
                    list_content = [str(ch_n), str(x), str(y), str(z)]
                    writer.writerow(list_content)
                else:
                    tup = in_val[i]
                    cont = lines[tup[1]::]
                    content = cont[1::]
                    ch_n = cont[0] 
                    ch_n = ch_n.lstrip('[').rstrip(']')
                    x = content[0] 
                    x = float(x.lstrip('X=')) / 1000
                    y = content[1]
                    y = float(y.lstrip('Y=')) / 1000
                    z = content[2] 
                    z = float(z.lstrip('Z=')) / 1000
                    list_content = [str(ch_n), str(x), str(y), str(z)]
                    writer.writerow(list_content)

    # read .csv of positional .csv file
    df = pd.read_csv(outfile)
    df.to_csv(outfile, index=False, sep=',')  # restructure
    return

"""
# test on participant S01
os.makedirs('C:/Users/rebec/fNIRS-project/Data', exist_ok=True)

# write .pos to .csv
create_csv('Data/S11/0001.pos', 'Data/S11/0001.csv')

# read .csv file with columns: ch_name,x,y,z and create a dataframe
df = pd.read_csv('Data/S11/0001.csv')


# segmentation of Probe1 and Probe2 to new .csv files
probe1 = df[df['ch_name'].str.startswith('Probe1')] # left 
probe2 = df[df['ch_name'].str.startswith('Probe2')]

df.drop('ch_name', axis=1, inplace=True)

new_names = ['S1', 'D1',
             'S2', 'D2',
             'S3', 'D3',
             'S4', 'D4',
             'S5', 'D5',
             'S6', 'D6',
             'S7', 'D7',
             'S8', 'D8',
             'S9', 'D9',
             'S10', 'D10',
             'S11', 'D11',
             'S12', 'D12',
             'S13', 'D13',
             'S14', 'D14',
             'S15','S16']
df.insert(0, 'ch_name', new_names)

# rename
# left hemisphere
new_names_1 = 'S1 D1 S2 D2 S3 D3 S4 D4 S5 D5 S6 D6 S7 D7 S8'.split()

# right hemisphere
new_names_2 = ['S9', 'D8',
             'S10', 'D9',
             'S11', 'D10',
             'S12', 'D11',
              'S13', 'D12',
              'S14', 'D13',
              'S15', 'D14',
              'S16']


probe1.drop('ch_name', axis=1, inplace=True)
probe2.drop('ch_name', axis=1, inplace=True)
probe1.insert(0, 'ch_name', new_names_1)
probe2.insert(0, 'ch_name', new_names_2)


probe1.to_csv('Data/S01/probe1_channel_montage.csv', index=False, sep=',')
probe2.to_csv('Data/S01/probe2_channel_montage.csv', index=False, sep=',')

probe1.to_csv('Data/S34/probe1_channel_montage.csv', index=False, sep=',')
probe2.to_csv('Data/S34/probe2_channel_montage.csv', index=False, sep=',')
df.to_csv('Data/S34/0001_edit.csv', index=False, sep=',')


probe1.to_csv('Data/S33/probe1_channel_montage.csv', index=False, sep=',')
probe2.to_csv('Data/S33/probe2_channel_montage.csv', index=False, sep=',')
df.to_csv('Data/S33/0001_edit.csv', index=False, sep=',')


probe1.to_csv('Data/S11/probe1_channel_montage.csv', index=False, sep=',')
probe2.to_csv('Data/S11/probe2_channel_montage.csv', index=False, sep=',')
df.to_csv('Data/S11/0001_edit.csv', index=False, sep=',')

probe1.to_csv('Data/S11/probe1_channel_montage.csv', index=False, sep=',')
probe2.to_csv('Data/S11/probe2_channel_montage.csv', index=False, sep=',')
df.to_csv('Data/S11/0001_edit.csv', index=False, sep=',')
"""


def create_0001_edit(number):
    os.makedirs('C:/Users/rebec/fNIRS-project/Data', exist_ok=True)

    # write .pos to .csv
    file_path_pos = 'Data/S' + str(number) + '/0001.pos'
    file_path_csv = 'Data/S' + str(number) + '/0001.csv'

    create_csv(file_path_pos, file_path_csv)

    # read .csv file with columns: ch_name,x,y,z and create a dataframe
    df = pd.read_csv(file_path_csv)

    # segmentation of Probe1 and Probe2 to new .csv files
    probe1 = df[df['ch_name'].str.startswith('Probe1')]  # left
    probe2 = df[df['ch_name'].str.startswith('Probe2')]


    # rename
    # left hemisphere
    new_names_1 = 'S1 D1 S2 D2 S3 D3 S4 D4 S5 D5 S6 D6 S7 D7 S8'.split()

    # right hemisphere


    new_names_2 = ['S9', 'D8','S10', 'D9','S11', 'D10','S12', 'D11','S13', 'D12','S14', 'D13','S15', 'D14','S16']

    # new_names_2 = 'S11 D10 S10 D9 S9 D13 S13 D12 S12 D11 S16 D15 S15 D14 S14'.split()
    new_names = new_names_1 + new_names_2
    df.insert(0, 'ch_name', new_names)
    probe1.drop('ch_name', axis=1, inplace=True)
    probe2.drop('ch_name', axis=1, inplace=True)
    probe1.insert(0, 'ch_name', new_names_1)
    probe2.insert(0, 'ch_name', new_names_2)

    file_path1 = 'Data/S' + str(number) + '/probe1_channel_montage.csv'
    file_path2 = 'Data/S' + str(number) + '/probe2_channel_montage.csv'
    probe1.to_csv(file_path1, index=False, sep=',')
    probe2.to_csv(file_path2, index=False, sep=',')

    df.to_csv('Data/S' + str(number) + '/0001_edit.csv', index=False, sep=',')
    return


number = ['01', '04', '05', '06', '07', '08', '09', 11, 12, 15, 16, 17, 18, 30, 31, 32, 33, 34, 35, 36, 37]

for n in number:
    create_0001_edit(n)