function digpts = getGroupDigpts(digpts, dirname)

dirs  = dir([dirname, '/*']);

kk=1;
for ii=1:length(dirs)
    
    % Skip all non-subject folders and files
    if ~dirs(ii).isdir
        continue;
    end
    if strcmp(dirs(ii).name, '.')
        continue;
    end
    if strcmp(dirs(ii).name, '..')
        continue;
    end
    
    % Skip all subject folders without dig pts
    if exist([dirs(ii).name, '/digpts.txt'], 'file') ~= 2
        continue;
    end
    
    % Found a subject folder with dig pts
    if kk==1
        digpts.digpts = initDigpts();
    else
        digpts.digpts(kk) = initDigpts();
    end
    digpts.digpts(kk) = getDigpts(digpts.digpts(kk), [dirname, dirs(ii).name]);
    
    kk=kk+1;
end


% Check that all the digpts are of the same probe
if ~isempty(digpts.digpts)
    for jj=2:length(digpts.digpts)
        if size(digpts.digpts(jj).srcpos,1) ~= size(digpts.digpts(1).srcpos,1)
            digpts.digpts = [];
            break;
        end
        if size(digpts.digpts(jj).detpos,1) ~= size(digpts.digpts(1).detpos,1)
            digpts.digpts = [];
            break;
        end
    end
    
    q = menu(sprintf('AtlasViewer has detected dig points in the current subject''s sub-folders.\nDo you want to load the mean of the group dig points?'), 'YES', 'NO');
    if q==2
        digpts.digpts = [];
    end
end

