function platform = setplatformparams(dirnameSrc)

if ~exist('dirnameSrc','var')
    dirnameSrc = '';
end


platform = struct(...
    'arch','', ...
    'mc_exe','', ...
    'homer2_exe',{{}}, ...
    'atlasviewer_exe',{{}}, ...
    'setup_exe',{{}}, ...
    'setup_script','', ...
    'dirnameApp', getAppDir(), ...
    'mcrpath','', ...
    'iso2meshmex',{{}}, ...
    'iso2meshbin','' ...
    );

if ~ispc()
    currdir = pwd;
    cd ~/;
    dirnameHome = pwd;
    mcrpath = [dirnameHome, '/libs/mcr'];
    cd(currdir);
end

% When this function is called from createInstallFile.m, it is in a Matlab
% IDE and getexeextfinal which relies on ffpath works correctly to find
% cgalsimp2 exe file. But when setup is run it also calls this function
% from an executable and getexeextfinal doesn't work correctly (on MAC) and returns
% empty string. However when setup is run we already have our cgalsimp2
% in the same dir as the setup executable, so we don't need to rely on
% getexeextfinal.
cgalsimp2_ext='';
try 
    if isempty(dirnameSrc)
        cgalsimp2_ext = getexeextfinal('cgalsimp2');
    else
        fprintf('cgalsimp2_ext is empty\n');
        files = dir([dirnameSrc, 'cgalsimp2.*']);
        fprintf('files(1).name = %s\n', files(1).name);
        if ~isempty(files) & ~files(1).isdir
            k = find(files(1).name=='.');
            cgalsimp2_ext = files(1).name(k:end);
            fprintf('Second attempt: cgalsimp2_ext = %s\n', cgalsimp2_ext);
        end
    end
catch
    q = menu('Error finding cgalsimp2', 'OK');
end


fprintf('Final: cgalsimp2_ext = %s\n', cgalsimp2_ext);
platform.iso2meshmex{1} = ['cgalsimp2', cgalsimp2_ext];
platform.iso2meshbin = findiso2meshbin();

if ismac()
    platform.arch = 'Darwin';
    platform.mc_exe = 'tMCimg';
    platform.homer2_exe{1} = 'Homer2_UI.app';
    platform.homer2_exe{2} = 'run_Homer2_UI.sh';
    platform.atlasviewer_exe{1} = 'AtlasViewerGUI.app';
    platform.atlasviewer_exe{2} = 'run_AtlasViewerGUI.sh';
    platform.setup_exe{1} = 'setup.app';
    platform.setup_exe{2} = 'run_setup.sh';
    platform.setup_script = 'setup.command';
    platform.createshort_script{1} = 'createShortcut.sh';
    platform.mcrpath = mcrpath;
elseif islinux()
    platform.arch = 'Linux';
    platform.mc_exe = 'tMCimg';
    platform.homer2_exe{1} = 'Homer2_UI';
    platform.homer2_exe{2} = 'run_Homer2_UI.sh';
    platform.atlasviewer_exe{1} = 'AtlasViewerGUI';
    platform.atlasviewer_exe{2} = 'run_AtlasViewerGUI.sh';
    platform.setup_exe{1} = 'setup';
    platform.setup_exe{2} = 'run_setup.sh';
    platform.setup_script = 'setup.sh';
    platform.createshort_script{1} = 'createShortcut.sh';
    platform.mcrpath = mcrpath;
else
    platform.arch = 'Win';
    platform.mc_exe = 'tMCimg.exe';
    platform.homer2_exe{1} = 'Homer2_UI.exe';
    platform.atlasviewer_exe{1} = 'AtlasViewerGUI.exe';
    platform.setup_exe{1} = 'setup.exe';
    platform.setup_exe{2} = 'installtemp';
    platform.setup_script = 'setup.bat';
    platform.createshort_script{1} = 'createShortcut.bat';
    platform.createshort_script{2} = 'createShortcut.vbs';
end


