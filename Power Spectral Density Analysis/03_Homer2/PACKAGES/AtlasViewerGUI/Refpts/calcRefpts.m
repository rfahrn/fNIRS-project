function [refpts, labels, err] = calcRefpts(refpts, head, labels, eeg_system)

%
% USAGE:
%
%    [refpts, labels] = calcRefpts(refpts, head, labels, system)
%
% INPUTS:
%    
%    refpts  - A set of 5 landmark points in the order: Nz, Iz, RPA, LPA, Cz
%              where Cz is an initial guess (here referred to as Czi) 
%              marking some position close to the top of the head surface
%              passed as the first argument.
%
%    head    - Head volume or head vertices. 
%
%
% OUTPUTS:
%     
%    refpts     - A structure, (refpts.pos and refpts.labels), of 
%                 10-20, 10-10 or 10-5 reference points array and corresponding 
%                 ref points labels. 
%         or 
%
%    refpts     - 10-20, 10-10 or 10-5 reference points array
%    labels     - corresponding ref points labels.
%
%    Type of output will match the refpts input type.
% 
% DESCRIPTION:
%
%    User picks the reference points Nz, Iz, RPA, LPA and Cz (Cz can be less exact 
%    than the others, basically anywhere near the top/center of the head),
%    on a scan of the head.
%
%    *** NOTE *** this algorithm needs two conditions to work properly: 
%    a) the mesh density has to be reasonably high (a bit of trial and error),  
%    and b) the reference points should be on actual head voxels rather than 
%    air (or some other medium). 
%
% 
% EXAMPLE:
%
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   05/07/2009
%
% Modified by Jay Dubb to compute 10-20, 10-10, or 10-5 eeg points
% DATE:   04/18/2015
%
%

err = true;

%%% Process args

% Arg 1

if ~isstruct(head) && ndims(head)==2
    surf = head;
    vertices = surf;
elseif ~isstruct(head) && ndims(head)==3
    fv = isosurface(head,.9);
    fv.vertices = [fv.vertices(:,2) fv.vertices(:,1) fv.vertices(:,3)];
    % [fv.vertices fv.faces] = meshresample(fv.vertices, fv.faces, .2);
    surf = fv;
    vertices = surf.vertices;
elseif isstruct(head) && isfield(head,'img')
    fv = isosurface(head.img,.9);
    fv.vertices = [fv.vertices(:,2) fv.vertices(:,1) fv.vertices(:,3)];
    % [fv.vertices fv.faces] = meshresample(fv.vertices, fv.faces, .2);
    surf = fv;    
    vertices = surf.vertices;
elseif isstruct(head) && isfield(head,'mesh')    
    surf = head.mesh;
    vertices = surf.vertices;
end


% Arg 2
if isstruct(refpts)
    pos    = refpts.pos;
    labels = refpts.labels;
else
    pos = refpts;
end
pos = nearest_point(vertices,pos);


% Arg 3 (optional)
if ~exist('labels','var')
    menu('ERROR: Labels not found. Cannot determine reference points.', 'OK');
    return;
end


% Arg 4 (optional)
switch(eeg_system)   
    case '10-20'
        ;
    case '10-10'
        ;
    case '10-5'
        ;
    case '10-2.5'
        [refpts,~,err] = calcRefptsSmallscale(refpts, head, {}, eeg_system);
        return;
    case '10-1'
        [refpts,~,err] = calcRefptsSmallscale(refpts, head, {}, eeg_system);
        return;
    otherwise
        menu('Not yet implemented','OK');
        return;
end


% Find ref pts in pos
knz = find(strcmpi(labels,'nz'));
kiz = find(strcmpi(labels,'iz'));
krpa = find(strcmpi(labels,'rpa'));
klpa = find(strcmpi(labels,'lpa'));
kar = find(strcmpi(labels,'ar'));
kal = find(strcmpi(labels,'al'));
kcz = find(strcmpi(labels,'cz'));

% Error checking 
if isempty(knz)
    return;
end
if isempty(kiz)
    return;
end
if isempty(krpa)
    if ~isempty(kar)
        krpa = kar;
    else
        return;
    end
end
if isempty(klpa)
    if ~isempty(kal)
        klpa = kal;
    else
        return;
    end
end
if isempty(kcz)
    return;
end


Nz  = pos(knz,:);
Iz  = pos(kiz,:);
RPA  = pos(krpa,:);
LPA  = pos(klpa,:);
Czi = pos(kcz,:);

% Distance threshold for the curve_gen to determine 
% the surface points on the head which intersect with a plane
% dt=.5;
dt=.5;

% Step sizes as a percentage of curve length
stepsize1 = 5;
stepsize2 = 12.5;
stepsize3 = 4.5455;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note: How to get a more accurate location of Cz? Roughly speaking, Cz is the point 
% on the surface of the head that is equidistant from LPA and RPA, and from
% Nz and Iz, respectively.
% 
% The procedure used here to approximate this point is as follows:
%
% 1. Find the midpoint of LPA-Czi-RPA (Where Czi is the user's initial guess at Cz), call it Mp_LPACziRPA. 
%
% 2. Find the curve between Nz and Iz through the point Mp_LPACziRPA (in the code it's the 1st recalculation of Czi), 
%
% 3. Find the midpoint of the curve Nz-Mp_LPACziRPA-Iz. This second midpoint we take to be our Cz.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

% Find the curve from LPA to RPA through our initial guess, Czi
[curve_pts_LPACziRPA len_LPACziRPA] = curve_gen(LPA, RPA, Czi, surf, dt);
fprintf('Initial LPA-RPA curve length: %1.1f\n', len_LPACziRPA);


display('Recalculating our guess for Cz along the curve LPA-RPA...');

% Recalculate Czi: Find the midpoint of curve from LPA to RPA 
% through our initial guess, Czi. The midpoint will be our new Czi
Czi = curve_walk(curve_pts_LPACziRPA, len_LPACziRPA/2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve and ref pts from Nz to Iz through the recalculated Czi. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_NzCziIz = {'NFpz'; 'Fpz'; 'AFpz'; 'AFz'; 'AFFz'; 'Fz'; 'FFCz'; 'FCz'; 'FCCz'; 'dummy'; 'CCPz'; 'CPz'; 'CPPz'; 'Pz'; 'PPOz'; 'POz'; 'POOz'; 'Oz'; 'OIz'};
[curve_pts_NzCziIz, len_NzCziIz] = curve_gen(Nz, Iz, Czi, surf, dt);
refpts_NzCziIz = calcRefptsAlongCurve(curve_pts_NzCziIz, len_NzCziIz, labels_NzCziIz, stepsize1, 'Nz-Czi-Iz');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find Cz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Cz, len] = curve_walk(curve_pts_NzCziIz, 50*len_NzCziIz/100);
fprintf('Cz = (%1.1f, %1.1f, %1.1f) is %1.2f away from Nz\n', Cz(1), Cz(2), Cz(3), len);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve and ref pts from LPA to RPA through Cz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_LPACzRPA = {'T9'; 'T9h'; 'T7'; 'T7h'; 'C5'; 'C5h'; 'C3'; 'C3h'; 'C1'; 'C1h'; 'dummy'; 'C2h'; 'C2'; 'C4h'; 'C4'; 'C6h'; 'C6'; 'T8h'; 'T8'; 'T10h'; 'T10'};
[curve_pts_LPACzRPA, len_LPACzRPA] = curve_gen(LPA, RPA, Cz, surf, dt);
refpts_LPACzRPA = calcRefptsAlongCurve(curve_pts_LPACzRPA, len_LPACzRPA, labels_LPACzRPA, stepsize3, 'LPA-Cz-RPA');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nz-T9-Iz, Nz-T10-Iz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T9 = refpts_LPACzRPA(1,:);
T10 = refpts_LPACzRPA(end,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from Nz to Iz, through T9. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_NzT9Iz = curve_gen(Nz, Iz, T9, surf, dt, 6);
[foo, iT9] = nearest_point(curve_pts_NzT9Iz, T9);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from Nz to T9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_NzT9 = {'N1h'; 'N1'; 'AFp9'; 'AF9'; 'AFF9'; 'F9'; 'FFT9'; 'FT9'; 'FTT9'};
refpts_NzT9 = calcRefptsAlongCurve(curve_pts_NzT9Iz(1:iT9,:), 0, labels_NzT9, 2*stepsize1, 'Nz-T9');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from T9 to Iz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_T9Iz = {'TTP9'; 'TP9'; 'TPP9'; 'P9'; 'PPO9'; 'PO9'; 'POO9'; 'I1'; 'I1h'};
refpts_T9Iz = calcRefptsAlongCurve(curve_pts_NzT9Iz(iT9:end,:), 0, labels_T9Iz, 2*stepsize1, 'T9-Iz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from Nz to Iz, through T10. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_NzT10Iz = curve_gen(Nz, Iz, T10, surf, dt, 6);
[foo, iT10] = nearest_point(curve_pts_NzT10Iz, T10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from Nz to T10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_NzT10 = {'N2h'; 'N2'; 'AFp10'; 'AF10'; 'AFF10'; 'F10'; 'FFT10'; 'FT10'; 'FTT10'};
refpts_NzT10 = calcRefptsAlongCurve(curve_pts_NzT10Iz(1:iT10,:), 0, labels_NzT10, 2*stepsize1, 'Nz-T10');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from T10 to Iz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_T10Iz = {'TTP10'; 'TP10'; 'TPP10'; 'P10'; 'PPO10'; 'PO10'; 'POO10'; 'I2'; 'I2h'};
refpts_T10Iz = calcRefptsAlongCurve(curve_pts_NzT10Iz(iT10:end,:), 0, labels_T10Iz, 2*stepsize1, 'T10-Iz');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NFpz-T9h-OIz, NFpz-T10h-OIz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NFpz = refpts_NzCziIz(1,:);
OIz  = refpts_NzCziIz(end,:);
T9h  = refpts_LPACzRPA(2,:);
T10h = refpts_LPACzRPA(end-1,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from NFpz to OIz, through T9h. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_NFpzT9hOIz = curve_gen(NFpz, OIz, T9h, surf, dt, 6);
[foo, iT9h] = nearest_point(curve_pts_NFpzT9hOIz, T9h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from NFpz to T9h
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_NFpzT9h = {'NFp1h'; 'NFp1'; 'AFp9h'; 'AF9h'; 'AFF9h'; 'F9h'; 'FFT9h'; 'FT9h'; 'FTT9h'};
refpts_NFpzT9h = calcRefptsAlongCurve(curve_pts_NFpzT9hOIz(1:iT9h,:), 0, labels_NFpzT9h, 2*stepsize1, 'NFpz-T9h');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from T9h to OIz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_T9hOIz = {'TTP9h'; 'TP9h'; 'TPP9h'; 'P9h'; 'PPO9h'; 'PO9h'; 'POO9h'; 'OI1'; 'OI1h'};
refpts_T9hOIz = calcRefptsAlongCurve(curve_pts_NFpzT9hOIz(iT9h:end,:), 0, labels_T9hOIz, 2*stepsize1, 'T9h-OIz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from NFpz to OIz, through T10h. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_NFpzT10hOIz = curve_gen(NFpz, OIz, T10h, surf, dt, 6);
[foo, iT10h] = nearest_point(curve_pts_NFpzT10hOIz, T10h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from NFpz to T10h
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_NFpzT10h = {'NFp2h'; 'NFp2'; 'AFp10h'; 'AF10h'; 'AFF10h'; 'F10h'; 'FFT10h'; 'FT10h'; 'FTT10h'};
refpts_NFpzT10h = calcRefptsAlongCurve(curve_pts_NFpzT10hOIz(1:iT10h,:), 0, labels_NFpzT10h, 2*stepsize1, 'NFpz-T10h');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from T10h to OIz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_T10hOIz = {'TTP10h'; 'TP10h'; 'TPP10h'; 'P10h'; 'PPO10h'; 'PO10h'; 'POO10h'; 'OI2'; 'OI2h'};
refpts_T10hOIz = calcRefptsAlongCurve(curve_pts_NFpzT10hOIz(iT9h:end,:), 0, labels_T10hOIz, 2*stepsize1, 'T10h-OIz');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fpz-T7-Oz, Fpz-T10h-OIz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fpz = refpts_NzCziIz(2,:);
Oz  = refpts_NzCziIz(end-1,:);
T7  = refpts_LPACzRPA(3,:);
T8  = refpts_LPACzRPA(end-2,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from Fpz to Oz, through T7. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_FpzT7Oz = curve_gen(Fpz, Oz, T7, surf, dt);
[foo, iT7] = nearest_point(curve_pts_FpzT7Oz, T7);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from Fpz to T7
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_FpzT7 = {'Fp1h'; 'Fp1'; 'AFp7'; 'AF7'; 'AFF7'; 'F7'; 'FFT7'; 'FT7'; 'FTT7'};
refpts_FpzT7 = calcRefptsAlongCurve(curve_pts_FpzT7Oz(1:iT7,:), 0, labels_FpzT7, 2*stepsize1, 'Fpz-T7');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from T7 to Oz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_T7Oz = {'TTP7'; 'TP7'; 'TPP7'; 'P7'; 'PPO7'; 'PO7'; 'POO7'; 'O1'; 'O1h'};
refpts_T7Oz = calcRefptsAlongCurve(curve_pts_FpzT7Oz(iT7:end,:), 0, labels_T7Oz, 2*stepsize1, 'T7-Oz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from Fpz to Oz, through T8. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_FpzT8Oz = curve_gen(Fpz, Oz, T8, surf, dt);
[foo, iT8] = nearest_point(curve_pts_FpzT8Oz, T8);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from Fpz to T8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_FpzT8 = {'Fp2h'; 'Fp2'; 'AFp8'; 'AF8'; 'AFF8'; 'F8'; 'FFT8'; 'FT8'; 'FTT8'};
refpts_FpzT8 = calcRefptsAlongCurve(curve_pts_FpzT8Oz(1:iT8,:), 0, labels_FpzT8, 2*stepsize1, 'Fpz-T8');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from T8 to Oz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_T8Oz = {'TTP8'; 'TP8'; 'TPP8'; 'P8'; 'PPO8'; 'PO8'; 'POO8'; 'O2'; 'O2h'};
refpts_T8Oz = calcRefptsAlongCurve(curve_pts_FpzT8Oz(iT8:end,:), 0, labels_T8Oz, 2*stepsize1, 'T8-Oz');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFp7-AFpz-AFp8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AFp7 = refpts_FpzT7(3,:);
AFp8 = refpts_FpzT8(3,:);
AFpz = refpts_NzCziIz(3,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from AFp7 to AFp8, through AFpz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_AFp7AFpzAFp8 = curve_gen(AFp7, AFp8, AFpz, surf, dt);
[foo, iAFpz] = nearest_point(curve_pts_AFp7AFpzAFp8, AFpz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from AFp7 to AFpz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_AFp7AFpz = {'AFp5'; 'AFp3'; 'AFp1'};
refpts_AFp7AFpz = calcRefptsAlongCurve(curve_pts_AFp7AFpzAFp8(1:iAFpz,:), 0, labels_AFp7AFpz, 2*stepsize2, 'AFp7-AFpz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from AFp8 to AFpz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_AFp8AFpz = {'AFp6'; 'AFp4'; 'AFp2'};
refpts_AFp8AFpz = calcRefptsAlongCurve(curve_pts_AFp7AFpzAFp8(end:-1:iAFpz,:), 0, labels_AFp8AFpz, 2*stepsize2, 'AFp8-AFpz');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AF7-AFz-AF8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AF7 = refpts_FpzT7(4,:);
AF8 = refpts_FpzT8(4,:);
AFz = refpts_NzCziIz(4,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from AF7 to AF8, through AFz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_AF7AFzAF8 = curve_gen(AF7, AF8, AFz, surf, dt);
[foo, iAFz] = nearest_point(curve_pts_AF7AFzAF8, AFz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from AF7 to AFz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_AF7AFz = {'AF7h'; 'AF5'; 'AF5h'; 'AF3'; 'AF3h'; 'AF1'; 'AF1h'};
refpts_AF7AFz = calcRefptsAlongCurve(curve_pts_AF7AFzAF8(1:iAFz,:), 0, labels_AF7AFz, stepsize2, 'AF7-AFz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from AF8 to AFz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_AF8AFz = {'AF8h'; 'AF6'; 'AF6h'; 'AF4'; 'AF4h'; 'AF2'; 'AF2h'};
refpts_AF8AFz = calcRefptsAlongCurve(curve_pts_AF7AFzAF8(end:-1:iAFz,:), 0, labels_AF8AFz, stepsize2, 'AF8-AFz');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFF7-AFFz-AFF8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AFF7 = refpts_FpzT7(5,:);
AFF8 = refpts_FpzT8(5,:);
AFFz = refpts_NzCziIz(5,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from AFF7 to AFF8, through AFFz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_AFF7AFFzAFF8 = curve_gen(AFF7, AFF8, AFFz, surf, dt);
[foo, iAFFz] = nearest_point(curve_pts_AFF7AFFzAFF8, AFFz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from AFF7 to AFFz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_AFF7AFFz = {'AFF7h'; 'AFF5'; 'AFF5h'; 'AFF3'; 'AFF3h'; 'AFF1'; 'AFF1h'};
refpts_AFF7AFFz = calcRefptsAlongCurve(curve_pts_AFF7AFFzAFF8(1:iAFFz,:), 0, labels_AFF7AFFz, stepsize2, 'AFF7-AFFz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from AFF8 to AFFz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_AFF8AFFz = {'AFF8h'; 'AFF6'; 'AFF6h'; 'AFF4'; 'AFF4h'; 'AFF2'; 'AFF2h'};
refpts_AFF8AFFz = calcRefptsAlongCurve(curve_pts_AFF7AFFzAFF8(end:-1:iAFFz,:), 0, labels_AFF8AFFz, stepsize2, 'AFF8-AFFz');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% F7-Fz-F8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F7 = refpts_FpzT7(6,:);
F8 = refpts_FpzT8(6,:);
Fz = refpts_NzCziIz(6,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from F7 to F8, through Fz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_F7FzF8 = curve_gen(F7, F8, Fz, surf, dt);
[foo, iFz] = nearest_point(curve_pts_F7FzF8, Fz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from F7 to Fz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_F7Fz = {'F7h'; 'F5'; 'F5h'; 'F3'; 'F3h'; 'F1'; 'F1h'};
refpts_F7Fz = calcRefptsAlongCurve(curve_pts_F7FzF8(1:iFz,:), 0, labels_F7Fz, stepsize2, 'F7-Fz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from F8 to Fz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_F8Fz = {'F8h'; 'F6'; 'F6h'; 'F4'; 'F4h'; 'F2'; 'F2h'};
refpts_F8Fz = calcRefptsAlongCurve(curve_pts_F7FzF8(end:-1:iFz,:), 0, labels_F8Fz, stepsize2, 'F8-Fz');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT7-FFCz-FFT8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FFT7 = refpts_FpzT7(7,:);
FFT8 = refpts_FpzT8(7,:);
FFCz = refpts_NzCziIz(7,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from FFT7 to FFT8, through FFCz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_FFT7FFCzFFT8 = curve_gen(FFT7, FFT8, FFCz, surf, dt);
[foo, iFFCz] = nearest_point(curve_pts_FFT7FFCzFFT8, FFCz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from FFT7 to FFCz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_FFT7FFCz = {'FFT7h'; 'FFC5'; 'FFC5h'; 'FFC3'; 'FFC3h'; 'FFC1'; 'FFC1h'};
refpts_FFT7FFCz = calcRefptsAlongCurve(curve_pts_FFT7FFCzFFT8(1:iFFCz,:), 0, labels_FFT7FFCz, stepsize2, 'FFT7-FFCz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from FFT8 to FFCz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_FFT8FFCz = {'FFT8h'; 'FFC6'; 'FFC6h'; 'FFC4'; 'FFC4h'; 'FFC2'; 'FFC2h'};
refpts_FFT8FFCz = calcRefptsAlongCurve(curve_pts_FFT7FFCzFFT8(end:-1:iFFCz,:), 0, labels_FFT8FFCz, stepsize2, 'FFT8-FFCz');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FT7-FCz-FT8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FT7 = refpts_FpzT7(8,:);
FT8 = refpts_FpzT8(8,:);
FCz = refpts_NzCziIz(8,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from FT7 to FT8, through FCz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_FT7FCzFT8 = curve_gen(FT7, FT8, FCz, surf, dt);
[foo, iFCz] = nearest_point(curve_pts_FT7FCzFT8, FCz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from FT7 to FCz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_FT7FCz = {'FT7h'; 'FC5'; 'FC5h'; 'FC3'; 'FC3h'; 'FC1'; 'FC1h'};
refpts_FT7FCz = calcRefptsAlongCurve(curve_pts_FT7FCzFT8(1:iFCz,:), 0, labels_FT7FCz, stepsize2, 'FT7-FCz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from FT8 to FCz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_FT8FCz = {'FT8h'; 'FC6'; 'FC6h'; 'FC4'; 'FC4h'; 'FC2'; 'FC2h'};
refpts_FT8FCz = calcRefptsAlongCurve(curve_pts_FT7FCzFT8(end:-1:iFCz,:), 0, labels_FT8FCz, stepsize2, 'FT8-FCz');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FTT7-FCCz-FTT8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FTT7 = refpts_FpzT7(9,:);
FTT8 = refpts_FpzT8(9,:);
FCCz = refpts_NzCziIz(9,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from FTT7 to FTT8, through FCCz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_FTT7FCCzFTT8 = curve_gen(FTT7, FTT8, FCCz, surf, dt);
[foo, iFCCz] = nearest_point(curve_pts_FTT7FCCzFTT8, FCCz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from FTT7 to FCCz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_FTT7FCCz = {'FTT7h'; 'FCC5'; 'FCC5h'; 'FCC3'; 'FCC3h'; 'FCC1'; 'FCC1h'};
refpts_FTT7FCCz = calcRefptsAlongCurve(curve_pts_FTT7FCCzFTT8(1:iFCCz,:), 0, labels_FTT7FCCz, stepsize2, 'FTT7-FCCz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from FTT8 to FCCz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_FTT8FCCz = {'FTT8h'; 'FCC6'; 'FCC6h'; 'FCC4'; 'FCC4h'; 'FCC2'; 'FCC2h'};
refpts_FTT8FCCz = calcRefptsAlongCurve(curve_pts_FTT7FCCzFTT8(end:-1:iFCCz,:), 0, labels_FTT8FCCz, stepsize2, 'FTT8-FCCz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TTP7-CCPz-TTP8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TTP7 = refpts_T7Oz(1,:);
TTP8 = refpts_T8Oz(1,:);
CCPz = refpts_NzCziIz(11,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from TTP7 to TTP8, through CCPz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_TTP7CCPzTTP8 = curve_gen(TTP7, TTP8, CCPz, surf, dt);
[foo, iCCPz] = nearest_point(curve_pts_TTP7CCPzTTP8, CCPz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from TTP7 to CCPz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_TTP7CCPz = {'TTP7h'; 'CCP5'; 'CCP5h'; 'CCP3'; 'CCP3h'; 'CCP1'; 'CCP1h'};
refpts_TTP7CCPz = calcRefptsAlongCurve(curve_pts_TTP7CCPzTTP8(1:iCCPz,:), 0, labels_TTP7CCPz, stepsize2, 'TTP7-CCPz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from TTP8 to CCPz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_TTP8CCPz = {'TTP8h'; 'CCP6'; 'CCP6h'; 'CCP4'; 'CCP4h'; 'CCP2'; 'CCP2h'};
refpts_TTP8CCPz = calcRefptsAlongCurve(curve_pts_TTP7CCPzTTP8(end:-1:iCCPz,:), 0, labels_TTP8CCPz, stepsize2, 'TTP8-CCPz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TP7-CPz-TP8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TP7 = refpts_T7Oz(2,:);
TP8 = refpts_T8Oz(2,:);
CPz = refpts_NzCziIz(12,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from TP7 to TP8, through CPz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_TP7CPzTP8 = curve_gen(TP7, TP8, CPz, surf, dt);
[foo, iCPz] = nearest_point(curve_pts_TP7CPzTP8, CPz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from TP7 to CPz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_TP7CPz = {'TP7h'; 'CP5'; 'CP5h'; 'CP3'; 'CP3h'; 'CP1'; 'CP1h'};
refpts_TP7CPz = calcRefptsAlongCurve(curve_pts_TP7CPzTP8(1:iCPz,:), 0, labels_TP7CPz, stepsize2, 'TP7-CPz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from TP8 to CPz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_TP8CPz = {'TP8h'; 'CP6'; 'CP6h'; 'CP4'; 'CP4h'; 'CP2'; 'CP2h'};
refpts_TP8CPz = calcRefptsAlongCurve(curve_pts_TP7CPzTP8(end:-1:iCPz,:), 0, labels_TP8CPz, stepsize2, 'TP8-CPz');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TPP7-CPPz-TPP8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TPP7 = refpts_T7Oz(3,:);
TPP8 = refpts_T8Oz(3,:);
CPPz = refpts_NzCziIz(13,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from TPP7 to TPP8, through CPPz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_TPP7CPPzTPP8 = curve_gen(TPP7, TPP8, CPPz, surf, dt);
[foo, iCPPz] = nearest_point(curve_pts_TPP7CPPzTPP8, CPPz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from TPP7 to CPPz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_TPP7CPPz = {'TPP7h'; 'CPP5'; 'CPP5h'; 'CPP3'; 'CPP3h'; 'CPP1'; 'CPP1h'};
refpts_TPP7CPPz = calcRefptsAlongCurve(curve_pts_TPP7CPPzTPP8(1:iCPPz,:), 0, labels_TPP7CPPz, stepsize2, 'TPP7-CPPz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from TPP8 to CPPz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_TPP8CPPz = {'TPP8h'; 'CPP6'; 'CPP6h'; 'CPP4'; 'CPP4h'; 'CPP2'; 'CPP2h'};
refpts_TPP8CPPz = calcRefptsAlongCurve(curve_pts_TPP7CPPzTPP8(end:-1:iCPPz,:), 0, labels_TPP8CPPz, stepsize2, 'TPP8-CPPz');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P7-Pz-P8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P7 = refpts_T7Oz(4,:);
P8 = refpts_T8Oz(4,:);
Pz = refpts_NzCziIz(14,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from P7 to P8, through Pz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_P7PzP8 = curve_gen(P7, P8, Pz, surf, dt);
[foo, iPz] = nearest_point(curve_pts_P7PzP8, Pz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from P7 to Pz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_P7Pz = {'P7h'; 'P5'; 'P5h'; 'P3'; 'P3h'; 'P1'; 'P1h'};
refpts_P7Pz = calcRefptsAlongCurve(curve_pts_P7PzP8(1:iPz,:), 0, labels_P7Pz, stepsize2, 'P7-Pz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from P8 to Pz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_P8Pz = {'P8h'; 'P6'; 'P6h'; 'P4'; 'P4h'; 'P2'; 'P2h'};
refpts_P8Pz = calcRefptsAlongCurve(curve_pts_P7PzP8(end:-1:iPz,:), 0, labels_P8Pz, stepsize2, 'P8-Pz');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PPO7-PPOz-PPO8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PPO7 = refpts_T7Oz(5,:);
PPO8 = refpts_T8Oz(5,:);
PPOz = refpts_NzCziIz(15,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from PPO7 to PPO8, through PPOz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_PPO7PPOzPPO8 = curve_gen(PPO7, PPO8, PPOz, surf, dt);
[foo, iPPOz] = nearest_point(curve_pts_PPO7PPOzPPO8, PPOz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from PPO7 to PPOz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_PPO7PPOz = {'PPO7h'; 'PPO5'; 'PPO5h'; 'PPO3'; 'PPO3h'; 'PPO1'; 'PPO1h'};
refpts_PPO7PPOz = calcRefptsAlongCurve(curve_pts_PPO7PPOzPPO8(1:iPPOz,:), 0, labels_PPO7PPOz, stepsize2, 'PPO7-PPOz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from PPO8 to PPOz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_PPO8PPOz = {'PPO8h'; 'PPO6'; 'PPO6h'; 'PPO4'; 'PPO4h'; 'PPO2'; 'PPO2h'};
refpts_PPO8PPOz = calcRefptsAlongCurve(curve_pts_PPO7PPOzPPO8(end:-1:iPPOz,:), 0, labels_PPO8PPOz, stepsize2, 'PPO8-PPOz');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PO7-POz-PO8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PO7 = refpts_T7Oz(6,:);
PO8 = refpts_T8Oz(6,:);
POz = refpts_NzCziIz(16,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from PO7 to PO8, through POz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_PO7POzPO8 = curve_gen(PO7, PO8, POz, surf, dt);
[foo, iPOz] = nearest_point(curve_pts_PO7POzPO8, POz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from PO7 to POz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_PO7POz = {'PO7h'; 'PO5'; 'PO5h'; 'PO3'; 'PO3h'; 'PO1'; 'PO1h'};
refpts_PO7POz = calcRefptsAlongCurve(curve_pts_PO7POzPO8(1:iPOz,:), 0, labels_PO7POz, stepsize2, 'PO7-POz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from PO8 to POz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_PO8POz = {'PO8h'; 'PO6'; 'PO6h'; 'PO4'; 'PO4h'; 'PO2'; 'PO2h'};
refpts_PO8POz = calcRefptsAlongCurve(curve_pts_PO7POzPO8(end:-1:iPOz,:), 0, labels_PO8POz, stepsize2, 'PO8-POz');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% POO7-POOz-POO8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
POO7 = refpts_T7Oz(7,:);
POO8 = refpts_T8Oz(7,:);
POOz = refpts_NzCziIz(17,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from POO7 to POO8, through POOz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_POO7POOzPOO8 = curve_gen(POO7, POO8, POOz, surf, dt);
[foo, iPOOz] = nearest_point(curve_pts_POO7POOzPOO8, POOz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from POO7 to POOz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_POO7POOz = {'POO5'; 'POO3'; 'POO1'};
refpts_POO7POOz = calcRefptsAlongCurve(curve_pts_POO7POOzPOO8(1:iPOOz,:), 0, labels_POO7POOz, 2*stepsize2, 'POO7-POOz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from POO8 to POOz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels_POO8POOz = {'POO6'; 'POO4'; 'POO2'};
refpts_POO8POOz = calcRefptsAlongCurve(curve_pts_POO7POOzPOO8(end:-1:iPOOz,:), 0, labels_POO8POOz, 2*stepsize2, 'POO8-POOz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assemble all the points and labels together into one array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
switch(eeg_system)
    
    case '10-20'
        pos = [...
               Nz; Iz; RPA; LPA; Cz; ...
               refpts_NzCziIz(2:4:end-1,:); ...
               refpts_LPACzRPA(3:4:end-2,:); ...
               refpts_FpzT7(2:4:end,:); ...
               refpts_T7Oz([4,8],:); ...
               refpts_FpzT8(2:4:end,:); ...
               refpts_T8Oz([4,8],:); ...
               refpts_F7Fz(4,:); ...
               refpts_F8Fz(4,:); ...
               refpts_P7Pz(4,:); ...
               refpts_P8Pz(4,:); ...
              ];
        labels = [...
               'Nz'; 'Iz'; 'RPA'; 'LPA'; 'Cz'; ...
               labels_NzCziIz(2:4:end-1); ...
               labels_LPACzRPA(3:4:end-2); ...
               labels_FpzT7(2:4:end); ...
               labels_T7Oz([4,8]); ...
               labels_FpzT8(2:4:end); ...
               labels_T8Oz([4,8]); ...
               labels_F7Fz(4); ...
               labels_F8Fz(4); ...
               labels_P7Pz(4); ...
               labels_P8Pz(4); ...
              ];
          
    case '10-10'
        
        pos = [...
               Nz; Iz; RPA; LPA; Cz; ...
               refpts_NzCziIz(2:2:end-1,:); ...
               refpts_LPACzRPA(1:2:end,:); ...
               refpts_NzT10(2:2:end-1,:); ...
               refpts_T10Iz(2:2:end-1,:); ...
               refpts_NzT9(2:2:end-1,:); ...
               refpts_T9Iz(2:2:end-1,:); ...
               refpts_FpzT7(2:2:end-1,:); ...
               refpts_T7Oz(2:2:end-1,:); ...
               refpts_FpzT8(2:2:end-1,:); ...
               refpts_T8Oz(2:2:end-1,:); ...
               refpts_AF7AFz(4,:); ...
               refpts_AF8AFz(4,:); ...               
               refpts_F7Fz(2:2:end-1,:); ...
               refpts_F8Fz(2:2:end-1,:); ...
               refpts_FT7FCz(2:2:end-1,:); ...
               refpts_FT8FCz(2:2:end-1,:); ...
               refpts_TP7CPz(2:2:end-1,:); ...
               refpts_TP8CPz(2:2:end-1,:); ...
               refpts_P7Pz(2:2:end-1,:); ...
               refpts_P8Pz(2:2:end-1,:); ...
               refpts_PO7POz(4,:); ...
               refpts_PO8POz(4,:); ...
              ];
        labels = [...
               'Nz'; 'Iz'; 'RPA'; 'LPA'; 'Cz'; ...
               labels_NzCziIz(2:2:end-1); ...
               labels_LPACzRPA(1:2:end); ...
               labels_NzT10(2:2:end-1); ...
               labels_T10Iz(2:2:end-1); ...
               labels_NzT9(2:2:end-1); ...
               labels_T9Iz(2:2:end-1); ...
               labels_FpzT7(2:2:end-1); ...
               labels_T7Oz(2:2:end-1); ...
               labels_FpzT8(2:2:end-1); ...
               labels_T8Oz(2:2:end-1); ...
               labels_AF7AFz(4); ...
               labels_AF8AFz(4); ...               
               labels_F7Fz(2:2:end-1); ...
               labels_F8Fz(2:2:end-1); ...
               labels_FT7FCz(2:2:end-1); ...
               labels_FT8FCz(2:2:end-1); ...
               labels_TP7CPz(2:2:end-1); ...
               labels_TP8CPz(2:2:end-1); ...
               labels_P7Pz(2:2:end-1); ...
               labels_P8Pz(2:2:end-1); ...
               labels_PO7POz(4); ...
               labels_PO8POz(4); ...
              ];
          
    case '10-5'
        
        pos = [...
               Nz; Iz; RPA; LPA; Cz; ...
               refpts_NzCziIz; ...
               refpts_LPACzRPA;...
               refpts_NzT10; ...
               refpts_T10Iz; ...
               refpts_NzT9; ...
               refpts_T9Iz; ...
               refpts_NFpzT9h; ...
               refpts_T9hOIz; ...
               refpts_NFpzT10h; ...
               refpts_T10hOIz; ...
               refpts_FpzT7; ...
               refpts_T7Oz; ...
               refpts_FpzT8; ...
               refpts_T8Oz; ...
               refpts_AFp8AFpz; ...
               refpts_AFp7AFpz; ...
               refpts_AF7AFz; ...
               refpts_AF8AFz; ...
               refpts_AFF7AFFz; ...
               refpts_AFF8AFFz; ...
               refpts_F7Fz; ...
               refpts_F8Fz; ...
               refpts_FFT7FFCz; ...
               refpts_FFT8FFCz; ...
               refpts_FT7FCz; ...
               refpts_FT8FCz; ...
               refpts_FTT7FCCz; ...
               refpts_FTT8FCCz; ...
               refpts_TTP7CCPz; ...
               refpts_TTP8CCPz; ...
               refpts_TP7CPz; ...
               refpts_TP8CPz; ...
               refpts_TPP7CPPz; ...
               refpts_TPP8CPPz; ...
               refpts_P7Pz; ...
               refpts_P8Pz; ...
               refpts_PPO7PPOz; ...
               refpts_PPO8PPOz; ...
               refpts_PO7POz; ...
               refpts_PO8POz; ...
               refpts_POO7POOz; ...
               refpts_POO8POOz; ...
              ];
         
           labels = [...
               'Nz'; 'Iz'; 'RPA'; 'LPA'; 'Cz'; ...
               labels_NzCziIz; ...
               labels_LPACzRPA; ...
               labels_NzT10; ...
               labels_T10Iz; ...
               labels_NzT9; ...
               labels_T9Iz; ...
               labels_NFpzT9h; ...
               labels_T9hOIz; ...
               labels_NFpzT10h; ...
               labels_T10hOIz; ...
               labels_FpzT7; ...
               labels_T7Oz; ...
               labels_FpzT8; ...
               labels_T8Oz; ...
               labels_AFp8AFpz; ...
               labels_AFp7AFpz; ...
               labels_AF7AFz; ...
               labels_AF8AFz; ...
               labels_AFF7AFFz; ...
               labels_AFF8AFFz; ...
               labels_F7Fz; ...
               labels_F8Fz; ...
               labels_FFT7FFCz; ...
               labels_FFT8FFCz; ...
               labels_FT7FCz; ...
               labels_FT8FCz; ...
               labels_FTT7FCCz; ...
               labels_FTT8FCCz; ...
               labels_TTP7CCPz; ...
               labels_TTP8CCPz; ...
               labels_TP7CPz; ...
               labels_TP8CPz; ...
               labels_TPP7CPPz; ...
               labels_TPP8CPPz; ...
               labels_P7Pz; ...
               labels_P8Pz; ...
               labels_PPO7PPOz; ...
               labels_PPO8PPOz; ...
               labels_PO7POz; ...
               labels_PO8POz; ...
               labels_POO7POOz; ...
               labels_POO8POOz; ...
              ];
end


% Throw out redundant ref pts
k = find(strcmp(labels, 'dummy'));
pos(k,:) = [];
labels(k) = [];

% Make sure output type matches input type
if isstruct(refpts)
    refpts.pos = pos;
    refpts.labels = labels;
    if length(labels)>=50 & length(labels)<=100
        refpts.size = 9;
    elseif length(labels)>100
        refpts.size = 8;
    end
else
    refpts = pos;
end

err = false;

