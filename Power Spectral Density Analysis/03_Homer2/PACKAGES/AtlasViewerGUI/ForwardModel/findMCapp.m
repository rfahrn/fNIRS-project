function fwmodel = findMCapp(fwmodel, argExtern)

if ~exist('argExtern','var')
    argExtern={};
end
mc_appnamelist = mcAppList();
dirnameApp = getAppDir();
if ispc()
    platform = 'Win';
elseif ismac()
    platform = 'Darwin';
else
    platform = 'Linux';
end


% Check external args for user supplied MC app root folder 
if length(argExtern)>2 & ~isempty(argExtern{3})
    mc_exepath = argExtern{3};
    [mc_exename, mc_appname, ext] = searchDirForMCApp(mc_exepath);
    if ~isempty(mc_exename)
        fwmodel.mc_rootpath = argExtern{3};
        fwmodel.mc_exepath = argExtern{3};
        fwmodel.mc_exename = mc_exename;
        fwmodel.mc_appname = mc_appname;
        fwmodel.mc_exename_ext = ext;
        return;
    end
end


% Check installation folder for MC app 
[mc_exename, mc_appname, ext] = searchDirForMCApp(dirnameApp);
if ~isempty(mc_exename)
    fwmodel.mc_rootpath = dirnameApp;
    fwmodel.mc_exepath = dirnameApp;
    fwmodel.mc_exename = mc_exename;
    fwmodel.mc_appname = mc_appname;
    fwmodel.mc_exename_ext = ext;
    return;
end


% Check Desktop for MC app dir instead of app itself
for ii=1:length(mc_appnamelist)
    mc_exepath = sprintf('%s/%s/bin/%s', dirnameApp, mc_appnamelist{ii}, platform);
    [mc_exename, mc_appname, ext] = searchDirForMCApp(mc_exepath);
    if ~isempty(mc_exename)
        fwmodel.mc_rootpath = mc_exepath;
        fwmodel.mc_exepath = mc_exepath;
        fwmodel.mc_exename = mc_exename;
        fwmodel.mc_appname = mc_appname;
        fwmodel.mc_exename_ext = ext;
        return;
    end
end


% Try to locate MC app root folder using matlab search paths
foos = which('Homer2_UI.m');
if ~isempty(foos)
    [pp,fs] = getpathparts(foos);
    foos = buildpathfrompathparts(pp(1:end-1),fs(1:end-1,:));    
    for ii=1:length(mc_appnamelist)
        mc_exepath = sprintf('%s/PACKAGES/%s/bin/%s', foos, mc_appnamelist{ii}, platform);
        [mc_exename, mc_appname, ext] = searchDirForMCApp(mc_exepath);
        if ~isempty(mc_exename)
            fwmodel.mc_rootpath = mc_exepath;
            fwmodel.mc_exepath = mc_exepath;
            fwmodel.mc_exename = mc_exename;
            fwmodel.mc_appname = mc_appname;
            fwmodel.mc_exename_ext = ext;
            return;
        end
    end
end
    
    
% Last resort: If none of the above locate MC app then ask user where it is. 
while 1
    pause(.1)
    [filenm, pathnm] = uigetfile({'*'; '*.exe'}, ['Monte Carlo executable not found. Please select Monte Carlo executable.']);
    if filenm==0
        fwmodel.mc_rootpath = '';
        fwmodel.mc_exepath = '';
        fwmodel.mc_appname = '';
        fwmodel.mc_exename = '';
        fwmodel.mc_exename_ext = '';
        fwmodel.mc_options = '';
        return;
    end
    
    % Do a few basic error checks
    if istextfile(filenm)
        q = menu('Selected file not an executable. Try again', 'OK', 'Cancel');
        if q==2
            return;
        else
            continue;
        end
    end    
    break;
end
[mc_exename, mc_appname, ext] = searchDirForMCApp(pathnm);
if ~isempty(mc_exename)
    fwmodel.mc_rootpath = pathnm;
    fwmodel.mc_exepath = pathnm;
    fwmodel.mc_exename = mc_exename;
    fwmodel.mc_appname = mc_appname;
    fwmodel.mc_exename_ext = ext;
    return;
end


