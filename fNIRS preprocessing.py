# Author: Rebecka Fahrni
# Project: fNIRS data analysis

import csv
import mne
import mne_nirs
import seaborn as sns
import pandas as pd
import numpy as np
import clevercsv
import re

# Preprocessing of fNIRS


def read_hitachi(hitachi_path):
    """
    Read Hitachi-csv file
    :param hitachi_path csv file
    :returns raw: instance of RawHitachi - raw object containing Hitachi data
    """
    raw = mne.io.read_raw_hitachi(hitachi_path)
    return raw

def get_montage(file_path):
    """
    Read montage from a file
    :param file_path: of position: has to be of form '.xyz' or '.csv'
    :return: montage
    """
    montage = mne.channels.read_custom_montage(file_path)
    return montage

# --------------------------------------------------------------------------------------------
# test on first participant data: S01

raw1 = read_hitachi('Data/S01/S01_MES_Probe1.csv')
raw2 = read_hitachi('Data/S01/S01_MES_Probe2.csv')
events = mne.find_events(raw=raw1, initial_event=True)
sfreq = raw1.info['sfreq']
report = mne.Report(title='Events example')
report.add_events(events=events, title='Events from "events"', sfreq=sfreq)
#report.save('report_events.html', overwrite=True)

raw1.set_montage(get_montage('Data/S01/0001.csv'))
raw1.plot_sensors()









