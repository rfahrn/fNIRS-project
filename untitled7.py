


# iterate and generate raw.fif
import sys
sys.path.append(r'C:/Users/rebec/fNIRS-project/manuel_montage.py') 
sys.path.append(r'C:/Users/rebec/fNIRS-project/èreprocessing_individual.py') 
import  Preprocessing_individual
import mne
import mne_bids
import mne_nirs
import numpy as np



def gen_file(list_participants):
    for participant in list_participants:
        file_path = "C:/Users/rebec/fNIRS-project/Data/S" + str(participant) +'/FIF_' + str(participant) +'_raw.fif'
        snirf_path = 'C:/Users/rebec/fNIRS-project/Data/SNIRF/S'+str(participant)+'_raw.snirf'
        pos_file_path_1 = 'C:/Users/rebec/fNIRS-project/Data/S' + str(participant) +'/S' + str(participant) + '_MES_Probe1.csv'
        pos_file_path_2 = 'C:/Users/rebec/fNIRS-project/Data/S' + str(participant) +'/S' + str(participant) + '_MES_Probe2.csv'
        montage_path_csv = 'C:/Users/rebec/fNIRS-project/Data/S' + str(participant) + '/0001_edit.csv'
        montage_path_pos = 'C:/Users/rebec/fNIRS-project/Data/S' + str(participant) +'/0001.pos'

        
        raw = Preprocessing_individual.read_hitachi([pos_file_path_1, pos_file_path_2]).load_data()
        
        montage = Preprocessing_individual.self_montage(file_path=montage_path_pos, csv_file=montage_path_csv) 
        raw.set_montage(montage)
        
        # read Events from Hitachi-Raw and create an annotation 
        events = mne.find_events(raw)
        event_dict  =  {'Sp':1,
             'Rot-TS':2 ,
             'Rot-Blesser':3,
             'NV':4,
             'NV-Rot':5}

        event_desc = {v: k for k, v in event_dict.items()}

        # write and set annotations 
        annotation = mne.annotations_from_events(events=events, sfreq=raw.info['sfreq'],
                                                 event_desc=event_desc, 
                                                 orig_time=raw.info['meas_date'])
        raw.set_annotations(annotation)
        # set stimuus duration 20s - If orig_time is None, the annotations are synced 
        #to the start of the data (0 seconds).
        raw.annotations.set_durations(20)
        # raw.plot(start=5, duration=2000)
        #print(raw.info)
        mne_nirs.io.snirf.write_raw_snirf(raw, snirf_path) # write snirf file 
        
        #raw.save(file_path,overwrite=True) # saved them as fif files 

list_par = ['01','04','05','07','08','09',11,12,16,17,18,30,31,32, 33,34,35,36,37] # problem 15 und 06

# gen_file(list_par) # AssertionError: Data must be fnirs_cw_amplitude


# path = r'C:\Users\rebec\fNIRS-project\Data\S37\FIF_37_raw.fif'
# raw = mne.io.read_raw_fif(path).load_data()



# read raw to bids from snirf 
def get_bids_snirf(part_list):
    root = r'C:\Users\rebec\fNIRS-project\Data\BIDS_1'
    
    for part in part_list:
        file_path_fif = "C:/Users/rebec/fNIRS-project/Data/S" + str(part) +'/FIF_' + str(part) +'_raw.fif'
        montage_path_csv = 'C:/Users/rebec/fNIRS-project/Data/S' + str(part) + '/0001_edit.csv'
        montage_path_pos = 'C:/Users/rebec/fNIRS-project/Data/S' + str(part) +'/0001.pos'
        file_path_snirf = 'C:/Users/rebec/fNIRS-project/Data/SNIRF/S'+str(part)+'raw.snirf' 
        
        raw = mne.io.read_raw_fif(file_path_fif).load_data() # fif file 
        
        raw_snirf_intensity = mne.io.read_raw_snirf(file_path_snirf).load_data() # or snif 
        
        montage = Preprocessing_individual.self_montage(file_path=montage_path_pos, csv_file=montage_path_csv) 
        raw.set_montage(montage)
        # read Events from Hitachi-Raw and create an annotation 
        events = mne.find_events(raw)
        events = Preprocessing_individual.clean_events(events)
        event_dict  =  {'Sp':1,
             'Rot-TS':2 ,
             'Rot-Blesser':3,
             'NV':4,
             'NV-Rot':5}

        event_desc = {v: k for k, v in event_dict.items()}

        # write and set annotations 
        annotation = mne.annotations_from_events(events=events, sfreq=raw.info['sfreq'],
                                                 event_desc=event_desc, 
                                                 orig_time=raw.info['meas_date'])
        raw.set_annotations(annotation)
        # set stimuus duration 20s - If orig_time is None, the annotations are synced 
        #to the start of the data (0 seconds).
        raw.annotations.set_durations(20)
        # raw.plot(start=5, duration=2000)
    
        bids_path =  mne_bids.BIDSPath(subject=str(part),  task="speech", 
                                       description="intelligible speech ", root=root, suffix="nirs", 
                                       extension=".snirf", datatype="nirs")
        mne_bids.write_raw_bids(raw, bids_path, 
                                events=events,
                                event_id = event_dict,
                                montage=montage,
                                format="auto",
                            overwrite=True) 


get_bids_snirf(list_par) #  if allow_preload = False: ValueError: The data is already loaded from disk and may be altered. See warning for "allow_preload".
#  ValueError: For preloaded data, you must set the "format" parameter to one of: BrainVision, EDF, or FIF

# read raw to bids from fif
def get_bids_fif(part_list):
    root = r'C:\Users\rebec\fNIRS-project\Data\BIDS_1'
    
    for part in part_list:
        montage_path_csv = 'C:/Users/rebec/fNIRS-project/Data/S' + str(part) + '/0001_edit.csv'
        montage_path_pos = 'C:/Users/rebec/fNIRS-project/Data/S' + str(part) +'/0001.pos'
        file_path = r'C:\Users\rebec\fNIRS-project\Data\S'+str(part)+'\FIF_'+str(part)+'_raw.fif' # read fif files 
        raw = mne.io.read_raw_fif(file_path).load_data()
        montage = Preprocessing_individual.self_montage(file_path=montage_path_pos, csv_file=montage_path_csv) 
        raw.set_montage(montage)
        # read Events from Hitachi-Raw and create an annotation 
        events = mne.find_events(raw)
        events = Preprocessing_individual.clean_events(events)
        event_dict  =  {'Sp':1,
             'Rot-TS':2 ,
             'Rot-Blesser':3,
             'NV':4,
             'NV-Rot':5}

        event_desc = {v: k for k, v in event_dict.items()}

        # write and set annotations 
        annotation = mne.annotations_from_events(events=events, sfreq=raw.info['sfreq'],
                                                 event_desc=event_desc, 
                                                 orig_time=raw.info['meas_date'])
        raw.set_annotations(annotation)
        # set stimuus duration 20s - If orig_time is None, the annotations are synced 
        #to the start of the data (0 seconds).
        raw.annotations.set_durations(20)
        # raw.plot(start=5, duration=2000)
    
        bids_path =  mne_bids.BIDSPath(subject=str(part),  task="speech", 
                                       description="intelligible speech ", root=root, suffix="nirs", 
                                       extension=".snirf", datatype="nirs")
        mne_bids.write_raw_bids(raw, bids_path, 
                                events=events,
                                event_id = event_dict,
                                montage=montage,
                                format="FIF",
                            overwrite=True, allow_preload=True) 

#get_bids_fif(list_par) # IndexError: index 88 is out of bounds for axis 0 with size 88