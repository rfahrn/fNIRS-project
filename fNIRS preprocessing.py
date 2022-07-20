# author: Rebecka Fahrni
# fNIRS data anaysis BA project

import csv
import mne
import mne_nirs
import seaborn as sns
import pandas as pd
import numpy as np
import clevercsv
import re


def preprocessing(csv_file_hitachi_path):
    raw = mne.io.read_raw_hitachi(csv_file_hitachi_path)
    return raw

def pos_read(file_path):
    montage = mne.channels.read_custom_montage(file_path)
    return montage

raw1 = preprocessing('Data/S01/S01_MES_Probe1.csv')
raw2 = preprocessing('Data/S01/S01_MES_Probe2.csv')
events = mne.find_events(raw=raw1, initial_event=True)

sfreq = raw1.info['sfreq']
report = mne.Report(title='Events example')
report.add_events(events=events, title='Events from "events"', sfreq=sfreq)
#report.save('report_events.html', overwrite=True)

raw1.set_montage(pos_read('Data/S01/0001.csv'))
raw1.plot_sensors()









