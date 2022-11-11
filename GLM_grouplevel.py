# Author Rebecka Fahrni 
# GLM group level analysis - BIDS needed !!! -> should be created in plotting.py 

# Import common libraries
import numpy as np
import pandas as pd
import sys
sys.path.append('C:/Users/rebec/fNIRS-project/manuel_montage.py')
import manuel_montage
from itertools import compress

# Import MNE processing
from mne.preprocessing.nirs import optical_density, beer_lambert_law

# Import MNE-NIRS processing
from mne_nirs.statistics import run_glm
from mne_nirs.experimental_design import make_first_level_design_matrix
from mne_nirs.statistics import statsmodels_to_results
from mne_nirs.channels import get_short_channels, get_long_channels
from mne_nirs.channels import picks_pair_to_idx
from mne_nirs.visualisation import plot_glm_group_topo
from mne_nirs.visualisation import plot_glm_surface_projection
from mne_nirs.io.fold import fold_channel_specificity

# Import MNE-BIDS processing
from mne_bids import BIDSPath, write_raw_bids, read_raw_bids, get_entity_vals

# Import StatsModels
import statsmodels.formula.api as smf
# Import Plotting Library
import matplotlib.pyplot as plt
import matplotlib as mpl
import seaborn as sns
# Import MNE processing
from mne.viz import plot_compare_evokeds
from mne import Epochs, events_from_annotations, set_log_level
import json
from collections import defaultdict
import os.path as op
from pprint import pprint
import shutil
# Import MNE-NIRS processing
from mne_nirs.channels import get_long_channels
from mne_nirs.channels import picks_pair_to_idx
from mne_nirs.datasets import fnirs_motor_group
from mne.preprocessing.nirs import beer_lambert_law, optical_density,\
    temporal_derivative_distribution_repair, scalp_coupling_index
from mne_nirs.signal_enhancement import enhance_negative_correlation
import mne
from mne.datasets import sample
import Preprocessing_individual

from mne_bids import (write_raw_bids, read_raw_bids, write_meg_calibration,
                      write_meg_crosstalk, BIDSPath, print_dir_tree,
                      make_dataset_description)
from mne_bids.stats import count_events


# read raw to bids:
def get_raw(file_path, raw_path, bids_path, montage_path_pos, csv):
    write_raw_bids(raw, bids_path, events=None, event_id=None, anonymize=None,
                            format='auto', symlink=False, empty_room=None,
                            allow_preload=False, montage= False, acpc_aligned=False,
                            overwrite=True, events_data=None, verbose=None)


root = r'C:\Users\rebec\fNIRS-project\Data\BIDS'
print(root)

dataset = BIDSPath(root=root, task="speech",
                   datatype="nirs", suffix="nirs", 
                   description = 'uncleaned', extension=".csv")

print(dataset.directory)

def individual_analysis(bids_path, ID):

    raw_intensity = read_raw_bids(bids_path=bids_path, verbose=False)
    # Delete annotation labeled 15, as these just signify the start and end of experiment.
    raw_intensity.annotations.delete(raw_intensity.annotations.description == '15.0')
    # sanitize event names
    raw_intensity.annotations.description[:] = [
        d.replace('/', '_') for d in raw_intensity.annotations.description]

    # Convert signal to optical density and determine bad channels 
    raw_od = optical_density(raw_intensity)
    sci = scalp_coupling_index(raw_od, h_freq=1.35, h_trans_bandwidth=0.1)
    raw_od.info["bads"] = list(compress(raw_od.ch_names, sci < 0.5))
    raw_od.interpolate_bads()
    
    # Downsample and apply signal cleaning techniques
    raw_od.resample(0.8)
    raw_od = temporal_derivative_distribution_repair(raw_od)
    
    # convert to haemoglobin and filter
    raw_haemo = beer_lambert_law(raw_od, ppf=0.1) #ppf = .1 ok???
    raw_haemo = raw_haemo.filter(0.02, 0.3,
                             h_trans_bandwidth=0.1, l_trans_bandwidth=0.01,
                             verbose=False)
    
    # Cut out just the short channels for creating a GLM repressor
    # sht_chans = get_short_channels(raw_haemo)
    # raw_haemo = get_long_channels(raw_haemo)
    
    # apply further data cleaning techniques and extract epochs
    raw_haemo = enhance_negative_correlation(raw_haemo) 
    
    # Extract events
    events, event_dict = events_from_annotations(raw_haemo, verbose=False)
    
    epochs = Epochs(raw_haemo, events, event_id=event_dict, tmin=-5, tmax=20,
                    reject=dict(hbo=200e-6), reject_by_annotation=True,
                    proj=True, baseline=(None, 0), detrend=0,
                    preload=True, verbose=False)

    # Create a design matrix
    design_matrix = make_first_level_design_matrix(raw_haemo, stim_dur=5.0)

    # Run GLM
    glm_est = run_glm(raw_haemo, design_matrix)

    # Define channels in each region of interest
    # List the channel pairs manually
    left = [[4, 3], [1, 3], [3, 3], [1, 2], [2, 3], [1, 1]]
    right = [[8, 7], [5, 7], [7, 7], [5, 6], [6, 7], [5, 5]]
    # Then generate the correct indices for each pair
    groups = dict(
        Left_Hemisphere=picks_pair_to_idx(raw_haemo, left, on_missing='ignore'),
        Right_Hemisphere=picks_pair_to_idx(raw_haemo, right, on_missing='ignore'))

    # Extract channel metrics
    cha = glm_est.to_dataframe()

    # Compute region of interest results from channel data
    roi = glm_est.to_dataframe_region_of_interest(groups,
                                                  design_matrix.columns,
                                                  demographic_info=True)

    # Define left vs right tapping contrast
    contrast_matrix = np.eye(design_matrix.shape[1])
    basic_conts = dict([(column, contrast_matrix[i])
                        for i, column in enumerate(design_matrix.columns)])
    contrast_LvR = basic_conts['Tapping_Left'] - basic_conts['Tapping_Right']

    # Compute defined contrast
    contrast = glm_est.compute_contrast(contrast_LvR)
    con = contrast.to_dataframe()

    # Add the participant ID to the dataframes
    roi["ID"] = cha["ID"] = con["ID"] = ID

    # Convert to uM for nicer plotting below.
    cha["theta"] = [t * 1.e6 for t in cha["theta"]]
    roi["theta"] = [t * 1.e6 for t in roi["theta"]]
    con["effect"] = [t * 1.e6 for t in con["effect"]]

    return raw_haemo, epochs

#------------------------------------------------------------------------------------
# run alaysis on all data
all_evokeds = defaultdict(list)

for sub in range(1, 6):  # Loop from first to fifth subject

    # Create path to file based on experiment info
    # bids_path = BIDSPath(subject="%02d" % sub, task="tapping", datatype="nirs",
    #                     root=fnirs_motor_group.data_path(), suffix="nirs",
    #                     extension=".snirf")

    # Analyse data and return both ROI and channel results
    # raw_haemo, epochs = individual_analysis(bids_path, ID=sub)

    # Save individual-evoked participant data along with others in all_evokeds
    #for cidx, condition in enumerate(epochs.event_id):
    #    all_evokeds[condition].append(epochs[condition].average())
    pass


# --------------------------------------------------------------------------------
# view average waveform
# Specify the figure size and limits per chromophore
# fig, axes = plt.subplots(nrows=1, ncols=len(all_evokeds), figsize=(17, 5))
# lims = dict(hbo=[-5, 12], hbr=[-5, 12])
"""
for (pick, color) in zip(['hbo', 'hbr'], ['r', 'b']):
    for idx, evoked in enumerate(all_evokeds):
        plot_compare_evokeds({evoked: all_evokeds[evoked]}, combine='mean',
                             picks=pick, axes=axes[idx], show=False,
                             colors=[color], legend=False, ylim=lims, ci=0.95,
                             show_sensors=idx == 2)
        axes[idx].set_title('{}'.format(evoked))
axes[0].legend(["Oxyhaemoglobin", "Deoxyhaemoglobin"])
"""

#------------------------------------------------------------------------------
# Generate region of interest

# Specify channel pairs for each ROI
left = [[4, 3], [1, 3], [3, 3], [1, 2], [2, 3], [1, 1]]
right = [[8, 7], [5, 7], [7, 7], [5, 6], [6, 7], [5, 5]]

# Then generate the correct indices for each pair and store in dictionary
# rois = dict(Left_Hemisphere=picks_pair_to_idx(raw_haemo, left),
#            Right_Hemisphere=picks_pair_to_idx(raw_haemo, right))

# print(rois)

#------------------------------------------------------------------------------
# create average waveform per ROI (region of interest)
"""
# Specify the figure size and limits per chromophore.
fig, axes = plt.subplots(nrows=len(rois), ncols=len(all_evokeds),
                         figsize=(15, 6))
lims = dict(hbo=[-8, 16], hbr=[-8, 16])

for (pick, color) in zip(['hbo', 'hbr'], ['r', 'b']):
    for ridx, roi in enumerate(rois):
        for cidx, evoked in enumerate(all_evokeds):
            if pick == 'hbr':
                picks = rois[roi][1::2]  # Select only the hbr channels
            else:
                picks = rois[roi][0::2]  # Select only the hbo channels

            plot_compare_evokeds({evoked: all_evokeds[evoked]}, combine='mean',
                                 picks=picks, axes=axes[ridx, cidx],
                                 show=False, colors=[color], legend=False,
                                 ylim=lims, ci=0.95, show_sensors=cidx == 2)
            axes[ridx, cidx].set_title("")
        axes[0, cidx].set_title(f"{evoked}")
        axes[ridx, 0].set_ylabel(f"{roi}\nChromophore (ΔμMol)")
axes[0, 0].legend(["Oxyhaemoglobin", "Deoxyhaemoglobin"])
"""

#------------------------------------------------------------------------------
# extract evoked amplitude

"""
df = pd.DataFrame(columns=['ID', 'ROI', 'Chroma', 'Condition', 'Value'])

for idx, evoked in enumerate(all_evokeds):
    subj_id = 0
    for subj_data in all_evokeds[evoked]:
        subj_id += 1
        for roi in rois:
            for chroma in ["hbo", "hbr"]:
                data = deepcopy(subj_data).pick(picks=rois[roi]).pick(chroma)
                value = data.crop(tmin=5.0, tmax=7.0).data.mean() * 1.0e6

                # Append metadata and extracted feature to dataframe
                this_df = pd.DataFrame(
                    {'ID': subj_id, 'ROI': roi, 'Chroma': chroma,
                     'Condition': evoked, 'Value': value}, index=[0])
                df = pd.concat([df, this_df], ignore_index=True)
df.reset_index(inplace=True, drop=True)
df['Value'] = pd.to_numeric(df['Value'])  # some Pandas have this as object

# You can export the dataframe for analysis in your favorite stats program
df.to_csv("stats-export.csv")

# Print out the first entries in the dataframe
df.head()

# view individual results
sns.catplot(x="Condition", y="Value", hue="ID", data=df.query("Chroma == 'hbo'"), ci=None, palette="muted", height=4, s=10)


"""
#-------------------------------------------------------------------------------
# research queiton: comparison of conditions

"""
input_data = df.query("Condition in ['control', 'Tapping/Right']")
input_data = input_data.query("Chroma in ['hbo']")
input_data = input_data.query("ROI in ['Left_Hemisphere']")

roi_model = smf.mixedlm("Value ~ Condition", input_data,
                        groups=input_data["ID"]).fit()
roi_model.summary()

"""