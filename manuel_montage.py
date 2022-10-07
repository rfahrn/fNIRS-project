
import pandas as pd 
import numpy as np

def convert_to_dic(csv_file):
    """ reuse csv file we got from pos_convert to get channel names and pos"""
    with open(csv_file) as f:
        df = pd.read_csv(f, header=None, index_col=0).iloc[1:, :]
        df1 = df.agg(list, axis=1).to_dict()
        dic = {}
        for ch_name, ch_pos in df1.items():
            ch_pos = np.asarray([eval(i) for i in ch_pos]) # ch_name with array of shape (3,)
            dic[ch_name] = ch_pos
        return dic
        
# print(convert_to_dic('Data/S01/0001.csv'))

def read_montage(filename):
    """
    :param filename: file of montage coordinates from .pos
    we need following parameters: ch_pos, nasion, lpa, rpa, hsp (none), hpi (none), coord_frame = MRI 'mri'
    :returns right format for function make_dig_montage arrays and matrix
    """
    with open(filename, 'r') as file:
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
        info_index = in_val[5:11]  # list of tuples of header(info) and index
        dic = {}
        for i in range(len(info_index)):

            if i != len(info_index) - 1:
                tup = info_index[i]
                tup2 = info_index[i + 1]
                name = lines[tup[1]:tup2[1]][0]
                content = np.array(lines[tup[1]:tup2[1]][1::])
                name = name.lstrip('[').rstrip(']')

                if name == 'LeftEar':
                    name = 'lpa'
                elif name == 'RightEar':
                    name = 'rpa'
                elif name == 'Nasion':
                    name = 'nasion'

                x = content[0] 
                x = float(x.lstrip('X=')) /1000
                y = content[1] 
                y = float(y.lstrip('Y=')) /1000
                z = content[2] 
                z = float(z.lstrip('Z=')) /1000
                list_content = [name, [float(x), float(y), float(z)]]
                dic[list_content[0]] = list_content[1]


        hsp = np.matrix((dic['Back'], dic['Top']))
        back = np.array(dic['Back'])
        top = np.array(dic['Top'])
        lpa = np.array(dic['lpa'])
        rpa = np.array(dic['rpa'])
        nasion = np.array(dic['nasion'])
        coord_frame = 'mri' # or 'unknown'

        return lpa, rpa, nasion, hsp, coord_frame
