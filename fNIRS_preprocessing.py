# Author: Rebecka Fahrni
# Project: fNIRS data analysis
# using MNE-python https://mne.tools/stable/index.html

import mne
from matplotlib import animation
import manuel_montage
import os.path as op
import numpy as np
import mne_nirs
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
    return mne.channels.make_dig_montage(ch_pos=ch_pos, nasion=nasion, lpa=lpa, rpa=rpa,
                                             hsp=hsp, hpi=None, coord_frame='unknown')


# 3D Animation using matplotlib


# def init():
#    """ initialize starting simulation """
    #    fig.gca().view_init(azim=-65, elev=25)
    #return [fig]


#def animate(i):
#    """ helper function for steps of simulation, i steps """
#    fig.gca().view_init(azim=i, elev=25)
#    return [fig]


def montage_animation_channels(montage):
    """ Animation of a montage using only channels """
    fig = montage.plot(kind='3d')
    fig.gca().view_init(azim=-65, elev=25)
    fig.savefig('Data/S34/fig.png')  # save montage as a png file
    for angle in range(0, 360):
        fig.gca().view_init(angle, 25)
        plt.draw()
        plt.pause(.003)

    # Animate
    writergif = animation.PillowWriter(fps=30)
    #anim = animation.FuncAnimation(fig, animate, init_func=init,
    #                               frames=360, interval=20, blit=True)
    # Save
    #anim.save('Data/S34/basic_animation.gif', writer=writergif)


def return_montage(montage):
    """ returns montage """
    return montage


def save_in_file(participant, new_name):
    """ returns the filepath to save png/etc. """
    return 'Data/' + str(participant) + '/' + str(new_name)


def more_raw_annotations(raw_intensity):
    """Annotations for Raw intensity """
    events = mne.find_events(raw)
    #dict_events = raw_intensity.annotations.rename(
    #    {                             1: 'Speech (Sp)',
    #                                  2: 'Rotated speech TS (Rot-TS)',
    #                                  3: 'Rotated speech Blesser (Rot-Blesser)',
    #                                  4:'Noise-vocoded speech (NV)',
    #                                 5: 'rotated noise-vocoded speech (NV-Rot)'})
    #print(raw1.annotations)
    #annot_from_events = mne.annotations_from_events( events=events, event_desc=dict_events, sfreq=raw1.info['sfreq'],
        #orig_time=raw1.info['meas_date'])
    #raw1.set_annotations(annot_from_events)

# ----------------------------------------------------------------------------------------------------------------------
# test on first participant data: S11 (no bad channels)

# get raw-object
# raw1 = read_hitachi('Data/S11/S11_MES_Probe1.csv')
# raw2 = read_hitachi('Data/S11/S11_MES_Probe2.csv')


raw = read_hitachi(['Data/S11/S11_MES_Probe1.csv', 'Data/S11/S11_MES_Probe2.csv'])

#raw.copy().pick_types(fnirs=True, stim=True).plot(start=0, duration=20)

# set montage # blue source: S / green decoder: D

# left hemisphere (Probe 1)
montage11 = self_montage(file_path='Data/S11/0001.pos', csv_file='Data/S11/0001_edit.csv')
raw.set_montage(montage11, match_case=True, match_alias=True, on_missing='ignore')

# right hemisphere (Probe 2)
# montage11_2 = self_montage(file_path='Data/S11/0001.pos', csv_file='Data/S11/probe2_channel_montage.csv')

# mne.set_montage right hemisphere: raises Error - IndexError: index 44 is out of bounds for axis 0 with size 44
# raw2.set_montage(montage11_2)

# raw.load_data()

#mne.datasets.fetch_fsaverage(subjects_dir=None, verbose=True)
#brain = mne.viz.Brain('fsaverage', subjects_dir=None, background='white', cortex='0.5')
# brain.add_sensors(raw1.info, trans='fsaverage', fnirs=['channels','sources', 'detectors'])
#brain.add_sensors(raw.info, trans='fsaverage')
#brain.show_view(azimuth=20, elevation=90, distance=800)
#brain.save_image('[00-info]/templete_1.png')
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



# ---------------------------------------------------------------------------------------------

# Converting from raw intensity to optical density

#raw_od = mne.preprocessing.nirs.optical_density(raw)

#raw_od.plot(n_channels=len(raw_od.ch_names),duration=500, show_scrollbars=False)

