# Author: Rebecka Fahrni
# script for plotting

import sys

sys.path.append('C:/Users/rebec/fNIRS-project/manuel_montage.py')
sys.path.append('C:/Users/rebec/fNIRS-project/Preprocessing_individual.py')
import manuel_montage, Preprocessing_individual
import numpy as np
import matplotlib.pyplot as plt
from itertools import compress
import mne
import os


def plot_sensors(number):
    os.makedirs('C:/Users/rebec/fNIRS-project/Data', exist_ok=True)

    file_path1_raw = 'Data/S' + str(number) + '/S' + str(number) + '_MES_Probe1.csv'
    file_path2_raw = 'Data/S' + str(number) + '/S' + str(number) + '_MES_Probe2.csv'
    file_path_pos = 'Data/S' + str(number) + '/0001.pos'
    file_path_csv = 'Data/S' + str(number) + '/0001_edit.csv'
    file_path_save_raw = 'C:/Users/rebec/fNIRS-project/Plots/Preprocessing/Raw/raw_S' + str(number) + '.png'
    file_path_save_raw_op = 'C:/Users/rebec/fNIRS-project/Plots/Preprocessing/Raw_optical_density/raw_op_S' + str(
        number) + '.png'
    file_path_save_raw_hae = 'C:/Users/rebec/fNIRS-project/Plots/Preprocessing/Raw_haemoglobin/raw_hae_S' + str(
        number) + '.png'
    file_path_save_sensors = 'C:/Users/rebec/fNIRS-project/Plots/Sensors_individual/sensor_S' + str(number) + '.png'
    file_path_SCI = 'C:/Users/rebec/fNIRS-project/Plots/SCI/SCI_S' + str(number) + '.png'

    # read raw
    raw = Preprocessing_individual.read_hitachi([file_path1_raw, file_path2_raw])

    montage11 = Preprocessing_individual.self_montage(file_path_pos, file_path_csv)
    raw.set_montage(montage11)

    # load Data
    raw.load_data()

    # read Events from Hitachi-Raw and create an annotation
    events = mne.find_events(raw)
    events = Preprocessing_individual.clean_events(events)

    event_dict = {'Sp': 1,
                  'Rot-TS': 2,
                  'Rot-Blesser': 3,
                  'NV': 4,
                  'NV-Rot': 5}

    event_desc = {v: k for k, v in event_dict.items()}

    # write and set annotations
    annotation = mne.annotations_from_events(events=events, sfreq=raw.info['sfreq'],
                                             event_desc=event_desc,
                                             orig_time=raw.info['meas_date'])
    raw.set_annotations(annotation)
    # set stimuus duration 20s - If orig_time is None, the annotations are synced
    # to the start of the data (0 seconds).
    raw.annotations.set_durations(20)
    # raw.plot(start=5, duration=2000)

    # Selecting channels appropriate for detecting neural responses:
    # remove channels that are too close together (short channels) to detect a
    # neural response (less than 1 cm distance between optodes).
    picks = mne.pick_types(raw.info, meg=False, fnirs=True)
    dists = mne.preprocessing.nirs.source_detector_distances(
        raw.info,
        picks=picks)

    raw.pick(picks[dists > 0.01])
    fig_raw = raw.plot(n_channels=len(raw.ch_names), duration=2000, show_scrollbars=False)
    fig_raw.grab().save(file_path_save_raw)

    # plot sensors
    mne.datasets.fetch_fsaverage(subjects_dir=None, verbose=True)
    brain = mne.viz.Brain('fsaverage', subjects_dir=None, background='white', cortex='0.7')
    brain.add_sensors(raw.info, trans='fsaverage', fnirs=['channels', 'pairs', 'sources', 'detectors'])

    brain.show_view(azimuth=20, elevation=90, distance=800)
    brain.save_image(file_path_save_sensors)

    # converting raw to optical density
    raw_od = mne.preprocessing.nirs.optical_density(raw)
    fig_raw_od = raw_od.plot(n_channels=len(raw_od.ch_names), duration=5000, show_scrollbars=False)
    fig_raw_od.grab().save(file_path_save_raw_op)

    # evaluate quality of data
    sci = mne.preprocessing.nirs.scalp_coupling_index(raw_od)
    fig, ax = plt.subplots()
    ax.hist(sci)
    ax.set(xlabel='Scalp Coupling Index', ylabel='Count', xlim=[0, 1])
    fig.savefig(file_path_SCI)
    # set bads
    raw_od.info['bads'] = list(compress(raw_od.ch_names, sci < 0.5))

    # converting optical density to haemoglobin
    raw_haemo = mne.preprocessing.nirs.beer_lambert_law(raw_od, ppf=0.57)
    fig_hae = raw_haemo.plot(n_channels=len(raw_haemo.ch_names),
                             duration=500, show_scrollbars=False)
    fig_hae.grab().save(file_path_save_raw_hae)


list_folders = ['01', '04', '05', '07', '08', '09', 11, 12, 15, 16, 17, 18, 30, 31, 32, 33, 34, 35, 36,
                37]  # S06 not possible to plot !!!!!!!!!!

for n in list_folders:
    plot_sensors(n)


