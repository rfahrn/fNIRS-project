function dotmfiles = findDotMFiles(subdir)

dotmfiles = {};
currdir = pwd;
if exist('subdir','var')
    cd(subdir);
end
files = dir('*');
if isempty(files)
    return;
end

jj=1;
kk=1;
iF=[];
for ii=1:length(files)
    if isdotmfile(files(ii))
        dotmfiles{jj} = files(ii).name;
        jj=jj+1;
    elseif files(ii).isdir && ~iscurrdir(files(ii)) && ~isparentdir(files(ii))
        dotmfiles = [dotmfiles, findDotMFiles(files(ii).name)];
    end
end
cd(currdir);



% -------------------------------------------------------------------------
function b = isdotmfile(file)

b=0;
if file.isdir
    return;
end
if file.name(end) ~= 'm' || file.name(end-1) ~= '.'
    return;
end
b=1;



% -------------------------------------------------------------------------
function b = iscurrdir(file)

b=0;
if ~file.isdir
    return;
end
if isempty(file.name)
    return;
end
if isempty(file.name)
    return;
end
if length(file.name)==1
    if file.name(1)~='.'
        return;
    end
end
if (length(file.name)==2)
    if (file.name(1)~='.') || (file.name(2)~='/' && file.name(2)~='\')
        return;
    end
end
if (length(file.name)>2)
    return;
end

b=1;



% -------------------------------------------------------------------------
function b = isparentdir(file)

b=0;
if ~file.isdir
    return;
end
if isempty(file.name)
    return;
end
if isempty(file.name)
    return;
end
if length(file.name)==1
    return;
end
if (length(file.name)==2)
    if (file.name(1)~='.') || (file.name(2)~='.')
        return;
    end
end
if (length(file.name)==3)
    if (file.name(1)~='.') || (file.name(2)~='.') || (file.name(2)~='/' && file.name(2)~='\')
        return;
    end
end
if (length(file.name)>3)
    return;
end
b=1;


