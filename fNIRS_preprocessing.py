# Author: Rebecka Fahrni
# Project: fNIRS data analysis
# using MNE-python https://mne.tools/stable/index.html

import sys
sys.path.append('C:/Users/rebec/fNIRS-project/manuel_montage.py')
import mne 
from matplotlib import animation
import manuel_montage
import os.path as op
import numpy as np
import matplotlib.pyplot as plt
from itertools import compress
from matplotlib.cm import ScalarMappable
from matplotlib.colors import Normalize
import os
import mne
import mne_nirs
from mne_nirs.experimental_design import make_first_level_design_matrix
from mne_nirs.statistics import run_glm
from mne_nirs.channels import (get_long_channels, get_short_channels, picks_pair_to_idx)
from nilearn.plotting import plot_design_matrix
from mne.preprocessing.nirs import (optical_density, temporal_derivative_distribution_repair)

# Preprocessing of fNIRS
# ----------------------------------------------------------------------------------------------------------------------


# read Hitachi-files
def read_hitachi(hitachi_path):
    """
    Read Hitachi-csv file
    :param hitachi_path csv file list of strings
    :returns raw: instance of RawHitachi - raw object containing Hitachi data
    """
    raw = mne.io.read_raw_hitachi(hitachi_path)
    return raw


# Dig montage
def self_montage(file_path, csv_file):
    """
    :param file_path: .pos file with location of montage
    :param csv_file: enter csv file with ch_names and position
    :return: montage
    """
    lpa, rpa, nasion, hsp, coord_frame = manuel_montage.read_montage(file_path)
    ch_pos = manuel_montage.convert_to_dic(csv_file)
    return mne.channels.make_dig_montage(ch_pos=ch_pos,
                                         nasion=nasion,
                                         lpa=lpa, rpa=rpa,
                                         hsp=hsp,
                                         hpi=None,
                                         coord_frame='mri')


# 3D Animation using matplotlib


# def init():
#    """ initialize starting simulation """
    #    fig.gca().view_init(azim=-65, elev=25)
    # return [fig]


# def animate(i):
#    """ helper function for steps of simulation, i steps """
#    fig.gca().view_init(azim=i, elev=25)
#    return [fig]


def montage_animation_channels(montage):
    """ Animation of a montage using only channels """
    fig_ = montage.plot(kind='3d')
    fig_.gca().view_init(azim=-65, elev=25)
    fig_.savefig('Data/S34/fig.png')  # save montage as a png file
    for angle in range(0, 360):
        fig_.gca().view_init(angle, 25)
        plt.draw()
        plt.pause(.003)

    # Animate
    # writergif = animation.PillowWriter(fps=30)
    # anim = animation.FuncAnimation(fig, animate, init_func=init,
    #                               frames=360, interval=20, blit=True)
    # Save
    # anim.save('Data/S34/basic_animation.gif', writer=writergif)


def return_montage(montage):
    """ returns montage """
    return montage


def save_in_file(participant, new_name):
    """ returns the filepath to save png/etc. """
    return 'Data/' + str(participant) + '/' + str(new_name)


def more_raw_annotations(raw):
    """Annotations for Raw intensity """
    events_ = mne.find_events(raw)
    event_dict_ = {
        '(Sp)': 1,
        '(Rot-TS)': 2,
        '(Rot-Blesser)': 3,
        '(NV)': 4,
        '(NV-Rot)': 5
    }
    fig = mne.viz.plot_events(events_,
                              sfreq=raw.info['sfreq'],
                              first_samp=raw.first_samp,
                              event_id=event_dict_)

    fig.subplots_adjust(right=0.7)  # make room for legend

    raw.plot(events=events_,
             start=5,
             duration=20,
             color='gray',
             event_color={1: 'r', 2: 'g', 3: 'b', 4: 'm', 5: 'y'})

# ----------------------------------------------------------------------------------------------------------------------
# test on first participant data: S11 (no bad channels)

# get raw-object


raw1 = read_hitachi('Data/S11/S11_MES_Probe1.csv')  # only left hemisphere
# raw2 = read_hitachi('Data/S11/S11_MES_Probe2.csv') # only right hemisphere
# raw = read_hitachi(['Data/S11/S11_MES_Probe1.csv', 'Data/S11/S11_MES_Probe2.csv']) # both hemis.


# montage11 = self_montage(file_path='Data/S11/0001.pos', csv_file='Data/S11/0001_edit.csv') # both hemis.
montage11_1 = self_montage(file_path='Data/S11/0001.pos', csv_file='Data/S11/probe1_channel_montage.csv') # only left

raw1.set_montage(montage11_1)  # both hemis.

# fig = mne.viz.plot_sensors(raw1.info, kind='3d')
# fig.savefig('Data/S11/sensors_3d.png')  # looks fine

raw1.load_data()

events = mne.find_events(raw1)
event_dict  =  {'(Sp)':1,
     '(Rot-TS)':2 ,
     '(Rot-Blesser)':3,
     '(NV)':4,
     ' (NV-Rot)':5}


epochs = mne.Epochs(raw1, events, tmin=-0.3, tmax=10, event_id=event_dict)
print(events)
event_desc = {v: k for k, v in event_dict.items()}
mne.annotations_from_events(events=events,sfreq=raw1.info['sfreq'],event_desc=event_desc)
# epochs.plot(n_epochs=10)
picks = mne.pick_types(raw1.info, meg=False, fnirs=True)
dists = mne.preprocessing.nirs.source_detector_distances(
    raw1.info, picks=picks)
raw1.pick(picks[dists > 0.01])
raw1.plot(n_channels=len(raw1.ch_names),
          duration=5000, show_scrollbars=False)

mne.datasets.fetch_fsaverage(subjects_dir=None, verbose=True)
brain = mne.viz.Brain('fsaverage', subjects_dir=None, background='white', cortex='0.7')
brain.add_sensors(raw1.info, trans='fsaverage', fnirs=['channels','pairs','sources', 'detectors'])

brain.show_view(azimuth=20, elevation=90, distance=800)
brain.save_image('Data/S11/sensors_left.png')


# ----------------------------------------------------------------------------------------------------------------------


"""
def init():
    fig.gca().view_init(azim=-65, elev=25)
    return [fig]


def animate(i):
    fig.gca().view_init(azim=i, elev=25)
    return [fig]

for angle in range(0, 360):
    fig.gca().view_init(angle, 25)
    plt.draw()
    plt.pause(.003)
"""
# plt.show()

# Animate
# writergif = animation.PillowWriter(fps=30)
# anim = animation.FuncAnimation(fig, animate, init_func=init,
#                               frames=360, interval=20, blit=True)
# Save

# anim.save('Data/S11/basic_animation.gif', writer=writergif)
# montage33.plot(kind='topomap', show_names=False)


# ---------------------------------------------------------------------------------------------
# plot 

# raw1.plot(n_channels=len(raw1.ch_names), duration=5000, show_scrollbars=False)

# converting raw to optical density
raw_od = mne.preprocessing.nirs.optical_density(raw1)
# raw_od.plot(n_channels=len(raw_od.ch_names), duration=5000, show_scrollbars=False)

# evaluate quality of data
sci = mne.preprocessing.nirs.scalp_coupling_index(raw_od)
fig, ax = plt.subplots()
ax.hist(sci)
ax.set(xlabel='Scalp Coupling Index', ylabel='Count', xlim=[0, 1])
# set bads
raw_od.info['bads'] = list(compress(raw_od.ch_names, sci < 0.5))

# converting optical density to haemoglobin 
raw_haemo = mne.preprocessing.nirs.beer_lambert_law(raw_od, ppf=0.57)
raw_haemo.plot(n_channels=len(raw_haemo.ch_names),
               duration=500, show_scrollbars=False)
       

# removing heart rate 
#fig = raw_haemo.plot_psd(average=True)
#fig.suptitle('Before filtering', weight='bold', size='x-large')
#fig.subplots_adjust(top=0.88)
#raw_haemo = raw_haemo.filter(0.05, 0.7, h_trans_bandwidth=0.2,
#                             l_trans_bandwidth=0.02)
#fig = raw_haemo.plot_psd(average=True)
#fig.suptitle('After filtering', weight='bold', size='x-large')
#fig.subplots_adjust(top=0.88)
       


fig = mne.viz.plot_events(events,
                          event_id=event_dict,
                          sfreq=raw_haemo.info['sfreq'])
fig.subplots_adjust(right=0.7)  # make room for the legend

reject_criteria = dict(hbo=80e-6)
tmin, tmax = -5, 15

epochs = mne.Epochs(raw_haemo, events, event_id=event_dict,
                    tmin=tmin, tmax=tmax,
                    reject=reject_criteria, reject_by_annotation=True,
                    proj=True, baseline=(None, 0), preload=True,
                    detrend=None, verbose=True)


# ---------------------------------------------------------------------------------------------

# Converting from raw intensity to optical density

# raw_od = mne.preprocessing.nirs.optical_density(raw)

# raw_od.plot(n_channels=len(raw_od.ch_names),duration=500, show_scrollbars=False)
