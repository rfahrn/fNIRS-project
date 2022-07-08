function [curve_seg len gap] = curve_gen(p1, p2, p3, surf, dt, neighbdist)

%
% USAGE:
%
%    [curve_seg len] = curve_gen(p1, p2, p3, plane, surf, dt)
%
% DESCRIPTION:
%    
%    Find the set of points in surf which lie approximately on the 
%    line of intersection formed by the aurgumant plane and surf. The 
%    output paramter curve_seg is a subset of this set of points 
%    limited to the point lying on the curve segment [p1,p3,p2].
%
% EXAMPLE:
%
%    [curve_pts_NzIz len_NzIz] = curve_gen(Nz, Iz, Cz, surf, .3);
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   2/9/2010
%

if ~exist('neighbdist', 'var')
    neighbdist = 4;
end
MIN_NEIGHBOR_DIST = neighbdist/meshdensity(surf);

if ~exist('dt') || isempty(dt)
    dt=.5;
end

% Generate curve using optimul distance threshhold (dt) from plane of 
% intersection to points on the surface. Optimal distance threshhold
% is one that produces a set of curve points with the smallest gaps 
% in between points that make it up.

plane = plane_equation(p1, p2, p3);
[curve_pts icurve] = plane_surf_intersect(plane, surf, dt);
[curve_seg len gap] = find_curve_path(p1, p2, p3, curve_pts);

% Throw away points which are too close and fill in points on 
% lines segments connecting the included points. 
[curve_seg len gap] = gen_sparcer_curve(curve_seg, MIN_NEIGHBOR_DIST, surf);
curve_seg(end,:) = p2;
