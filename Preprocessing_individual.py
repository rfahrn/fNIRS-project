
# Author: Rebecka Fahrni, 18-735-522
# Project: fNIRS data analysis
# using MNE-python https://mne.tools/stable/index.html
# -----------------------------------------------------------------------------
import sys
sys.path.append('C:/Users/rebec/fNIRS-project/manuel_montage.py')
import manuel_montage
import numpy as np
import matplotlib.pyplot as plt
from itertools import compress
import mne

# Preprocessing of fNIRS - Individual analysis
# -----------------------------------------------------------------------------


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
                                         hsp=hsp, hpi=None, coord_frame='mri')

# clean events - double triggers
def clean_events(events_numpy):
    """
    removes double triggering after found events
    :param events_numpy: events array that should be cleaned
    :return cleaned event array"""
    a = events_numpy
    ids = [0,]
    consecutives = 0
    for i in range(1, len(a)):
        if a[i,-1]!=a[i-1,-1]:
            consecutives=0
        else:
            consecutives+=1
        if consecutives%2==0:
            ids.append(i)
    return a[ids]

def get_plots(list_part):
    for participant in list_part:
        file_path = "C:/Users/rebec/fNIRS-project/Data/S" + str(participant) +'/S' + str(participant) +'_raw.fif'
        pos_file_path_1 = 'C:/Users/rebec/fNIRS-project/Data/S' + str(participant) +'/S' + str(participant) + '_MES_Probe1.csv'
        pos_file_path_2 = 'C:/Users/rebec/fNIRS-project/Data/S' + str(participant) +'/S' + str(participant) + '_MES_Probe2.csv'
        montage_path_csv = 'C:/Users/rebec/fNIRS-project/Data/S' + str(participant) + '/0001_edit.csv'
        montage_path_pos = 'C:/Users/rebec/fNIRS-project/Data/S' + str(participant) +'/0001.pos'
        montage_save_3d = 'C:/Users/rebec/fNIRS-project/Data/S' + str(participant) +'/montage_3d.png'
        montage_save = 'C:/Users/rebec/fNIRS-project/Data/S' + str(participant) +'/montage_top.png'
        save_plots =  'C:/Users/rebec/fNIRS-project/Plots/s_' + str(participant)
        raw = read_hitachi([pos_file_path_1, pos_file_path_2])
        montage = self_montage(file_path=montage_path_pos, csv_file=montage_path_csv) 
        raw.set_montage(montage)
        
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
        
        
        # Selecting channels appropriate for detecting neural responses:
        # remove channels that are too close together (short channels) to detect a
        # neural response (less than 1 cm distance between optodes).
        picks = mne.pick_types(raw.info, meg=False, fnirs=True)
        dists = mne.preprocessing.nirs.source_detector_distances(
            raw.info,
            picks=picks)
        
        raw.pick(picks[dists > 0.01])
        #raw.plot(n_channels=len(raw.ch_names), duration=2000, show_scrollbars=False)
        
        
        
        # Converting raw intensity to optical density
        raw_od = mne.preprocessing.nirs.optical_density(raw)
        #raw_od.plot(n_channels=len(raw_od.ch_names),
        #            duration=2000, show_scrollbars=False)
        
        # -----------------------------------------------------------------------------
        # Evaluating the quality of the data - Scalp Coupling Index (SCI)
        
        # SCI: This method looks for the presence of a prominent synchronous signal in
        # the frequency range of cardiac signals across both photodetected signals
        
        sci = mne.preprocessing.nirs.scalp_coupling_index(raw_od)
        #fig, ax = plt.subplots()
        #ax.hist(sci)
        #ax.set(xlabel='Scalp Coupling Index', ylabel='Count', xlim=[0, 1])
        
        # set SCI less than 0.5 as bad channel!
        raw_od.info['bads'] = list(compress(raw_od.ch_names, sci < 0.5))
        
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
        
        #fig = raw_haemo.plot_psd(average=True)
        #fig.suptitle('Before filtering', weight='bold', size='x-large')
        #fig.subplots_adjust(top=0.88)
        
        # filter out hear rate
        raw_haemo = raw_haemo.filter(l_freq=0.05, h_freq=0.7, h_trans_bandwidth=0.2,
                                     l_trans_bandwidth=0.02)
        
        # my_filter = raw_haemo.filter(l_freq=0.05, h_freq=0.7, h_trans_bandwidth=0.01, l_trans_bandwidth=0.5)   # in easynirsprocessopt - hpf 0.01
        
        #fig = raw_haemo.plot_psd(average=True)
        #fig.suptitle('After filtering', weight='bold', size='x-large')
        #fig.subplots_adjust(top=0.88)
        
        #fig2 = my_filter.plot_psd(average=True)
        #fig2.suptitle('After filtering', weight='bold', size='x-large')
        #fig2.subplots_adjust(top=0.88)
        
        # -----------------------------------------------------------------------------
        # Extract epochs
        
        # Now that the signal has been converted to relative haemoglobin concentration,
        #  and the unwanted heart rate component has been removed, we can extract epochs
        # related to each of the experimental conditions.
        # First we extract the events of interest / visualise them to ensure they are correct.
        
        events, event_dict = mne.events_from_annotations(raw_haemo)
        #fig = mne.viz.plot_events(events, event_id=event_dict,
        #                        sfreq=raw_haemo.info['sfreq'])
        #fig.subplots_adjust(right=0.7)  # make room for the legend
        
        # define range of epochs, rejection criteria, basline correction and extract epochs.
        # Visualize log of which epochs were dropped.
        
        reject_criteria = dict(hbo=80e-6)  # rejection criteria
        tmin, tmax = -8, 20
        
        epochs = mne.Epochs(raw_haemo, events, event_id=event_dict,
                            tmin=tmin, tmax=tmax,
                            reject=reject_criteria, reject_by_annotation=True,
                            proj=True, baseline=(tmin, 0), preload=True,
                            detrend=None, verbose=True)
        
        # epochs.plot_drop_log()
        
        # -----------------------------------------------------------------------------
        # View consistency of responses across trials
        
        # haemodynamic response for our tapping condition. We visualise the response
        # for both the oxy- and deoxyhaemoglobin, and observe the expected peak in
        # HbO at around 6 seconds consistently across trials, and the consistent dip in
        # HbR that is slightly delayed relative to the HbO peak.
        
        epochs['Sp'].plot_image(combine='mean', vmin=-30, vmax=30,
                                ts_args=dict(ylim=dict(hbo=[-15, 15],
                                                       hbr=[-15, 15])))
        
        epochs['Rot-TS'].plot_image(combine='mean', vmin=-30, vmax=30,
                                    ts_args=dict(ylim=dict(hbo=[-15, 15],
                                                           hbr=[-15, 15])))
        
        epochs['Rot-Blesser'].plot_image(combine='mean', vmin=-30, vmax=30,
                                         ts_args=dict(ylim=dict(hbo=[-15, 15],
                                                                hbr=[-15, 15])))
        epochs['NV'].plot_image(combine='mean', vmin=-30, vmax=30,
                                ts_args=dict(ylim=dict(hbo=[-15, 15],
                                                       hbr=[-15, 15])))
        epochs['NV-Rot'].plot_image(combine='mean', vmin=-30, vmax=30,
                                    ts_args=dict(ylim=dict(hbo=[-15, 15],
                                                           hbr=[-15, 15])))
        
        # -----------------------------------------------------------------------------
        # Plot standard fNIRS response image
        
        # generate the most common visualisation of fNIRS data: plotting both the
        # HbO and HbR on the same figure to illustrate the relation between the two signals.
        
        
        evoked_dict = {'Sp/HbO': epochs['Sp'].average(picks='hbo'),
                       'Sp/HbR': epochs['Sp'].average(picks='hbr'),
                       'Rot-TS/HbO': epochs['Rot-TS'].average(picks='hbo'),
                       'Rot-TS/HbR': epochs['Rot-TS'].average(picks='hbr'),
                       'Rot-Blesser/HbO': epochs['Rot-Blesser'].average(picks='hbo'),
                       'Rot-Blesser/HbR': epochs['Rot-Blesser'].average(picks='hbr'),
                       'NV-Rot/HbO': epochs['NV-Rot'].average(picks='hbo'),
                       'NV-Rot/HbR': epochs['NV-Rot'].average(picks='hbr'),
                       }
        # Rename channels until the encoding of frequency in ch_name is fixed
        for condition in evoked_dict:
            evoked_dict[condition].rename_channels(lambda x: x[:-4])
        
        color_dict = dict(HbO='#AA3377', HbR='b')
        styles_dict = dict(Control=dict(linestyle='dashed'))
        
        comp = mne.viz.plot_compare_evokeds(evoked_dict, combine="mean", ci=0.95,
                                     colors=color_dict, styles=None,show_sensors=True,title= str(participant))
        
        comp[0].savefig(save_plots)
        # -----------------------------------------------------------------------------
        # View topographic representation of activity
        
        # view how the topographic activity changes throughout the response
        times = np.arange(-3.5, 13.2, 3.0)
        topomap_args = dict(extrapolate='local')
        epochs['Sp'].average(picks='hbo').plot_joint(times=times,
                                                     topomap_args=topomap_args)
        
        # -----------------------------------------------------------------------------
        # Compare Sp and Rot-TS
        
        times = np.arange(4.0, 11.0, 1.0)
        epochs['Sp'].average(picks='hbo').plot_topomap(
            times=times, **topomap_args)
        epochs['Rot-TS'].average(picks='hbo').plot_topomap(
            times=times, **topomap_args)
        
        fig, axes = plt.subplots(nrows=2, ncols=4, figsize=(9, 5),
                                 gridspec_kw=dict(width_ratios=[1, 1, 1, 0.1]))
        vmin, vmax, ts = -8, 8, 9.0
        
        evoked_sp = epochs['Sp'].average()
        evoked_rot_ts = epochs['Rot-TS'].average()
        
        evoked_sp.plot_topomap(ch_type='hbo', times=ts, axes=axes[0, 0],
                               vmin=vmin, vmax=vmax, colorbar=False,
                               **topomap_args, image_interp='cubic')
        evoked_sp.plot_topomap(ch_type='hbr', times=ts, axes=axes[1, 0],
                               vmin=vmin, vmax=vmax, colorbar=False,
                               **topomap_args, image_interp='cubic')
        evoked_rot_ts.plot_topomap(ch_type='hbo', times=ts, axes=axes[0, 1],
                                   vmin=vmin, vmax=vmax, colorbar=False,
                                   **topomap_args, image_interp='cubic')
        evoked_rot_ts.plot_topomap(ch_type='hbr', times=ts, axes=axes[1, 1],
                                   vmin=vmin, vmax=vmax, colorbar=False,
                                   **topomap_args, image_interp='cubic')
        
        evoked_diff = mne.combine_evoked([evoked_sp, evoked_rot_ts], weights=[1, -1])
        
        evoked_diff.plot_topomap(ch_type='hbo', times=ts, axes=axes[0, 2:],
                                 vmin=vmin, vmax=vmax, colorbar=True,
                                 **topomap_args)
        evoked_diff.plot_topomap(ch_type='hbr', times=ts, axes=axes[1, 2:],
                                 vmin=vmin, vmax=vmax, colorbar=True,
                                 **topomap_args, image_interp='cubic')
        
        for column, condition in enumerate(
                ['Sp', 'Rot-TS', 'Sp/Rot-TS']):
            for row, chroma in enumerate(['HbO', 'HbR']):
                axes[row, column].set_title('{}: {}'.format(chroma, condition))
        fig.tight_layout()
        fig.savefig(save_plots + 'hbo_hbr')
        # -----------------------------------------------------------------------------
        # get individual waveforms that drive topographic plot:
        
        fig, axes = plt.subplots(nrows=1, ncols=1, figsize=(6, 4))
        mne.viz.plot_evoked_topo(epochs['Sp'].average(picks='hbo'), color='b',
                                 axes=axes, legend=False)
        mne.viz.plot_evoked_topo(epochs['Rot-TS'].average(picks='hbo'), color='r',
                                 axes=axes, legend=False)
        
        # Tidy the legend:
        leg_lines = [line for line in axes.lines if line.get_c() == 'b'][:1]
        leg_lines.append([line for line in axes.lines if line.get_c() == 'r'][0])
        fig.legend(leg_lines, ['Sp', 'Rot-TS'], loc='lower right')
        fig.savefig(save_plots + '_individual waveform_sp_rot_ts')
        # -----------------------------------------------------------------------------
        
        extrapolations = ['local', 'head', 'box']
        fig, axes = plt.subplots(figsize=(7.5, 4.5), nrows=2, ncols=3)
        
        # Here we look at channels, and use a custom head sphere to get all the
        # sensors to be well within the drawn head surface
        
        
        for axes_row, ch_type in zip(axes, ('hbo', 'hbr')):
            for ax, extr in zip(axes_row, extrapolations):
                evoked_sp.plot_topomap(0.1, ch_type=ch_type, size=2, extrapolate=extr,
                                       axes=ax, show=False, colorbar=False,
                                       sphere=(0., 0., 0., 0.09))
                ax.set_title('%s %s' % (ch_type.upper(), extr), fontsize=14)
        fig.tight_layout()
        
        evoked_sp.plot_topomap(0.1, ch_type='hbo', show_names=True, colorbar=False,
                               size=6, res=128, title='Speech response',
                               time_unit='s')
        plt.subplots_adjust(left=0.01, right=0.99, bottom=0.01, top=0.88)
        
        # -----------------------------------------------------------------------------
        # Animation
        """
        times = np.arange(0.05, 0.151, 0.01)
        fig, anim = evoked_sp.animate_topomap(
            times=times, ch_type='hbr', frame_rate=2, time_unit='s', blit=False)"""
        
list_par = ['01','04','05','07','08','09',11,12,16,17,18,30,31,32, 33,34,35,36,37] # problem 15 und 06


