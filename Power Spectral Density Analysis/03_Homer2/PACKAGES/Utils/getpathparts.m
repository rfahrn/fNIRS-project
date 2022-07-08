function [pathparts,dirsep] = getpathparts(path)

MAX_DIR_NUM=100;

pathparts = repmat({''},MAX_DIR_NUM,1);
dirsep = repmat({''},MAX_DIR_NUM,2);
p = path;
i = 1;
j = 1;
m = 1;

if isempty(p)
    return;
end

while j <= length(p) 

    % Skip dir separators
    while (j <= length(p)) & ((p(j) == '/') | (p(j) == '\'))
        dirsep{i,1} = '/';
        j=j+1;
    end
    
    % 
    % We are at the start of a dir name. Copy it to a new entry in pathparts
    %

    % copy dir name to pathparts
    k = 1;
    while(j <= length(p) & ...
          p(j) ~= '/'    & ...
          p(j) ~= '\')
    
        pathparts{i}(k) = p(j);
        j=j+1;
        k=k+1;

    end
    
    if (j <= length(p)) && p(j)=='\' | p(j)=='/'
        dirsep{i,2} = '/';
    end
    i=i+1;

end
k=find(strcmp(pathparts,''));
pathparts(k)=[];
dirsep(k,:)=[];

