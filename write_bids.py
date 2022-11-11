
# Import common libraries
import numpy as np
import pandas as pd
import mne_bids
# Import MNE processing
from mne.preprocessing.nirs import optical_density, beer_lambert_law
import mne
# Import MNE-NIRS processing
from mne_nirs.statistics import run_glm
from mne_nirs.experimental_design import make_first_level_design_matrix
from mne_nirs.statistics import statsmodels_to_results
from mne_nirs.channels import get_short_channels, get_long_channels
from mne_nirs.channels import picks_pair_to_idx
from mne_nirs.visualisation import plot_glm_group_topo
from mne_nirs.datasets import fnirs_motor_group
from mne_nirs.visualisation import plot_glm_surface_projection
from mne_nirs.io.fold import fold_channel_specificity

# Import MNE-BIDS processing
from mne_bids import BIDSPath, read_raw_bids, get_entity_vals

# Import StatsModels
import statsmodels.formula.api as smf

# Import Plotting Library
import matplotlib.pyplot as plt
import matplotlib as mpl
import seaborn as sns

def write_bids(participant_list):
    root = "C:/Users/rebec/fNIRS-project/Data/BIDS"
    for part in participant_list:
        raw_snirf_path = 'C:/Users/rebec/fNIRS-project/Data/SNIRF/S'+ str(part) +"raw_coregistered_to_fsaverage.snirf"
        raw_fif_path = 'C:/Users/rebec/fNIRS-project/Data/FIF/S'+str(part)+'_raw.fif'
        raw_obj = mne.io.read_raw_snirf(raw_snirf_path)
        #raw_obj = mne.io.read_raw_fif(raw_fif_path)
        bids_path = BIDSPath(subject=str(part),task='intelligible speech',
                     root=root)
        mne_bids.write_raw_bids(raw_obj,bids_path,overwrite=True)
        
list_par = ['01','04','05','07','08','09',11,12,16,17,18,30,31,32,33,34,35,36,37] #excluded 06,15
write_bids(list_par)
root = "C:/Users/rebec/fNIRS-project/Data/BIDS"
subjects = get_entity_vals(root,'subject')
print(subjects) # gives: ['01', '04', '05', '07', '08', '09', '11', '12', '16', '17', '18', '30', '31', '32', '33', '34', '35', '36', '37']  


def individual_analysis(bids_path, ID):

    raw_intensity = read_raw_bids(bids_path=bids_path, verbose=False)
    # Delete annotation labeled 15, as these just signify the start and end of experiment.
    # raw_intensity.annotations.delete(raw_intensity.annotations.description == '15.0')
    # sanitize event names
    raw_intensity.data_load()
    #raw_intensity.annotations.description[:] = [
    #    d.replace('/', '_') for d in raw_intensity.annotations.description]

    # Convert signal to haemoglobin and resample
    raw_od = optical_density(raw_intensity)
    raw_haemo = beer_lambert_law(raw_od, ppf=0.1)
    raw_haemo.resample(0.3)


    # Create a design matrix
    design_matrix = make_first_level_design_matrix(raw_haemo, stim_dur=20.0)

    # Run GLM
    glm_est = run_glm(raw_haemo, design_matrix)

    # Extract channel metrics
    cha = glm_est.to_dataframe()

    # Compute region of interest results from channel data

    # Define left vs right tapping contrast
    contrast_matrix = np.eye(design_matrix.shape[1])
    basic_conts = dict([(column, contrast_matrix[i])
                        for i, column in enumerate(design_matrix.columns)])
    contrast_4 = basic_conts['Rot-TS'] - basic_conts['Rot-Blesser']

    # Compute defined contrast
    contrast = glm_est.compute_contrast(contrast_4)
    con = contrast.to_dataframe()

    # Add the participant ID to the dataframes
    roi["ID"] = cha["ID"] = con["ID"] = ID

    # Convert to uM for nicer plotting below.
    cha["theta"] = [t * 1.e6 for t in cha["theta"]]
    roi["theta"] = [t * 1.e6 for t in roi["theta"]]
    con["effect"] = [t * 1.e6 for t in con["effect"]]

    return raw_haemo, roi, cha, con

df_roi = pd.DataFrame()  # To store region of interest results
df_cha = pd.DataFrame()  # To store channel level results
df_con = pd.DataFrame()  # To store channel level contrast results



for sub in subjects:  # Loop from first to fifth subject
    bids_path = BIDSPath(subject=sub,task='intelligible speech', root=root)
    
    
    # Analyse data and return both ROI and channel results
    raw_haemo, roi, channel, con = individual_analysis(bids_path, sub)
    
    # Append individual results to all participants
    df_roi = pd.concat([df_roi, roi], ignore_index=True)
    df_cha = pd.concat([df_cha, channel], ignore_index=True)
    df_con = pd.concat([df_con, con], ignore_index=True)

grp_results = df_roi.query("Condition in ['Control', 'Rot-TS', 'Rot-Blesser']")
grp_results = grp_results.query("Chroma in ['hbo']")

sns.catplot(x="Condition", y="theta", col="ID", hue="ROI", data=grp_results, col_wrap=5, ci=None, palette="muted", height=4, s=10)
