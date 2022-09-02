# Author: Rebecka Fahrni
# Project: fNIRS data analysis

import mne
from matplotlib import animation
import manuel_montage
import os.path as op
import numpy as np
import matplotlib.pyplot as plt
from itertools import compress

# Preprocessing of fNIRS
# ----------------------------------------------------------------------------------------------------------------------


# read Hitachi-files
def read_hitachi(hitachi_path):
    """
    Read Hitachi-csv file
    :param hitachi_path csv file
    :returns raw: instance of RawHitachi - raw object containing Hitachi data
    """
    raw = mne.io.read_raw_hitachi(hitachi_path)
    return raw


# setting montage with only xyz position - not good
def get_montage(file_path):
    """
    Read montage from a file
    :param file_path: of position: has to be of form '.xyz' or '.csv'
    :return: montage
    """
    montage = mne.channels.read_custom_montage(file_path)
    return montage


# better montage
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
#def init():
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
    # include information of duration of each stimulus 5 seconds for all conditions in experiment
    # raw_intensity.annotations.set_duration(5)  # 5 seconds for all conditions
    # TODO ask about how long each stimulus took for all conditions
    raw_intensity.set_duration(20)
    raw_intensity.annotations.rename({1: 'Speech (Sp)',
                                      2: 'Rotated speech TS (Rot-TS)',
                                      3: 'Rotated speech Blesser (Rot-Blesser)',
                                      4:'Noise-vocoded speech (NV)',
                                      5: 'rotated noise-vocoded speech (NV-Rot)'})
# ----------------------------------------------------------------------------------------------------------------------
# test on first participant data: S01

# raw1 = read_hitachi('Data/S01/S01_MES_Probe1.csv')
# raw2 = read_hitachi('Data/S01/S01_MES_Probe2.csv')

raw1 = read_hitachi('Data/S11/S11_MES_Probe1.csv')
raw2 = read_hitachi('Data/S11/S11_MES_Probe2.csv')

channel_names1 = raw1.info.ch_names
channel_names2 = raw2.info.ch_names

# ----------------------------------------------------------------------------------------------------------------------
# set montage x,y,z coordinates Montage convert pos file using get_montage function


# raw1.set_montage(get_montage('Data/S01/probe1_channel_montage.csv'))
# raw2.set_montage(get_montage('Data/S01/probe2_channel_montage.csv'))

# montage1_1 = self_montage(file_path='Data/S01/0001.pos', csv_file='Data/S01/probe1_channel_montage.csv')
# montage34_1 = self_montage(file_path='Data/S34/0001.pos', csv_file='Data/S34/probe1_channel_montage.csv')
# montage34_2 = self_montage(file_path='Data/S34/0001.pos', csv_file='Data/S34/probe2_channel_montage.csv')
# montage34 = self_montage(file_path='Data/S34/0001.pos', csv_file='Data/S34/0001_edit.csv')
# montage33 = self_montage(file_path='Data/S33/0001.pos', csv_file='Data/S33/0001_edit.csv')
# montage11 = self_montage(file_path='Data/S11/0001.pos', csv_file='Data/S11/0001_edit.csv')
# raw2.set_montage(self_montage(file_path='Data/S01/0001.pos', csv_file= 'Data/S01/probe2_channel_montage.csv'))
# plot  1 - 22 sensors for left hemisphere
# fig1_1 = mne.viz.plot_montage(montage1_1, scale_factor=5, show_names=True, kind='topomap', sphere='auto', verbose=None)
# fig34_1 = mne.viz.plot_montage(montage34_1, scale_factor=5, show_names=True, kind='topomap', sphere='auto', verbose=None)
# mne.channels.compute_native_head_t(montage34)
# fig34 = mne.viz.plot_montage(montage34, scale_factor=20, show_names=True, kind='3d', sphere='auto') # return figure object (matplotlib.figure.Figure)
# fig34 = mne.viz.plot_montage(montage34, scale_factor=5, show_names=True, kind='3d')


# fig = return_montage(montage11).plot(kind='3d') #matpltlib.figure.Figure

# fig.gca().view_init(azim=-70, elev=20)

# fig.savefig('Data/S11/fig.png')  # save_in_file(S34,fig.png)

# raw1.set_montage(montage11_1,match_case=True,match_alias=True,on_missing='ignore')




montage11 = self_montage(file_path='Data/S11/0001.pos', csv_file='Data/S11/0001_edit.csv')

# left hemisphere (Probe 1)
montage11_1 = self_montage(file_path='Data/S11/0001.pos', csv_file='Data/S11/probe1_channel_montage.csv')
raw1.set_montage(montage11_1,match_case=True,match_alias=True,on_missing='ignore')

# right hemisphere (Probe 2)
montage11_2 = self_montage(file_path='Data/S11/0001.pos', csv_file='Data/S11/probe2_channel_montage.csv')

# mne.set_montage right hemisphere: raises Error - IndexError: index 44 is out of bounds for axis 0 with size 44
raw2.set_montage(montage11_2)


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



# mne.viz.plot_alignment((info=None, trans=None, subject=None,
# subjects_dir=None, surfaces='auto',
# coord_frame='auto', meg=None, eeg='original',
# fwd=None, dig=False, ecog=True,
# src=None, mri_fiducials=False, bem=None,
# seeg=True, fnirs=True, show_axes=False,
# dbs=True, fig=None, interaction='terrain', verbose=None)

# plot 23-44 channels for right hemisphere
# raw2.plot()

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


# event_dict = {'Sp': 1, 'Rot-TS': 2, 'Rot-Blesser': 3, 'NV': 4, 'NV-Rot': 5}
# fig = mne.viz.plot_events(events, event_id=event_dict, sfreq=raw1.info['sfreq'], first_samp=raw1.first_samp)
# ----------------------------------------------------------------------------------------------
# print(mne.pick_types(raw2.info, meg=False, eeg=False, fnirs=True, exclude=[]))

# ----------------------------------------------------------------------------------------------------------------------




