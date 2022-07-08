function fs2viewer = convertFs2Viewer(fs2viewer, dirnameSubj)

if ~exist([dirnameSubj, '/mri'], 'dir') | ~exist([dirnameSubj, '/surf'], 'dir')
    return;
end

[fs2viewer, headvol, status1] = fs2headvol(fs2viewer, dirnameSubj);
if status1~=0
    return;
end
[fs2viewer, status2] = headvol2headsurf(fs2viewer, dirnameSubj, headvol);
[fs2viewer, status3] = fs2pialsurf(fs2viewer, dirnameSubj);

status = status1+status2+status3;

if status>0
    menu(sprintf('Error in converting FreeSurfer files to Viewer format.'),'OK');
    return;
end

