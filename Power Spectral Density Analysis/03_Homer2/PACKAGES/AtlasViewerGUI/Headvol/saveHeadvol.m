function saveHeadvol(headvol, dirname, mode)

if isempty(headvol) | isempty(headvol.img)
    return;
end

if ~exist('dirname','var')  | isempty(dirname)
    dirname = [headvol.pathname, '/anatomical/'];
else
    if dirname(end)~='/' && dirname(end)~='\'
        dirname(end+1)='/';
    end
    dirname = [dirname, '/anatomical/'];    
end
if ~exist(dirname, 'dir')
    mkdir(dirname);
end
if ~exist('mode', 'var')
    mode='nooverwrite';
end

if ~exist([dirname, 'headvol.vox'], 'file') | strcmp(mode, 'overwrite')
    if ~isempty(headvol.imgOrig)
        headvol.img = headvol.imgOrig;
    else
        headvol.img = xform_apply_vol_smooth(headvol.img, inv(headvol.T_2mc));
    end
    save_vox([dirname, 'headvol.vox'], headvol);
end

