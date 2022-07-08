function save_vox(filename, vol)

% USAGE: 
%   
%    save_vox(filename, vol)
%
% DESCRIPTION:
%
%    Writes data to a file in binary format which means that the way the 
%    data appears in memory as a sequnece of bytes is the way it is saved 
%    on disk. The dimensions of the data are saved in a text file of the 
%    same name as the argument filename except the extension '_dims.txt' 
%    is appended. This is the only header information that is saved. 
%    
% Author: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% Date:   11/22/2012

img       = vol.img;
tiss_prop = vol.tiss_prop;
T_2digpts = vol.T_2digpts;
T_2mc = vol.T_2mc;

% Create .bin file from segemented head
fid = fopen(filename, 'wb');
fwrite(fid, img, 'uint8');
fclose(fid);

% Save text file with the dimensions
k = strfind(filename, '.');
filename_dims = [filename(1:k(end)-1), '_dims.txt'];
dims = size(img); 
save(filename_dims, 'dims', '-ascii');

% Generate a tissue file.
filename_tiss_type = [filename(1:k(end)-1), '_tiss_type.txt'];
save_tiss_type(filename_tiss_type,tiss_prop);

% Generate a transformation files.
filename_2digpts = [filename(1:k(end)-1), '2digpts.txt'];
save(filename_2digpts,'T_2digpts','-ascii');

filename_2mc = [filename(1:k(end)-1) '2mc.txt'];
save(filename_2mc,'T_2mc','-ascii');

if ~isempty(vol.orientation)
    filename_orientation = [filename(1:k(end)-1), '_orientation.txt'];
    fd = fopen(filename_orientation, 'w');
    fprintf(fd,'%s',vol.orientationOrig);
    fclose(fd);
end


