function setup()

h = waitbar(0,'Installation Progress ...');
nSteps = 100;
iStep = 1;

if ismac()
    dirnameSrc = '~/Downloads/homer2_install/';
else
	dirnameSrc = [pwd, '/'];
end
dirnameDst = getAppDir();

% Uninstall
if exist(dirnameDst,'dir')
    rmdir(dirnameDst, 's');
end

platform = setplatformparams(dirnameSrc);

fprintf('Platform params:\n');
fprintf('  arch: %s\n', platform.arch);
fprintf('  mc_exe: %s\n', platform.mc_exe);
fprintf('  homer2_exe: %s\n', platform.homer2_exe{1});
fprintf('  atlasviewer_exe: %s\n', platform.atlasviewer_exe{1});
fprintf('  setup_exe: %s\n', platform.setup_exe{1});
fprintf('  setup_script: %s\n', platform.setup_script);
fprintf('  dirnameApp: %s\n', platform.dirnameApp);
fprintf('  mcrpath: %s\n', platform.mcrpath);
fprintf('  iso2meshmex: %s\n', platform.iso2meshmex{1});
fprintf('  iso2meshbin: %s\n\n', platform.iso2meshbin);

if ispc()
    cmd = sprintf('IF EXIST %%userprofile%%\\desktop\\%s.lnk (del /Q /F %%userprofile%%\\desktop\\%s.lnk)', ...
                  platform.atlasviewer_exe{1}, platform.atlasviewer_exe{1});
    system(cmd);
    
    cmd = sprintf('IF EXIST %%userprofile%%\\desktop\\%s.lnk (del /Q /F %%userprofile%%\\desktop\\%s.lnk)', ...
                  platform.homer2_exe{1}, platform.homer2_exe{1});
    system(cmd);
elseif islinux()
    if exist('~/Desktop/Homer2_UI.sh','file')
        delete('~/Desktop/Homer2_UI.sh');
    end
    if exist('~/Desktop/AtlasViewerGUI.sh','file')
        delete('~/Desktop/AtlasViewerGUI.sh');
    end
    if ~exist(platform.mcrpath,'dir') | ~exist([platform.mcrpath, '/mcr'],'dir') | ~exist([platform.mcrpath, '/runtime'],'dir')
        menu('Error: Invalid MCR path under ~/libs/mcr. Terminating installation...\n','OK');
	end
elseif ismac()
    if exist('~/Desktop/Homer2_UI.command','file')
        delete('~/Desktop/Homer2_UI.command');
    end
    if exist('~/Desktop/AtlasViewerGUI.command','file')
        delete('~/Desktop/AtlasViewerGUI.command');
    end
    if ~exist(platform.mcrpath,'dir') | ~exist([platform.mcrpath, '/mcr'],'dir') | ~exist([platform.mcrpath, '/runtime'],'dir')
        menu('Error: Invalid MCR path under ~/libs/mcr. Terminating installation...\n','OK');
	end
end

pause(2);

% Create the source and destination folders
mkdir(dirnameDst);
mkdir([dirnameDst, 'Colin']);
mkdir([dirnameDst, 'Colin/anatomical']);
mkdir([dirnameDst, 'Colin/fw']);
mkdir([dirnameDst, 'tMCimg']);
mkdir([dirnameDst, 'tMCimg/bin']);
mkdir([dirnameDst, 'tMCimg/bin/Win']);
mkdir([dirnameDst, 'tMCimg/bin/Linux']);
mkdir([dirnameDst, 'tMCimg/bin/Darwin']);

waitbar(iStep/nSteps, h); iStep = iStep+1;

% Copy all the AtlasViewerGUI app folder files
waitbar(iStep/nSteps, h); iStep = iStep+1;

% Important: For next 2 copyfile calls make sure to keep the destination
% the way it is, with the destination file name specified. This is important
% for mac installation because the executable is actually a directory.
% Copyfile only copies the contents of a folder so to copy the whole thing
% you need to specify the root foder same as the source.
for ii=1:length(platform.atlasviewer_exe)
    if exist([dirnameSrc, platform.atlasviewer_exe{ii}],'file')
        copyfile([dirnameSrc, platform.atlasviewer_exe{ii}],  [dirnameDst, platform.atlasviewer_exe{ii}]);
    end
end
for ii=1:length(platform.homer2_exe)
    if exist([dirnameSrc, platform.homer2_exe{ii}],'file')
        copyfile([dirnameSrc, platform.homer2_exe{ii}], [dirnameDst, platform.homer2_exe{ii}]);
    end
end
waitbar(iStep/nSteps, h); iStep = iStep+1;

% Copy all the Colin atlas folder files
if exist([dirnameSrc, 'headsurf.mesh'],'file')
    copyfile([dirnameSrc, 'headsurf.mesh'],         [dirnameDst, 'Colin/anatomical']);
end
if exist([dirnameSrc, 'headsurf2vol.txt'],'file')
    copyfile([dirnameSrc, 'headsurf2vol.txt'],         [dirnameDst, 'Colin/anatomical']);
end
if exist([dirnameSrc, 'headvol.vox.gz'],'file')
    copyfile([dirnameSrc, 'headvol.vox.gz'],         [dirnameDst, 'Colin/anatomical']);
elseif exist([dirnameSrc, 'headvol.vox'],'file')
    copyfile([dirnameSrc, 'headvol.vox'],         [dirnameDst, 'Colin/anatomical']);
end
if exist([dirnameSrc, 'headvol2ras.txt'],'file')
    copyfile([dirnameSrc, 'headvol2ras.txt'],         [dirnameDst, 'Colin/anatomical']);
end
if exist([dirnameSrc, 'headvol_dims.txt'],'file')
    copyfile([dirnameSrc, 'headvol_dims.txt'],         [dirnameDst, 'Colin/anatomical']);
end
if exist([dirnameSrc, 'headvol_tiss_type.txt'],'file')
    copyfile([dirnameSrc, 'headvol_tiss_type.txt'],         [dirnameDst, 'Colin/anatomical']);
end
if exist([dirnameSrc, 'labelssurf.mat'],'file')
    copyfile([dirnameSrc, 'labelssurf.mat'],         [dirnameDst, 'Colin/anatomical']);
end
if exist([dirnameSrc, 'labelssurf2vol.txt'],'file')
    copyfile([dirnameSrc, 'labelssurf2vol.txt'],         [dirnameDst, 'Colin/anatomical']);
end
waitbar(iStep/nSteps, h); iStep = iStep+1;
if exist([dirnameSrc, 'pialsurf.mesh'],'file')
    copyfile([dirnameSrc, 'pialsurf.mesh'],         [dirnameDst, 'Colin/anatomical']);
end
waitbar(iStep/nSteps, h); iStep = iStep+1;
if exist([dirnameSrc, 'pialsurf2vol.txt'],'file')
    copyfile([dirnameSrc, 'pialsurf2vol.txt'],      [dirnameDst, 'Colin/anatomical']);
end
waitbar(iStep/nSteps, h); iStep = iStep+1;
if exist([dirnameSrc, 'refpts.txt'],'file')
    copyfile([dirnameSrc, 'refpts.txt'],            [dirnameDst, 'Colin/anatomical']);
end
waitbar(iStep/nSteps, h); iStep = iStep+1;
if exist([dirnameSrc, 'refpts2vol.txt'],'file')
    copyfile([dirnameSrc, 'refpts2vol.txt'],        [dirnameDst, 'Colin/anatomical']);
end
waitbar(iStep/nSteps, h); iStep = iStep+1;
if exist([dirnameSrc, 'refpts_labels.txt'],'file')
    copyfile([dirnameSrc, 'refpts_labels.txt'],     [dirnameDst, 'Colin/anatomical']);
end
waitbar(iStep/nSteps, h); iStep = iStep+1;
if exist([dirnameSrc, platform.mc_exe],'file')
    copyfile([dirnameSrc, platform.mc_exe],         [dirnameDst, 'tMCimg/bin/', platform.arch]);
end
waitbar(iStep/nSteps, h); iStep = iStep+1;
if exist([dirnameSrc, 'db2.mat'],'file')
    copyfile([dirnameSrc, 'db2.mat'],               dirnameDst);
end
waitbar(iStep/nSteps, h); iStep = iStep+1;
pause(2);

% Check if there a fluence profile to load in this particular search path
fluenceProfFnames = dir([dirnameSrc, 'fluenceProf*.mat']);
for ii=1:length(fluenceProfFnames)
    if exist([dirnameSrc, fluenceProfFnames(ii).name],'file')
        copyfile([dirnameSrc, fluenceProfFnames(ii).name],  [dirnameDst, 'Colin/fw']);
    end
    genMultWavelengthSimInFluenceFiles([dirnameSrc, fluenceProfFnames(ii).name], 2, [dirnameDst, 'Colin/fw']);
    waitbar(iStep/nSteps, h); iStep = iStep+1;
end
if exist([dirnameSrc, 'projVoltoMesh_brain.mat'],'file')
    copyfile([dirnameSrc, 'projVoltoMesh_brain.mat'], [dirnameDst, 'Colin/fw']);
end
if exist([dirnameSrc, 'projVoltoMesh_scalp.mat'],'file')
    copyfile([dirnameSrc, 'projVoltoMesh_scalp.mat'], [dirnameDst, 'Colin/fw']);
end
for ii=1:length(platform.iso2meshmex)
    % Use dir instead of exist for mex files because of an annoying matlab bug, where a  
    % non existent file will be reported as exisiting as a mex file (exist() will return 3)
    % because there are other files with the same name and a .mex extention that do exist. 
    % dir doesn't have this problem.    
    if ~isempty(dir([dirnameSrc, platform.iso2meshmex{ii}]))
        fprintf('Copying %s to %s\n', [dirnameSrc, platform.iso2meshmex{ii}], dirnameDst);
        copyfile([dirnameSrc, platform.iso2meshmex{ii}], dirnameDst);
        if isunix()
            system(sprintf('chmod 755 %s', [dirnameDst, '', platform.iso2meshmex{ii}]'));
        end
    else
        fprintf('ERROR: %s does NOT exist...\n', [dirnameSrc, platform.iso2meshmex{ii}]);
    end
end

waitbar(iStep/nSteps, h); iStep = iStep+1;
pause(2);

% Create desktop shortcuts to Homer2_UI and AtlasViewerGUI
if ispc()
    k = dirnameDst=='/';
    dirnameDst(k)='\';
    
    cmd = sprintf('call "%s\\createShortcut.bat" "%s" AtlasViewerGUI.exe', dirnameSrc(1:end-1), dirnameDst);
    system(cmd);
    
    cmd = sprintf('call "%s\\createShortcut.bat" "%s" Homer2_UI.exe', dirnameSrc(1:end-1), dirnameDst);
    system(cmd);
elseif islinux()
    cmd = sprintf('sh %s/createShortcut.sh sh', dirnameSrc(1:end-1));
    system(cmd);
elseif ismac()
    cmd = sprintf('sh %s/createShortcut.sh command', dirnameSrc(1:end-1));
    system(cmd);
end

% Check that everything was installed properly
r = finishInstallGUI();
waitbar(nSteps/nSteps, h);
close(h);

% cleanup();


% -----------------------------------------------------------------
function cleanup()

% Cleanup
if exist('~/Desktop/homer2_install/','dir')
    rmdir('~/Desktop/homer2_install/', 's');
end
if exist('~/Desktop/homer2_install.zip','file')
    delete('~/Desktop/homer2_install.zip');
end
if exist('~/Downloads/homer2_install/','dir')
    rmdir('~/Downloads/homer2_install/', 's');
end
if exist('~/Downloads/homer2_install.zip','file')
    delete('~/Downloads/homer2_install.zip');
end

