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
import manuel_montage

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
    # TODO https://mne.tools/stable/generated/mne.channels.make_dig_montage.html#mne.channels.make_dig_montage
    # TODO make_dig_montage might be better
    return montage

# better montage
def self_montage(file_path, csv_file):
    """
    :param file_path: .pos file with montage, open file and then read ch_pos: dict,
    :return: montage """

    with open (file_path) as file:
        # get ch_pos (dict) shape keys (channel names) values are 3d coordinates (3,)
        # get nasion position (array, shape(3,)

        lpa, rpa, nasion, hsp, coord_frame = manuel_montage.read_montage(file_path)
        ch_pos = manuel_montage.convert_to_dic(csv_file)
        return mne.channels.make_dig_montage(ch_pos=ch_pos, nasion= nasion, lpa=lpa, rpa=rpa, hsp=hsp, hpi=None, coord_frame='unknown')

# --------------------------------------------------------------------------------------------
# test on first participant data: S01

raw1 = read_hitachi('Data/S01/S01_MES_Probe1.csv')
raw2 = read_hitachi('Data/S01/S01_MES_Probe2.csv')

# channel_names = raw1.info.ch_names
# print(channel_names)
# ---------------------------------------------------------------------------------------------
# set montage x,y,z coordinates Montage convert pos file using get_montage function


# Fiducial point nasion not found, assuming identity unknown to head transformation
# TODO Maybe try to set nasion point in csv file extract more information for channel montage look into the source code now used 'auto' for calculating nasion and ear position
# raw1.set_montage(get_montage('Data/S01/probe1_channel_montage.csv'))
# raw2.set_montage(get_montage('Data/S01/probe2_channel_montage.csv'))
# TODO check why raw2 (right hemisphere) has problems plotting the sensors
montage1 = self_montage(file_path='Data/S01/0001.pos', csv_file= 'Data/S01/probe1_channel_montage.csv')
# raw2.set_montage(self_montage(file_path='Data/S01/0001.pos', csv_file= 'Data/S01/probe2_channel_montage.csv'))
# plot  1 - 22 sensors for left hemisphere
mne.viz.plot_montage(montage1, scale_factor=20, show_names=True, kind='3d', sphere= 'auto', verbose=None)

# plot 23-44 channels for right hemisphere
#raw2.plot()

# ----------------------------------------------------------------------------------------------
# blue source: S / green decoder: D

# Standard Montage EXAMPLE
# mon = mne.channels.make_standard_montage('standard_1020')
# need = 'S1 D1 S2 D2 S3 D3 S4 D4 S5 D5 S6 D6 S7 D7 S8'.split()
# have = 'F3 FC3 C3 CP3 P3 F5 FC5 C5 CP5 P5 F7 FT7 T7 TP7 P7'.split()
# mon.rename_channels(dict(zip(have, need)))

# ---------------------------------------------------------------------------------------------
# Get events
#
events = mne.find_events(raw=raw1, initial_event=True)
# sfreq = raw1.info['sfreq']
# report = mne.Report(title='Events example')
# report.add_events(events=events, title='Events from "events"', sfreq=sfreq)
# report.save('report_events.html', overwrite=True)


event_dict = {'Sp': 1, 'Rot-TS': 2, 'Rot-Blesser': 3,'NV': 4, 'NV-Rot': 5}
# fig = mne.viz.plot_events(events, event_id=event_dict, sfreq=raw1.info['sfreq'], first_samp=raw1.first_samp)
# ----------------------------------------------------------------------------------------------
# print(mne.pick_types(raw2.info, meg=False, eeg=False, fnirs=True, exclude=[]))





