# iterate and generate raw.fif
import sys
sys.path.append(r'C:/Users/rebec/fNIRS-project/manuel_montage.py') 
sys.path.append(r'C:/Users/rebec/fNIRS-project/èreprocessing_individual.py') 
import  Preprocessing_individual
import mne
import mne_bids
import mne_nirs
import numpy as np


def gen_fif(list_participants):
    for participant in list_participants:
        file_path = "C:/Users/rebec/fNIRS-project/Data/S" + str(participant) +'/FIF_' + str(participant) +'_raw.fif'
        pos_file_path_1 = 'C:/Users/rebec/fNIRS-project/Data/S' + str(participant) +'/S' + str(participant) + '_MES_Probe1.csv'
        pos_file_path_2 = 'C:/Users/rebec/fNIRS-project/Data/S' + str(participant) +'/S' + str(participant) + '_MES_Probe2.csv'
        montage_path_csv = 'C:/Users/rebec/fNIRS-project/Data/S' + str(participant) + '/0001_edit.csv'
        montage_path_pos = 'C:/Users/rebec/fNIRS-project/Data/S' + str(participant) +'/0001.pos'
        montage_save_3d = 'C:/Users/rebec/fNIRS-project/Data/S' + str(participant) +'/montage_3d.png'
        montage_save = 'C:/Users/rebec/fNIRS-project/Data/S' + str(participant) +'/montage_top.png'
        raw = Preprocessing_individual.read_hitachi([pos_file_path_1, pos_file_path_2])
        raw.save(file_path)
        """
        montage = Preprocessing_individual.self_montage(file_path=montage_path_pos, csv_file=montage_path_csv) 
        fig_3d = mne.viz.plot_montage(montage,show_names=True,sphere='auto',kind='3d')
        fig_ = mne.viz.plot_montage(montage,show_names=True,sphere='auto',kind='topomap')
        #fig_.savefig(montage_save)
        #fig_3d.savefig(montage_save_3d)
        raw.set_montage(montage)
        
        # load Data
        raw.load_data()

        # read Events from Hitachi-Raw and create an annotation
        events = mne.find_events(raw)
        events = Preprocessing_individual.clean_events(events) # get rid of double triggers 

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
        raw.annotations.set_durations(mapping = {'Sp': 20,
                      'Rot-TS': 20,
                      'Rot-Blesser': 20,
                      'NV': 20,
                      'NV-Rot': 20})
        raw.annotations.set_durations(20)
        # raw.plot(start=5, duration=2000)
        raw.save(file_path,overwrite=True)
        
        fig = mne.viz.plot_montage(montage, scale_factor=20, show_names=True, kind='3d', show=True, sphere='auto')
        
        picks = mne.pick_types(raw.info, meg=False, fnirs=True)

        dists = mne.preprocessing.nirs.source_detector_distances(raw.info, picks=picks)
        raw.pick(picks[dists > 0.01])
        
        raw_od = mne.preprocessing.nirs.optical_density(raw)
        raw_haemo = mne.preprocessing.nirs.beer_lambert_law(raw_od, ppf=0.057)
        
        
        #raw.plot(n_channels=len(raw.ch_names), duration=5000, show_scrollbars=False)
        
        mne.datasets.fetch_fsaverage(subjects_dir=None, verbose=True)
        brain = mne.viz.Brain('fsaverage', subjects_dir=None, background='black', cortex='0.7',title= 'montage of participant '+ str(participant),surf='pial')
        #brain.add_sensors(raw.info, trans='fsaverage', fnirs=['channels', 'pairs', 'sources', 'detectors'])
        brain.add_sensors(raw.info, trans='fsaverage', fnirs=['channels'])
        brain.add_annotation('aparc.a2009s', borders=False)
        brain.show_view(azimuth=20, elevation=90, distance=800)
        # brain.save_image('C:/Users/rebec/fNIRS-project/Data/S'+ str(participant) +'/sensors.png')
           
        #plot_kwargs = dict(subjects_dir=None,
        #           surfaces="brain", dig=True, eeg=[],
        #           fnirs=['sources', 'detectors'], show_axes=True,
        #           coord_frame='head', mri_fiducials=True)



        coreg = mne.coreg.Coregistration(raw.info, "fsaverage", subjects_dir=None, fiducials="estimated")
        coreg.fit_fiducials(lpa_weight=1., nasion_weight=1., rpa_weight=1.)
        
        brain = mne.viz.Brain('fsaverage', subjects_dir=None, background='black', cortex='0.7', title= 'montage of participant '+ str(participant),surf='pial')
        brain.add_sensors(raw.info, trans=coreg.trans, fnirs=['channels', 'pairs', 'sources', 'detectors'])
        brain.add_annotation('aparc.a2009s', borders=False)
        brain.show_view(azimuth=20, elevation=90, distance=500)
        brain.save_image('C:/Users/rebec/fNIRS-project/Data/S'+ str(participant) +'/sensors.png')
        
        view_map = {
            'left-lat': np.r_[np.arange(6, 22), 28],
            'caudal': np.r_[27, np.arange(43, 44)],
            'right-lat': np.r_[np.arange(33, 43), 44],
        }
        
        fig_montage = mne_nirs.visualisation.plot_3d_montage(
            raw.info, view_map=view_map, subjects_dir=None)
        subjects_dir = str(mne.datasets.sample.data_path()) + '/subjects'
        mne.datasets.fetch_hcp_mmp_parcellation(subjects_dir=subjects_dir, accept=True) # 'C:\Users\rebec\mne_data'
        labels = mne.read_labels_from_annot('fsaverage', 'HCPMMP1', 'lh', subjects_dir=subjects_dir)
        labels_combined = mne.read_labels_from_annot('fsaverage', 'HCPMMP1_combined', 'lh', subjects_dir=subjects_dir)
        brain = mne.viz.Brain('fsaverage', subjects_dir=None, background='w', cortex='0.5')
        brain.add_sensors(raw.info, trans='fsaverage', fnirs=['channels', 'pairs', 'sources', 'detectors'])
        
        aud_label = [label for label in labels if label.name == 'L_A1_ROI-lh'][0] #primary auditory cortex 'L_A4_ROI-lh' 'L_A5_ROI-lh' 'L_AAIC_ROI-lh', , 'L_AIP_ROI-lh'
        stg_label = [label for label in labels if label.name == 'L_STGa_ROI-lh'][0]
        audi_lable = [label for label in labels if label.name == 'L_AAIC_ROI-lh'][0] #'L_STSdp_ROI-lh' 'L_STSva_ROI-lh' 'L_STSvp_ROI-lh'
        borca_lable = [label for label in labels if label.name == 'L_IFSa_ROI-lh'][0]  # 'L_IFSa_ROI-lh' nferior frontal gyrus  'L_IFSp_ROI-lh', 'L_IFJp_ROI-lh'  'L_IFJa_ROI-lh' 
        aud_2_label =  aud_label = [label for label in labels if label.name == 'L_A5_ROI-lh'][0]
        aud_label = [label for label in labels if label.name == 'L_A1_ROI-lh'][0]
        #  'L_TPOJ1_ROI-lh' 'L_TPOJ2_ROI-lh'  'L_V2_ROI-lh'
        
        
        l = [label for label in labels if label.name]
        print(l)
        brain.add_label(aud_label, borders=False, color='blue')
        brain.add_label(stg_label, borders=False, color='red')
        brain.add_label(borca_lable, borders=False, color='green')
        brain.add_label(aud_2_label, borders=False, color='yellow')
        brain.add_label(audi_lable, borders=False, color='pink')
        brain.show_view(azimuth=180, elevation=80, distance=450)
        
        # Plot the projection and sensor locations
        #brain = mne_nirs.plot_glm_surface_projection(raw_haemo.copy().pick("hbo"), model_df, colorbar=True)
        # brain.add_sensors(raw_haemo.info, trans='fsaverage', fnirs=['channels', 'pairs', 'sources', 'detectors'])
        
        # mark the premotor cortex in green
        #aud_label = [label for label in labels_combined if label.name == 'Premotor Cortex-lh'][0]
        #brain.add_label(aud_label, borders=True, color='green')
        
        # mark the auditory association cortex in blue
        #aud_label = [label for label in labels_combined if label.name == 'Auditory Association Cortex-lh'][0]
        #brain.add_label(aud_label, borders=True, color='blue')
        
        #brain.show_view(azimuth=160, elevation=60, distance=400)
        mne_nirs.io.write_raw_snirf(raw, 'C:/Users/rebec/fNIRS-project/Data/S'+ str(participant) +"raw.snirf")
        
        mtg = raw.get_montage()
        mtg.apply_trans(coreg.trans)
        raw.set_montage(mtg)
        raw_haemo.save(file_path,overwrite=True) # write fif
        mne_nirs.io.write_raw_snirf(raw, 'C:/Users/rebec/fNIRS-project/Data/S'+ str(participant) +"raw_coregistered_to_fsaverage.snirf")
        
        raw_obj = mne.io.read_raw_fif(file_path)
        root = r'C:\Users\rebec\fNIRS-project\Data\BIDS_1'
        bids_path = mne_bids.BIDSPath(subject=str(participant), task='intelligible speech',datatype="nirs", suffix="nirs", 
        description = 'uncleaned', extension=".snirf" ,root=root)
        """

        
list_par = ['01','04','05','07','08','09',11,12,16,17,18,30,31,32, 33,34,35,36,37] # problem 15 und 06

