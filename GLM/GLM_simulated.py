# GLM simulated

import os
import numpy as np
import matplotlib.pyplot as plt

import mne
import mne_nirs

from mne_nirs.experimental_design import make_first_level_design_matrix
from mne_nirs.statistics import run_glm
from mne_nirs.channels import (get_long_channels,
                               get_short_channels,
                               picks_pair_to_idx)

import mne
import mne_nirs
import matplotlib.pylab as plt
import numpy as np
from mne_nirs.experimental_design import make_first_level_design_matrix
from mne_nirs.statistics import run_glm
from nilearn.plotting import plot_design_matrix
np.random.seed(1)
from nilearn.plotting import plot_design_matrix
import sys
sys.path.append('C:/Users/rebec/fNIRS-project/manuel_montage.py')
sys.path.append('C:/Users/rebec/fNIRS-project/untitled0.py')
import manuel_montage,untitled0


raw = untitled0.read_hitachi(['Data/S11/S11_MES_Probe1.csv', 'Data/S11/S11_MES_Probe2.csv']).load_data()

# set Montage
montage11 = untitled0.self_montage(file_path='Data/S11/0001.pos', csv_file='Data/S11/0001_edit.csv')
raw.set_montage(montage11)


# read Events from Hitachi-Raw and create an annotation
events = mne.find_events(raw)
event_dict = {
    'Sp': 1,
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

raw_od = mne.preprocessing.nirs.optical_density(raw)
raw_haemo = mne.preprocessing.nirs.beer_lambert_law(raw_od, ppf=0.057)

# ------------------------------------------------------------------------------
# Simulate noise free NIRS dat

# First we simulate some noise free data. We simulate 5 minutes of data with a
# block design. The inter stimulus interval of the stimuli is uniformly selected
# between 15 and 45 seconds. The amplitude of the simulated signal is 4 uMol and
# the sample rate is 3 Hz. The simulated signal is plotted below.
sfreq = 3.
amp = 4.

raw = mne_nirs.simulation.simulate_nirs_raw(
    sfreq=sfreq,
    sig_dur=60 * 5,
    amplitude=amp,
    isi_min=15.,
    isi_max=45.)

raw.plot(duration=300, show_scrollbars=False)
# -----------------------------------------------------------------------------
# create design matrix

design_matrix = make_first_level_design_matrix(raw,
                                               stim_dur=5.0,
                                               drift_order=1,
                                               drift_model='polynomial')
fig, ax1 = plt.subplots(figsize=(10, 6), nrows=1, ncols=1)
fig = plot_design_matrix(design_matrix, ax=ax1)

# -----------------------------------------------------------------------------
# estimate response on clean data
glm_est = run_glm(raw, design_matrix)


def print_results(glm_est, truth):
    """Function to print the results of GLM estimate"""
    print("Estimate:", glm_est.theta()[0][0],
          "  MSE:", glm_est.MSE()[0],
          "  Error (uM):", 1e6*(glm_est.theta()[0][0] - truth * 1e-6))


print_results(glm_est, amp)
# ------------------------------------------------------------------------------
# simulate noisy nirs data

# First take a copy of noise free data for comparison
raw_noise_free = raw.copy()

raw._data += np.random.normal(0, np.sqrt(1e-11), raw._data.shape)
glm_est = run_glm(raw, design_matrix)

plt.plot(raw.times, raw_noise_free.get_data().T * 1e6)
plt.plot(raw.times, raw.get_data().T * 1e6, alpha=0.3)
plt.plot(raw.times, glm_est.theta()[0][0] * design_matrix["Sp"].values * 1e6)
plt.xlabel("Time (s)")
plt.ylabel("Haemoglobin (uM)")
plt.legend(["Clean Data", "Noisy Data", "GLM Estimate"])

print_results(glm_est, amp)
