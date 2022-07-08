function [orientation, o] = getOrientation(nz, iz, rpa, lpa, cz, czo)

%
% Usage:
%
%    [orientation, o] = getOrientation(nz, iz, rpa, lpa, cz)
%
% Description:
%    
%    Function determines the orientation of head reference points using  
%    a Freesurfer style 3 letter code. This code indicates how the 6 head 
%    axes Left-Right, Anterior-Posterior, and Superior-Inferior correspond to 
%    the 6 XYZ coordinates, (x+, x-, y+, y-, z+, z-)in a right handed 
%    coordinate system. 
%
%    The significance of this code is that any head orientation with 'L' 
%    in it (e.g., LAS or PLS) will appear left-right flipped (i.e. mirror 
%    image) when viewed in a right handed system. Conversly any code with 
%    'R' in it will appear correctly. That is, not-flipped with respect to 
%    left-right. Note: Matlab by default is a right-handed coordinate system. 
%
%
% Arguments:
%   
%    nz:  Nazion coordinates 
%
%    iz:  Inion coordinates 
%
%    rpa: Right Preauricular coordinates 
%
%    lpa: Left Preauricular coordinates 
%
%    cz:  Central coordinates 
%    
% Ouput:
%    
%    orientation: 3-letter code indicating how the axes of the head 
%                 correspond to the  axes of the xyz right-handed 
%                 coord system. There are 6x4x2 = 48 code possibilitities. 
%                 Here are 2 of them:
%
%                  'RIP' --> 
%                    Right     aligns with  x+ (thus Left      aligns with x-)
%                    Inferior  aligns with  y+ (thus Superior  aligns with y-)
%                    Posterior aligns with  z+ (thus Anterior  aligns with z-)
%                    
%                  'LAS' --> 
%                    Left      aligns with  x+ (thus Right    aligns with  x-) 
%                    Anterior  aligns with  y+ (thus Anterior aligns with  y-)
%                    Superior  aligns with  z+ (thus Anerior  aligns with  z-)
%                  
%
%    o:           Center of the reference points nz,iz,rpa,lpa,cz, 
%                 used to align with the (0,0,0) origin of the 
%                 xyz right-handed coord system.
%
%  Written by Jay Dubb (jdubb@nmr.mgh.harvard.edu) 
%  Date written: Nov 28, 2015
%

DEBUG1 = 0;
DEBUG2 = 0;

orientation = '';
o = [];

if exist('nz','var') & ~exist('iz','var') & ~exist('rpa','var') & ~exist('lpa','var') & ~exist('cz','var')
    p = nz;
    nz  = p(1,:);
    iz  = p(2,:);
    rpa = p(3,:);
    lpa = p(4,:);
    cz  = p(5,:);
    if size(p,1)==6
        czo = p(6,:);
    end
end
if ~exist('czo','var')
    czo = [];
end

if isempty(nz) | isempty(iz) | isempty(rpa) | isempty(lpa) | isempty(cz)
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine origin of the head: Get line between LPA and RPA
% and line between Nz and Iz.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m1 = [(rpa(1)+lpa(1))/2, (rpa(2)+lpa(2))/2, (rpa(3)+lpa(3))/2];
m2 = [(nz(1)+iz(1))/2,   (nz(2)+iz(2))/2,   (nz(3)+iz(3))/2];
o = mean([m1; m2]);
if isempty(czo)
    czo = points_on_line(o,cz,-1,'relative');
end
m3 = [(cz(1)+czo(1))/2,  (cz(2)+czo(2))/2,  (cz(3)+czo(3))/2];

% Translate head axes to common head origin
T1 = [1 0 0 o(1)-m1(1); 0 1 0 o(2)-m1(2); 0 0 1 o(3)-m1(3); 0 0 0 1];
T2 = [1 0 0 o(1)-m2(1); 0 1 0 o(2)-m2(2); 0 0 1 o(3)-m2(3); 0 0 0 1];
T3 = [1 0 0 o(1)-m3(1); 0 1 0 o(2)-m3(2); 0 0 1 o(3)-m3(3); 0 0 0 1];
rpa = xform_apply(rpa, T1);
lpa = xform_apply(lpa, T1);
nz  = xform_apply(nz , T2);
iz  = xform_apply(iz , T2);
cz  = xform_apply(cz , T3);
czo = xform_apply(czo, T3);

if DEBUG1
    displayLandmarks(nz, iz, rpa, lpa, cz, czo);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transform to origin of xyz right-handed coordinate system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% First translate to origin 
T = [1 0 0 -o(1); 0 1 0 -o(2); 0 0 1 -o(3); 0 0 0 1];
p_new = xform_apply([nz; iz; rpa; lpa; cz; czo], T);
nz_new  = p_new(1,:);
iz_new  = p_new(2,:);
rpa_new = p_new(3,:);
lpa_new = p_new(4,:);
cz_new  = p_new(5,:);
czo_new = p_new(6,:);

% Rotate to align with x,y,z coordinates. 
p(1,:) = findClosestAxes(rpa_new);
p(2,:) = findClosestAxes(nz_new);
p(3,:) = findClosestAxes(cz_new);
q = [rpa_new; nz_new; cz_new];
T = gen_xform_from_pts(q,p(1:size(q,1),:));
if isempty(T)
    return;
end
p_new = xform_apply(p_new, T);

nz_new  = p_new(1,:);
iz_new  = p_new(2,:);
rpa_new = p_new(3,:);
lpa_new = p_new(4,:);
cz_new  = p_new(5,:);
czo_new = p_new(6,:);

if DEBUG2
    displayLandmarks(nz_new, iz_new, rpa_new, lpa_new, cz_new, czo_new);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now assign head axes to xyz positive axes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine head orientation in relation to a right-handed xyz coordinate
% system. First determine which head side corresponds to which axis
[~,icoord_AP] = max(abs(nz_new - iz_new));
[~,icoord_RL] = max(abs(rpa_new - lpa_new));
[~,icoord_SI] = max(abs(cz_new - czo_new));

% Error checks
if icoord_AP==icoord_RL
   return; 
end
if icoord_AP==icoord_SI
   return; 
end
if icoord_RL==icoord_SI
   return;
end

% Assign Anterior or Posterior to +X, +Y, or +Z 
if nz_new(icoord_AP) >= 0
    orientation(icoord_AP) = 'A';
else
    orientation(icoord_AP) = 'P';
end

% Assign Left or Right to +X, +Y, or +Z 
if rpa_new(icoord_RL) >= 0
    orientation(icoord_RL) = 'R';
else
    orientation(icoord_RL) = 'L';
end

% Assign Superior or Inferior to +X, +Y, or +Z 
if cz_new(icoord_SI) >= 0
    orientation(icoord_SI) = 'S';
else
    orientation(icoord_SI) = 'I';
end



% -----------------------------------------------------------------------
function ax = findClosestAxes(v)

s = dist3(v, [0,0,0]);

xyz(1,:) = [ s, 0, 0];
xyz(2,:) = [-s, 0, 0];
xyz(3,:) = [ 0, s, 0];
xyz(4,:) = [ 0,-s, 0];
xyz(5,:) = [ 0, 0, s];
xyz(6,:) = [ 0, 0,-s];

d(1) = dist3(v, xyz(1,:));
d(2) = dist3(v, xyz(2,:));
d(3) = dist3(v, xyz(3,:));
d(4) = dist3(v, xyz(4,:));
d(5) = dist3(v, xyz(5,:));
d(6) = dist3(v, xyz(6,:));

[~,i] = min(d);
ax = xyz(i,:);




% ----------------------------------------------------------------------
function displayLandmarks(nz,iz,rpa,lpa,cz,czo)

l1 = points_on_line(rpa, lpa, 1/100, 'all');
l2 = points_on_line(nz, iz, 1/100, 'all');
l3 = points_on_line(cz, czo, 1/100, 'all');

set(gca, {'xgrid', 'ygrid','zgrid'}, {'on','on','on'}); 
axis vis3d; 
axis equal
rotate3d
hold on

hl1 = plot3(l1(:,1), l1(:,2), l1(:,3), '.r'); 
hl2 = plot3(l2(:,1), l2(:,2), l2(:,3), '.g');
hl3 = plot3(l3(:,1), l3(:,2), l3(:,3), '.b');

hrpa = plot3(rpa(:,1), rpa(:,2), rpa(:,3), '.c', 'markersize',30);
hnz = plot3(nz(:,1), nz(:,2), nz(:,3), '.m', 'markersize',30);
hcz = plot3(cz(:,1), cz(:,2), cz(:,3), '.k', 'markersize',30);


