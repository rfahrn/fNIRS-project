function vol=isolatehead(vol,threshold)

%
% USAGE:
%
%    vol=isolatehead(vol,threshold)
%
% DESCRIPTION:
%
%    Function takes a MRI volume scan, labels all 
%    regions and zeros out all but the largest region 
%    (usually the head in an MR scan of the head). The
%    resulting image is a scan of the head with no noise 
%    or any other objects that appear in the original 
%    scan (such as fiducial markers).
%
% INPUTS:
%         
%    vol: MRI volume scan
%
%    threshold: Optional argument. By default the function assumes 
%               noise has been cleared from the volume. If not the 
%               user has the option of passing a threshold value 
%               below which a voxel value will be considered noisy 
%               and set to zero. 
%
% EXAMPLE 1:
%
%     i=find(vol<25);
%     vol(i)=0;
%     vol = isolatehead(vol);
%
% EXAMPLE 2:
%
%     vol = isolatehead(vol,25);
%
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   12/18/2012
%  

if(~exist('threshold','var'))
    threshold = mean(vol(:));
    disp(sprintf('Threshold: %d',uint32(threshold)));
end

i=find(vol<threshold);
vol(i)=0;

h = waitbar(0,'Reducing noise. Please wait...');
volmask  = vol2constvol(vol);
volmask  = bwlabeln(volmask);
vals = unique(volmask);
n = size(vals, 1);
int = round(n/100);
s = [];
for i=1:n
    if mod(i,int)==0
        waitbar(i/n, h, sprintf('Noise reduction %d%% complete...',uint8(100*(i/n))));
    end

    if(vals(i) == 0)
        continue;
    end

    j = find(volmask == vals(i));
    s(vals(i)) = length(j);
end
val = find(s == max(s));
inoise = find(volmask ~= val);
volmask(inoise) = 0;
i = find(volmask == 0);
vol(i) = 0;
close(h);

% Make sure head isn't touching the volume boundaries
% This causes all kinds of problems in image processing 
[nx,ny,nz]=size(vol);
vol(1:5,:,:)=0;
vol(nx-5:nx,:,:)=0;
vol(:,1:5,:)=0;
vol(:,ny-5:ny,:)=0;
vol(:,:,1:5)=0;
vol(:,:,nz-5:nz)=0;

