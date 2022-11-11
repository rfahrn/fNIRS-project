


import mne
import mne_bids, mne_nirs
from Preprocessing_individual import clean_events,self_montage,read_hitachi
import matplotlib.pyplot as plt
from itertools import compress
import mne_bids

l = ['S1_D1 hbo', 'S1_D1 hbr']
def split_ch_type(lis):
    dic = {}
    for item in lis: 
        ch_name,ch_type = item, item.split()[1]
        dic[ch_name] = ch_type 
        return dic
    


def pro_individual(part):
    mes_1_csv = 'C:/Users/rebec/fNIRS-project/Data/S'+str(part)+'/S'+str(part)+'_MES_Probe1.csv'
    mes_2_csv = 'C:/Users/rebec/fNIRS-project/Data/S'+str(part)+'/S'+str(part)+'_MES_Probe2.csv'
    pos = 'C:/Users/rebec/fNIRS-project/Data/S'+str(part)+'/0001.pos'
    csv = 'C:/Users/rebec/fNIRS-project/Data/S'+str(part)+'/0001_edit.csv'
    save_fif = 'C:/Users/rebec/fNIRS-project/Data/FIF/S'+str(part)+'_raw.fif'
    snirf_path= r'C:/Users/rebec/fNIRS-project/Data/SNIRF/S'+ str(part) +'raw.snirf'
    raw = read_hitachi([mes_1_csv,mes_2_csv])
    montage =self_montage(pos, csv)
    
    # read Hitachi data
    raw = read_hitachi([mes_1_csv, mes_2_csv])
    
    # set Montage
    montage11 = self_montage(file_path=pos, csv_file=csv)
    raw.set_montage(montage11)
    
    
    # load Data
    raw.load_data()
    
    # read Events from Hitachi-Raw and create an annotation
    events = mne.find_events(raw)
    events = clean_events(events)
    
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
    #raw.plot(start=0.5, duration=2000)
    print(raw.info)
    
    # Selecting channels appropriate for detecting neural responses:
    # remove channels that are too close together (short channels) to detect a
    # neural response (less than 1 cm distance between op"todes").
    picks = mne.pick_types(raw.info, meg=False, fnirs=True)
    dists = mne.preprocessing.nirs.source_detector_distances(
        raw.info,
        picks=picks)
    
    raw.pick(picks[dists > 0.01])
    #raw.plot(n_channels=len(raw.ch_names), duration=2000, show_scrollbars=False)
    
    
    
    # Converting raw intensity to optical density
    raw_od = mne.preprocessing.nirs.optical_density(raw)
    raw_od.plot(n_channels=len(raw_od.ch_names),
                duration=2000, show_scrollbars=False)
    
    # -----------------------------------------------------------------------------
    # Evaluating the quality of the data - Scalp Coupling Index (SCI)
    
    # SCI: This method looks for the presence of a prominent synchronous signal in
    # the frequency range of cardiac signals across both photodetected signals
    
    sci = mne.preprocessing.nirs.scalp_coupling_index(raw_od)
    fig, ax = plt.subplots()
    ax.hist(sci)
    ax.set(xlabel='Scalp Coupling Index', ylabel='Count', xlim=[0, 1])
    
    # set SCI less than 0.5 as bad channel!
    raw_od.info['bads'] = list(compress(raw_od.ch_names, sci < 0.75))
    
    #  Applies temporal derivative distribution repair (TDDR) to data [1]. This approach removes baseline shift and spike artifacts without the need for any user-supplied parameters.
    raw_od = mne.preprocessing.nirs.temporal_derivative_distribution_repair(raw_od)
    # -----------------------------------------------------------------------------
    # convert optical density data to haemoglobin concentration using modified Beer-Lambert law
    
    raw_haemo = mne.preprocessing.nirs.beer_lambert_law(raw_od, ppf=0.57)  # ppf - easynirs - ppf 6.3 5.7
    #raw_haemo.plot(n_channels=len(raw_haemo.ch_names),
    #              duration=2000, show_scrollbars=False)
    
    #epochs = mne.Epochs(raw, events, event_id, tmin, tmax)
    tmin,tmax =-8,20
    epochs = mne.Epochs(raw_haemo, events, tmin=tmin, tmax=tmax, 
                        event_id=event_dict,proj=True,baseline=(tmin,0),
                        preload=True, verbose=True)
    
    
    # -----------------------------------------------------------------------------
    # Removing heart rate from signal
    
    # The haemodynamic response has frequency content predominantly below 0.5 Hz.
    # An increase in activity around 1 Hz can be seen in the data that is due to
    # the person’s heart beat and is unwanted. So we use a low pass filter to
    # remove this. A high pass filter is also included to remove slow drifts in the data.
    
    fig = raw_haemo.plot_psd(average=True)
    fig.suptitle('Before filtering', weight='bold', size='x-large')
    fig.subplots_adjust(top=0.88)
    
    raw_haemo = raw_haemo.filter(l_freq=0.05, h_freq=0.7, h_trans_bandwidth=0.2,l_trans_bandwidth=0.02)

    fig = raw_haemo.plot_psd(average=True)
    fig.suptitle('After filtering', weight='bold', size='x-large')
    fig.subplots_adjust(top=0.88)
    # -----------------------------------------------------------------------------
    # Extract epochs
    
    # Now that the signal has been converted to relative haemoglobin concentration,
    #  and the unwanted heart rate component has been removed, we can extract epochs
    # related to each of the experimental conditions.
    # First we extract the events of interest / visualise them to ensure they are correct.
    
    events, event_dict = mne.events_from_annotations(raw_haemo)
    fig = mne.viz.plot_events(events, event_id=event_dict,
                            sfreq=raw_haemo.info['sfreq'])
    fig.subplots_adjust(right=0.7)  # make room for the legend
    
    # define range of epochs, rejection criteria, basline correction and extract epochs.
    # Visualize log of which epochs were dropped.
    
    reject_criteria = dict(hbo=80e-6)  # rejection criteria
    tmin, tmax = -8, 20
    
    
    epochs = mne.Epochs(raw_haemo, events, event_id=event_dict,
                        tmin=tmin, tmax=tmax,
                        reject=reject_criteria, reject_by_annotation=True,
                        proj=True, baseline=(tmin, 0), preload=True,
                        detrend=None, verbose=True)

    #raw_haemo.save(save_fif, overwrite=True)
    mne_nirs.io.write_raw_snirf(raw_haemo, snirf_path)
    
# list_par = ['01','04','05','07','08','09',11,12,16,17,18,30,31,32, 33,34,35,36,37] # problem 15 und 06
list_par = ['01']


"""
raw_obj = mne.io.read_raw_fif(raw_fif_path)
names = raw_obj.ch_names
raw_obj.set_channel_types(split_ch_type(names))
root = "C:/Users/rebec/fNIRS-project/Data/BIDS_from_fif"
bids_path = mne_bids.BIDSPath(subject='01',task='intelligible speech',root=root)
mne_bids.write_raw_bids(raw_obj,bids_path,overwrite=True)"""