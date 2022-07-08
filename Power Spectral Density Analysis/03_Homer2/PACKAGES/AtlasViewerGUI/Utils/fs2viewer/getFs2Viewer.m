function fs2viewer = getFs2Viewer(fs2viewer, dirname, headsurf, headvol, pialsurf)

if isempty(dirname)
    return;
end

if dirname(end)~='/' && dirname(end)~='\'
    dirname(end+1)='/';
end

%{
if (exist([dirname, 'mri'],'dir') && ~exist([dirname, 'antomical'],'dir'))
    set(fs2viewer.handles.menuItemFs2Viewer,'enable','on');
else
    set(fs2viewer.handles.menuItemFs2Viewer,'enable','off');
end
%}