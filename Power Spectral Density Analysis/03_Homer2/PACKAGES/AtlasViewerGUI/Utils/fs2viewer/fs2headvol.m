function [fs2viewer, headvol, status] = fs2headvol(fs2viewer, dirname)

headvol = initHeadvol();
status = 1;


if isempty(fs2viewer.threshold)
	c = inputdlg('MRI IMAGE THRESHOLD FOR NOISE REDUCTION (Click CANCEL for default value):');
	if isempty(c)
	    fs2viewer.threshold=30;
	else
	    fs2viewer.threshold = str2num(c{1});
	end
end

[hsegnii, tiss_prop, status] = create_hseg(dirname, fs2viewer.threshold);
if isempty(hsegnii) | status~=0 
    return;
end

%%%% Write the hseg volume to the hseg.bin file
headvol.pathname = dirname;
headvol.img = hsegnii.img;
headvol.tiss_prop = tiss_prop;

% Get orientation: Make up fake RAS reference points around the 
% xyz (right-handed) origin and transform them using the inverse 
% of the T_2ras transformation matrix found in the mri volume
rpa_RAS = [ 128, 0, 0];
lpa_RAS = [-128, 0, 0];
nz_RAS  = [ 0, 128, 0];
iz_RAS  = [ 0,-128, 0];
cz_RAS  = [ 0, 0, 128];
czo_RAS = [ 0, 0,-128];

p_RAS = [nz_RAS; iz_RAS; rpa_RAS; lpa_RAS; cz_RAS; czo_RAS];

% Now transform p_RAS to the orientation in the MRI volume 
T_2ras = [get_nii_vox2ras(hsegnii); 0 0 0 1];
p = xform_apply(p_RAS, inv(T_2ras));

% Get the orientation 
[headvol.orientation, headvol.center] = getOrientation(p);

headvol.T_2digpts = eye(4);
headvol.T_2mc = eye(4);

saveHeadvol(headvol, dirname);
status = 0;
