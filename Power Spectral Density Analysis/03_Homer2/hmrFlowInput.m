% dod = hmrFlowInput( d )
%
% UI NAME
% Intensity_Normalized
%
%
% INPUT
% d - intensity data (#time points x #data channels)
%
% OUTPUT
% dod - the intensity divided by the mean

function dod = hmrFlowInput( d )

% flow (fisrt half)
dod = d;
dod(:,1:size(d,2)/2) = dod(:,1:size(d,2)/2) * 1e8;

% convert intensity to optical density (second half)
dm = mean(abs(d),1);
nTpts = size(d,1);
for i = size(d,2)/2+1:size(d,2)
dod(:,i) = -log(abs(d(:,i))./(ones(nTpts,1)*dm(i)));
end
