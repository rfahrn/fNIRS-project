function [fs2viewer, status] = fs2pialsurf(fs2viewer, dirname)

status = 1;

if ~exist('dirname','var')
    dirname='./';
elseif dirname(end)~='/' && dirname(end)~='\'
    dirname(end+1)='/';
end

noder=[];
nodel=[];
elemr=[];
eleml=[];
if (~exist([dirname 'surf/rh.pial_resampled'],'file') || ...
    ~exist([dirname 'surf/lh.pial_resampled'],'file')) && ...
   (exist([dirname 'surf/rh.pial'],'file') && ...
    exist([dirname 'surf/lh.pial'],'file'))
    
    h = waitbar(0,'Downsampling brain surface. This may take a few minutes...');
    [nodeorigr,elemorigr] = read_surf([dirname 'surf/rh.pial']);
    [noder,elemr] = meshresample(nodeorigr,elemorigr,0.15);

    [nodeorigl,elemorigl] = read_surf([dirname 'surf/lh.pial']);
    [nodel,eleml] = meshresample(nodeorigl,elemorigl,0.15);
    close(h);

    write_surf([dirname 'surf/rh.pial_resampled'], noder, elemr);
    write_surf([dirname 'surf/lh.pial_resampled'], nodel, eleml);

elseif exist([dirname 'surf/rh.pial_resampled'],'file') && ...
       exist([dirname 'surf/lh.pial_resampled'],'file')

    [noder,elemr] = read_surf([dirname 'surf/rh.pial_resampled']);
    [nodel,eleml] = read_surf([dirname 'surf/lh.pial_resampled']);

end

if isempty(noder) | isempty(nodel) | isempty(elemr) | isempty(eleml)
    return;
end

nnoder = size(noder,1);
node = [noder ; nodel];
elem = [elemr ; eleml+nnoder];

if ~exist([dirname 'anatomical'], 'dir')
    mkdir([dirname 'anatomical']);
end

write_surf([dirname 'anatomical/pialsurf.mesh'], node, elem);

if ~exist([dirname 'vox2ras.txt'],'file')
    if islinux()
        cmd = sprintf('mri_info --vox2ras-tkr %s/mri/T1.nii > %s/vox2ras.txt', dirname, dirname);        
        system(cmd);
    end
end

if exist([dirname 'vox2ras.txt'],'file')
    pialsurf2vol = inv(load([dirname 'vox2ras.txt']));
    save([dirname 'anatomical/pialsurf2vol.txt'],'-ascii','pialsurf2vol');    
else
    if exist([dirname 'mri/hseg.nii'],'file')
        volnii = load_untouch_nii([dirname 'mri/hseg.nii']);
    elseif exist([dirname 'mri/T1.nii'],'file')
        volnii = load_untouch_nii([dirname 'mri/T1.nii']);
    end
    vox2ras = get_nii_vox2ras(volnii);
    pialsurf2vol = inv([vox2ras; 0 0 0 1]);
    save([dirname 'anatomical/pialsurf2vol.txt'],'-ascii','pialsurf2vol');
end
status = 0;

