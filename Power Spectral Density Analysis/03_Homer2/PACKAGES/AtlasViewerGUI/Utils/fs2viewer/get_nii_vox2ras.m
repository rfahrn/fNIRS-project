function vox2ras = get_nii_vox2ras(nii)

qoffset_x = nii.hdr.hist.qoffset_x;
qoffset_y = nii.hdr.hist.qoffset_y;
qoffset_z = nii.hdr.hist.qoffset_z;
srow_x = nii.hdr.hist.srow_x; 
srow_y = nii.hdr.hist.srow_y; 
srow_z = nii.hdr.hist.srow_z;

if abs(-128-qoffset_x) < abs(128-qoffset_x)
    offsetx = -128-qoffset_x;
else
    offsetx = 128-qoffset_x;
end
if abs(-128-qoffset_y) < abs(128-qoffset_y)
    offsety = -128-qoffset_y;
else
    offsety = 128-qoffset_y;
end
if abs(-128-qoffset_z) < abs(128-qoffset_z)
    offsetz = -128-qoffset_z;
else
    offsetz = 128-qoffset_z;
end

srow_x(4) = srow_x(4)+offsetx;
srow_y(4) = srow_y(4)+offsety;
srow_z(4) = srow_z(4)+offsetz;

vox2ras = [srow_x; srow_y; srow_z];
