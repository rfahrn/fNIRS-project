function dirname = getAppDir(backward_compatible)

if ~exist('backward_compatible','var') | isempty(backward_compatible)
    backward_compatible = 0;
end


if ispc()
    dirname = 'c:/users/public/homer2/';
else
    currdir = pwd;
    cd ~/;
    dirnameHome = pwd;   
    dirname = [dirnameHome, '/homer2/'];
    cd(currdir);
end

if backward_compatible
    if ~exist(dirname, 'dir')
        dirname = getAppDirOld();
    elseif ~exist([dirname, 'Colin'], 'dir')
        dirname = getAppDirOld();
    end
end 

if dirname(end) ~= '/'
    if dirname(end) == '\'
        dirname(end) = '/';
    else
        dirname(end+1) = '/';
    end
end





% --------------------------------------------------------------------------
function dirname = getAppDirOld()

if ispc()
    dirname = 'c:/users/public';
else
    currdir = pwd;
    cd ~/;
    dirnameHome = pwd;   
    dirname = dirnameHome;
    cd(currdir);
end

if dirname(end) ~= '/'
    if dirname(end) == '\'
        dirname(end) = '/';
    else
        dirname(end+1) = '/';
    end
end






