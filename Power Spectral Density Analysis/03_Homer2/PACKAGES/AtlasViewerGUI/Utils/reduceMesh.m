function mesh = reduceMesh(mesh)

if isempty(mesh.vertices) | isempty(mesh.faces)
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if number of elements is too large. If greater than 40,000 then
% need to reduce
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if size(mesh.faces,1)>40000
    hwait = waitbar(0,'Generating reduced pial mesh. Please wait ...');
    mesh = reducepatch(mesh, 40000/size(mesh.faces,1) );
    close(hwait);    
end

