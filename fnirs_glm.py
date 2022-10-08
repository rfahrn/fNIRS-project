# GLM - Measured fNIRS tutorial

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
from nilearn.plotting import plot_design_matrix
import sys
sys.path.append('C:/Users/rebec/fNIRS-project/manuel_montage.py') 
sys.path.append('C:/Users/rebec/fNIRS-project/untitled0.py') 
import manuel_montage, untitled0


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

# short_chs = get_short_channels(raw_haemo)
# raw_haemo = get_long_channels(raw_haemo)


# view experiment events
events, event_dict = mne.events_from_annotations(raw_haemo, verbose=False)
mne.viz.plot_events(events, event_id=event_dict, sfreq=raw_haemo.info['sfreq'])

# plot duration of event lasting - boxcar plot does
s = mne_nirs.experimental_design.create_boxcar(raw_haemo)
fig, axes = plt.subplots(nrows=1, ncols=1, figsize=(15, 6))
plt.plot(raw_haemo.times, s, axes=axes)
plt.legend(["Sp", "Rot-TS", "Rot-Blesser", "NV", "NV-Rot"], loc="upper right")
plt.xlabel("Time (s)")

# ------------------------------------------------------------------------------
# create design matrix

# We model the expected neural response for each experimental condition using 
# the SPM haemodynamic response function (HRF) combined with the known stimulus #
# event times and durations (as described above). We also include a cosine 
# drift model with components up to the high pass parameter value. See the 
# nilearn documentation for recommendations on setting these values. In short, 
# they suggest The cutoff period (1/high_pass) should be set as the longest 
# period between two trials of the same condition multiplied by 2. F
# or instance, if the longest period is 32s, the high_pass frequency shall be
#  1/64 Hz ~ 0.016 Hz”.

design_matrix = make_first_level_design_matrix(raw_haemo,
                                               drift_model='cosine',
                                               high_pass=0.01,  # Must be specified per experiment
                                               hrf_model='spm',
                                               stim_dur=20.0)
# add mean of the short channels to the design matrix. In theory these channels
# contain only systemic components. 
# design_matrix["ShortHbO"] = np.mean(short_chs.copy().pick(
#                                    picks="hbo").get_data(), axis=0)

# design_matrix["ShortHbR"] = np.mean(short_chs.copy().pick(
#                                    picks="hbr").get_data(), axis=0)

# using nilearn we diistplay a summary of the design matrix. The first three 
# columns represent the SPM HRF convolved with our stimulus event information
# The next columns illustrate the drift and constant components. The last
# column illustrate the short channel signals

fig, ax1 = plt.subplots(figsize=(10, 6), nrows=1, ncols=1)
fig = plot_design_matrix(design_matrix, ax=ax1)

# -----------------------------------------------------------------------------
# Examine expected response 

s = mne_nirs.experimental_design.create_boxcar(raw, stim_dur=5.0)
plt.plot(raw.times, s[:, 1])
plt.plot(design_matrix["Sp"])
plt.xlim(180, 2000)
plt.legend(["Stimulus", "Expected Response"])
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")

# -------------------------------------------------------------------------------
# Fit GLM to subset of data and estimate response for each experimental condition

data_subset = raw_haemo.copy().pick(picks=range(2))
glm_est = run_glm(data_subset, design_matrix)

# glm_est : returns GLM regression estimate for each channel. This data is stored in a dedicated type
print(glm_est)

glm_est.to_dataframe().head(9)

glm_est.scatter()

# fit GLM to all data and view topographic distribution
glm_est = run_glm(raw_haemo, design_matrix)
glm_est.plot_topo(conditions=[ "Rot-TS", "Rot-Blesser"])  # "Rot-TS", "Rot-Blesser","NV","NV-Rot"

fig, axes = plt.subplots(nrows=1, ncols=2, figsize=(10, 6), gridspec_kw=dict(width_ratios=[0.92, 1]))

#
glm_est.copy().surface_projection(condition="Sp", view="dorsal", chroma="hbo")
glm_hbo = glm_est.copy().pick(picks="hbo")

glm_hbo.plot_topo(axes=axes[0], colorbar=False, conditions=["Sp"])

glm_hbo.copy().pick(picks=range(10)).plot_topo(conditions=["Sp", "Rot-TS", "Rot-Blesser", "NV", "NV-Rot"],
                                               axes=axes[1],
                                               colorbar=False,
                                               vlim=(-16, 16))

glm_hbo.copy().pick(picks=range(10, 20)).plot_topo(conditions=["Sp", "Rot-TS", "Rot-Blesser", "NV", "NV-Rot"],
                                                   axes=axes[1],
                                                   colorbar=False,
                                                   vlim=(-16, 16))

axes[0].set_title("Smoothed across hemispheres")
axes[1].set_title("Hemispheres plotted independently")

# -----------------------------------------------------------------------------
# Analyse region of interest


left = [[1, 1], [1, 2], [1, 3], [2, 1], [2, 3],
        [2, 4], [3, 2], [3, 3], [4, 3], [4, 4]]
right = [[5, 5], [5, 6], [5, 7], [6, 5], [6, 7],
         [6, 8], [7, 6], [7, 7], [8, 7], [8, 8]]

groups = dict(Left_ROI=picks_pair_to_idx(raw_haemo, left),
              Right_ROI=picks_pair_to_idx(raw_haemo, right))

conditions = ["Sp", "Rot-TS", "Rot-Blesser", "NV", "NV-Rot"]

df = glm_est.to_dataframe_region_of_interest(groups, conditions)
print(df.head(6))

# ------------------------------------------------------------------------------
# Compute contrast 

# 1	Speech (Sp)
# 2	Rotated speech TS (Rot-TS)
# 3	Rotated speech Blesser (Rot-Blesser)
# 4	Noise-vocoded speech (NV)
# 5	Rotated noise-vocoded speech (NV-Rot)

# CONTRASTS USED in SCOTT EL Al. (2000)

# 1	Intelligible vs unintelligible speech:                    [(Sp + NV) – (Rot-Blesser + Rot-NV)]
# 2	Pitch perception with Blesser’s old rotation technique:   [(Sp + Rot-Blesser) – (NV + Rot-NV)]
# 3 Any type of phonetic information:                         [(Sp + NV + Rot-Blesser) – (NV-Rot)]

# NEW CONTRASTS
# 4	Comparing rotation techniques with different harmonic structure (TS Kurt vs Blesser):  [(Rot-TS) – (Rot-Blesser)]
# 5	Pitch perception with Kurt’s new rotation technique:                                   (Sp + Rot-TS) – (NV + Rot-NV)


contrast_matrix = np.eye(design_matrix.shape[1])
basic_conts = dict([(column, contrast_matrix[i])
                   for i, column in enumerate(design_matrix.columns)])

# 4 - New Contrast - TS Kurt vs. Blesser
contrast_LvR = basic_conts['Rot-TS'] - basic_conts['Rot-Blesser']
contrast = glm_est.compute_contrast(contrast_LvR)
contrast.plot_topo()
