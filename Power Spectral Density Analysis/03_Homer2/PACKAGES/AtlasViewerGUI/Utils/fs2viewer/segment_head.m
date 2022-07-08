function [hseg tiss_type] = segment_head(outer_skin_surf_fn, ...
                                         outer_skull_surf_fn, ...
                                         inner_skull_surf_fn, ...
                                         head_vol_fn, ...
                                         csf_vol_fn, ...
                                         gm_vol_fn, ...
                                         wm_vol_fn)
                                            
%
% USAGE:
%
% [hseg tiss_type] = segment_head(outer_skin_surf_fn, ...
%                                 outer_skull_surf_fn, ...
%                                 inner_skull_surf_fn, ...
%                                 head_vol_fn, ...
%                                 csf_vol_fn, ...
%                                 gm_vol_fn, ...
%                                 wm_vol_fn)
%
% 
% DESCRIPTION: 
%     
% This function loads volume and surface files and a tranformation matrix 
% file for head segmentation. It converts whatever surfaces are available 
% to volumes. The transformation matrix is needed if there are surfaces, 
% because the surfaces and volumes are in different coordinate spaces. 
% The volume files have a transformation that can be used by surfaces to 
% move into volume space. Once all the volumes are loaded the function 
% calls segment_head_vols.m to combine all the volumes into one segmented 
% volume of the head. 
%
% 
% INPUTS:
%
% Names of the volume, surface and tranformation matrix files. 
%
%
% OUTPUTS:
% 
% Single volume containing segmentation of the head. 
%
%
% EXAMPLE 1: 
%
% The following is an example of segment_head usage with
% FreeSurfer-reconstructed MR image files. The files are stored under 
% the subject directory /autofs/space/monte_012/users/jdubb/workspaces \
% /subjects/mind006. In this case the head and csf volume files aren't 
% needed because outer_skin and inner_skull surfaces are available 
% for this subject recontructed ME Flash dicoms. These surfaces will be  
% converted to head and csf volumes and are better than using the 
% MPRAGE-based T1 and brain volumes directly. 
%
% cd '/autofs/space/monte_012/users/jdubb/workspaces/subjects/mind006' 
% [hseg] = segment_head('./bem/flash/outer_skin.tri', ...
%                       './bem/flash/outer_skull.tri', ...
%                       './bem/flash/inner_skull.tri', ...
%                       [], ...
%                       [], ...
%                       './mri/aseg.nii', ...
%                       './mri/wm.nii');
% EXAMPLE 2:
%
% cd '/autofs/space/monte_012/users/jdubb/workspaces/subjects/mind006' 
% hseg = segment_head([], [], [], './mri/T1_headonly.nii', ...
%                     './mri/brain.nii', './mri/aseg.nii', 'mri/wm.nii');
%
%
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   12/18/2012
%  

vox2ras = eye(4);

%%%% Open T1 properties file produced by mri_info
% Load volumes 
if(~isempty(head_vol_fn))
    headnii = load_untouch_nii(head_vol_fn);
    dims    = headnii.hdr.dime.dim(2:4);
    head    = headnii.img;
    vox2ras = get_nii_vox2ras(headnii);
else
    head = [];
end

if(~isempty(csf_vol_fn))
    csfnii = load_untouch_nii(csf_vol_fn);
    dims = csfnii.hdr.dime.dim(2:4);
    csf = csfnii.img;
    vox2ras = get_nii_vox2ras(csfnii);
else
    csf = [];
end

if(~isempty(gm_vol_fn))
    gmnii = load_untouch_nii(gm_vol_fn);
    dims = gmnii.hdr.dime.dim(2:4);
    gm = gmnii.img;
    vox2ras = get_nii_vox2ras(gmnii);
else
    gm = [];
end

if(~isempty(wm_vol_fn))
    wmnii = load_untouch_nii(wm_vol_fn);
    dims = wmnii.hdr.dime.dim(2:4);
    wm = wmnii.img;
    vox2ras = get_nii_vox2ras(wmnii);
else
    wm = [];
end

if(~isempty(outer_skin_surf_fn))
    head = surf_file2vol(outer_skin_surf_fn, dims, inv(vox2ras));
end

if(~isempty(outer_skull_surf_fn))
    outer_skull = surf_file2vol(outer_skull_surf_fn, dims, inv(vox2ras));
else
    outer_skull = [];
end

if(~isempty(inner_skull_surf_fn))
    csf = surf_file2vol(inner_skull_surf_fn, dims, inv(vox2ras));
end

[hseg tiss_type] = segment_head_vols(head, outer_skull, csf, gm, wm);
