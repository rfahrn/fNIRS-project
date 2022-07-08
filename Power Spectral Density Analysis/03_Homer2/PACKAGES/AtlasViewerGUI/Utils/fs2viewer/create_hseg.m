function [hsegnii tiss_type status] = create_hseg(subj, threshold)

% USAGE:
%
% hseg = create_hseg(subject)
%
% DESCRIPTION: 
%
% 
%
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   12/18/2012

status = 0;
hsegnii = struct('hdr',[]);
tiss_type = {};

% Get the segmentation volumes from freesurfer generated files
% this is the system-dependent part.
if exist('subj','var')
    current_dir = pwd;
    cd(subj);
end

status = gen_mri_nifti_files();
if status~=0    
    return;   
end

% If hseg already exists our job is done.
if(exist('./mri/hseg.nii','file'))
    hsegnii = load_untouch_nii('./mri/hseg.nii');
    hseg = hsegnii.img;
    tiss_type = get_tiss_prop('./mri/hseg_tiss_type.txt');
    save_bin('./mri/hseg.bin', hseg);
    if(exist('subj'))
        cd(current_dir);
    end
    return;
end


if(exist('./mri/T1_headonly.nii','file'))
    T1_fn = './mri/T1_headonly.nii';
elseif(exist('./mri/T1.nii','file'))
    T1 = load_untouch_nii('./mri/T1.nii');
    T1.img = isolatehead(T1.img, threshold);
    save_untouch_nii(T1,'./mri/T1_headonly.nii');
    T1_fn = './mri/T1_headonly.nii';
else
    if(exist('subj', 'file'))
        cd(current_dir);
    end
    return;
end

hsegnii = load_untouch_nii(T1_fn);
hsegnii.img = [];
hsegnii.fileprefix = './mri/hseg';

%%%% If bem surfaces created from Multi-Echo Flip Angle sequences
%%%% exist, then use them for segmentation
if((exist('./bem/flash/outer_skin.tri','file'))  & ...
   (exist('./bem/flash/outer_skull.tri','file')) & ...
   (exist('./bem/flash/inner_skull.tri','file')) & ...
   (exist('./mri/aseg.nii','file'))              & ...
   (exist('./mri/wm.nii','file')))

    outer_skin_surf_fn = './bem/flash/outer_skin.tri';
    outer_skull_surf_fn = './bem/flash/outer_skull.tri';
    inner_skull_surf_fn = './bem/flash/inner_skull.tri';
    head_vol_fn = [];
    csf_vol_fn = [];
    gm_vol_fn = './mri/aseg.nii';
    wm_vol_fn = './mri/wm.nii';

%%%% We can still do 5 layer segmentation without the skin surface 
%%%% by simply using one of the volumes of the head, T1, for instance,
%%%% but we still have to have the inner and outer skull surfaces. 
elseif((exist('./bem/flash/outer_skull.tri','file')) & ...
       (exist('./bem/flash/inner_skull.tri','file')) & ...
       (exist(T1_fn))                         & ...
       (exist('./mri/aseg.nii','file'))              & ...
       (exist('./mri/wm.nii','file')))              

    outer_skin_surf_fn = [];
    outer_skull_surf_fn = './bem/flash/outer_skull.tri';
    inner_skull_surf_fn = './bem/flash/inner_skull.tri';
    head_vol_fn = T1_fn;
    csf_vol_fn = [];
    gm_vol_fn = './mri/aseg.nii';
    wm_vol_fn = './mri/wm.nii';
                    
%%%% Otherwise use brain volume to get the inner skull surface and 
%%%% hence the csf. Then label skin and skull as other. 
elseif((exist(T1_fn,'file'))             & ...
       (exist('./mri/brain.nii','file')) & ...
       (exist('./mri/aseg.nii','file'))  & ...
       (exist('./mri/wm.nii','file')))                    

    outer_skin_surf_fn = [];
    outer_skull_surf_fn = [];
    inner_skull_surf_fn = [];
    head_vol_fn = T1_fn;
    csf_vol_fn = './mri/brain.nii';
    gm_vol_fn = './mri/aseg.nii';
    wm_vol_fn = './mri/wm.nii';
    
%%%% If brain.mgz isn't there or isn't adequate for csf
%%%% then do the simplest segmentation
elseif((exist(T1_fn,'file'))             & ...
       (exist('./mri/aseg.nii','file'))  & ...
       (exist('./mri/wm.nii','file')))

    outer_skin_surf_fn = [];
    outer_skull_surf_fn = [];
    inner_skull_surf_fn = [];
    head_vol_fn = T1_fn;
    csf_vol_fn = [];
    gm_vol_fn = './mri/aseg.nii';
    wm_vol_fn = './mri/wm.nii';

elseif(exist(T1_fn,'file'))

    outer_skin_surf_fn = [];
    outer_skull_surf_fn = [];
    inner_skull_surf_fn = [];
    head_vol_fn = T1_fn;
    csf_vol_fn = [];
    gm_vol_fn = [];
    wm_vol_fn = [];

end

% Create the segmentation volume
[hseg tiss_type] = segment_head(outer_skin_surf_fn, ...
                                outer_skull_surf_fn, ...
                                inner_skull_surf_fn, ...
                                head_vol_fn, ... 
                                csf_vol_fn, ...
                                gm_vol_fn, ...
                                wm_vol_fn);


%%%% Write the hseg volume to the hseg.bin file
hsegnii.img = hseg;
save_bin('./mri/hseg.bin', hsegnii.img);
save_untouch_nii(hsegnii,'./mri/hseg.nii');
save_tiss_type('./mri/hseg_tiss_type.txt', tiss_type);

if(exist('subj','file'))
    cd(current_dir);
end   
