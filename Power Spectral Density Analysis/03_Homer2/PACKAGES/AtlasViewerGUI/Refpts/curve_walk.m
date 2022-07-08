function [pf len_tot] = curve_walk(curve_seg, len)

% USAGE:
%
%    [pf len_tot] = curve_walk(curve_seg, len)
%
% DESCRIPTION:
%    
%    Traverse the curve curve_seg the length of len and return 
%    the coordinates of the point, pf, on which the traversal ends.
%    Also return the distance actually traversed. 
%
%    Do this by summing all the straight-line distances between the 
%    ordered set of points in curve_seg. The first argument curve_seg 
%    must have the property that the array order of each point 
%    corresponds that point's geometric place in the curve. 
%
% EXAMPLE:
%    
%    [Cz  len] = curve_walk(curve_pts_NzIz, 5*len_NzIz/10);
%    
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   2/9/2010


len_tot=0;
for i=1:size(curve_seg,1)-1
    d=dist3(curve_seg(i,:), curve_seg(i+1,:));
    len_tot=len_tot+d;
    if(len_tot>=len)
        break;
    end
end
pf=curve_seg(i,:);
