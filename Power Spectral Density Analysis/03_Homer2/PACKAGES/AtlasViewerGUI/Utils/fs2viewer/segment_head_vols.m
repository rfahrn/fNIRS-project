function [hseg tiss_type] = segment_head_vols(head, skull, csf, gm, wm, mode)

%
% USAGE:
%
%    [hseg tiss_type] = segment_head_vols(head, skull, csf, gm, wm, mode)
% 
%
% DESCRIPTION: 
% 
%    head:     head volume 
%
%    skull:    skull volume 
%
%    csf:      csf volume 
%
%    gm:       gray matter volume 
%
%    wm:       white matter volume 
% 
%    mode: Optional - {'fill','nofill'}. 'nofill' option will run much 
%          faster because the head volume is assumed to have no gaps and  
%          therefore no gap filling is perfomed.
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   12/18/2012
%  

hseg = [];
tiss_type = {};

head = uint8(head);
skull = uint8(skull);
csf = uint8(csf);
gm = uint8(gm);
wm = uint8(wm);
if ~exist('mode','var')
    mode='fill';
end
s = 1;

% Put all volumes together to make a segmented head
% white matter volume
% skin volume
if(~isempty(head))
    hseg = head;
    i = find(hseg > 0);
    hseg(i) = 1;      

    if strcmp(mode,'fill')
        h = waitbar(0,'Filling gaps in segmented volume. This will take a few minutes...');
        se = strel('ball',20, 10);
        waitbar(1/3, h, sprintf('Filling gaps in segmented volume...%d%% completed',uint8(100*(1/3))));
        hseg = imclose(hseg, se);
        waitbar(2/3, h, sprintf('Filling gaps in segmented volume...%d%% completed',uint8(100*(2/3))));
        hseg = imfill(hseg, 'holes');
        waitbar(3/3, h, sprintf('Filling gaps in segmented volume...%d%% completed',uint8(100*(3/3))));
        close(h);
    end
    i = find(hseg < .7 & hseg > 0);
    hseg(i) = 0;

    i = find(hseg > 0);
    hseg(i) = s;

    tiss_type{s}='scalp';
    s=s+1;
end

% bone volume
if(~isempty(skull))
    if(~exist('hseg'))
        hseg = skull;
    end

    % Once in a while surface2volume leaves strange small gaps in 
    % the volume. To get rif of those we use fillholes.m with a 
    % small size threshold. imfill can't be used because the holes
    % might not be closed
    skull_i = find(skull ~= 0);
    hseg(skull_i) = s;
    tiss_type{s}='skull';
    s=s+1;
end

% csf volume
if(~isempty(csf))
    if(~exist('hseg'))
        hseg = csf;
    end

    csf_i = find(csf ~= 0);
    hseg(csf_i) = s;
    tiss_type{s}='csf';
    s=s+1;
end

% gray matter volume
if(~isempty(gm))
    if(~exist('hseg'))
        hseg = gm;
    end

    gm_i = find(gm ~= 0);
    hseg(gm_i) = s;
    tiss_type{s}='gm';
    s=s+1;
end

% white matter volume
if(~isempty(wm))
    if(~exist('hseg'))
        hseg = wm;
    end

    wm_i = find(wm ~= 0);
    hseg(wm_i) = s;
    tiss_type{s}='wm';
    s=s+1;
end
    
% Make sure head isn't touching the volume boundaries
% This causes all kinds of problems in image processing 
[nx,ny,nz]=size(hseg);
hseg(1:5,:,:)=0;
hseg(nx-5:nx,:,:)=0;
hseg(:,1:5,:)=0;
hseg(:,ny-5:ny,:)=0;
hseg(:,:,1:5)=0;
hseg(:,:,nz-5:nz)=0;

