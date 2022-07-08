function [subjDirs, groupDir] = findSubjDirs(dirname)

subjDirs = mydir('');
groupDir = '';

if ~exist('dirname','var') | isempty(dirname)
    dirname = './';
end

currdir = pwd;

% If groupResult.mat does not exist in the folder dirname then it's not a
% group folder. 
if ~exist([dirname, 'groupResults.mat'],'file')
    return;
end

cd(dirname);
groupDir = pwd;

subjDirs0 = mydir();
kk=1;
for ii=1:length(subjDirs0)
    if ~subjDirs0(ii).isdir
       continue;
    end
    if strcmp(subjDirs0(ii).name,'.')
       continue;
    end
    if strcmp(subjDirs0(ii).name,'..')   
       continue;
    end
    if strcmp(subjDirs0(ii).name,'hide')   
       continue;
    end
    
    cd(subjDirs0(ii).name);
    foos = mydir({'*.nirs','*.sd','*.SD','atlasViewer.mat'});
    if length(foos)>0
        subjDirs(kk) = subjDirs0(ii);
        kk=kk+1;
    end
    cd('../');    
end

cd(currdir);



% -------------------------------------------------------------
function files = mydir(strs)

files = dir('');
files0 = {};
if ~exist('strs','var')
    files = dir();
else
    kk=1;
    for ii=1:length(strs) 
        new = dir(strs{ii});
        for jj=1:length(new)
            files0{kk} = new(jj).name;
            kk=kk+1;
        end
    end
    
    % On windows uppercase and lowercase isn't distinuished leading to
    % duplicate files. We discard them here with the call to unique
    files0 = unique(files0);
    
    for ii=1:length(files0)
        files(ii) = dir(files0{ii});
    end
end


