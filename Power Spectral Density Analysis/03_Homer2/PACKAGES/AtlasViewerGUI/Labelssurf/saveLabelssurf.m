function saveLabelssurf(labelssurf, dirname, mode)

if isempty(labelssurf) | isempty(labelssurf.mesh.vertices)
    return;
end

if ~exist('dirname','var') | isempty(dirname)
    dirname = [labelssurf.pathname, '/anatomical/'];
else
    if dirname(end)~='/' && dirname(end)~='\'
        dirname(end+1)='/';
    end
    dirname = [dirname, '/anatomical/'];    
end
if ~exist(dirname, 'dir')
    mkdir(dirname);
end
if ~exist('T_vol2mc','var') | isempty(T_vol2mc)
    T_vol2mc = eye(4);
end
if ~exist('mode', 'var')
    mode='nooverwrite';
end


if ~exist([dirname, 'labelssurf.mat'], 'file') | strcmp(mode, 'overwrite')
    aal_fv = labelssurf.meshes;
    aal_ll = labelssurf.names;

    % Right now aal_fv has only been transformed to volume therefore no
    % need to transform back using T_vol2mc
    for ii=1:length(aal_fv)
        if ~isempty(aal_fv{ii}.vertices)
            aal_fv{ii}.vertices = xform_apply(aal_fv{ii}.vertices, inv(labelssurf.T_2vol));
        end
    end
    
    save([dirname, 'labelssurf.mat'], 'aal_fv', 'aal_ll');
end

if ~exist([dirname, 'labelssurf2vol.txt'], 'file') | strcmp(mode, 'overwrite')
    T = labelssurf.T_2vol;
    save([dirname, 'labelssurf2vol.txt'], 'T','-ascii');
end

