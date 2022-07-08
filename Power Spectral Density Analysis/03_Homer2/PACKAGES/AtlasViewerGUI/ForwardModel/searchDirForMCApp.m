function [mc_exename, mc_appname, ext] = searchDirForMCApp(mc_exepath)

mc_exename = '';
mc_appname = '';
ext = '';

files = dir([mc_exepath, '/*']);
for ii=1:length(files)
    if files(ii).isdir
        continue;
    end
    k = find(files(ii).name=='.');
    if isempty(k)
        temp = files(ii).name;
        ext = '';
    else
        temp = files(ii).name(1:k-1);
        ext = files(ii).name(k:end);
    end
    if isMCapp(temp)
        mc_appname = temp;
        mc_exename = [temp, ext];
        break;
    end
end

