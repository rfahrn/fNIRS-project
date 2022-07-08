function [refpts, pos] = updateRefpts(refpts, headsurf, labels, hAxes)

pos=[];
pos0 = headsurf.currentPt;
if size(pos0,1)<length(labels)
    return;
end

% Get real coordinates of pos0 by unflipping left-right if they were flipped. 
if leftRightFlipped(headsurf)
    axes_order=[2 1 3];
else
    axes_order=[1 2 3];
end
pos = [pos0(:,axes_order(1)), pos0(:,axes_order(2)), pos0(:,axes_order(3))];

if ~exist('hAxes','var')
    hAxes=[];
else
    axes(hAxes);
    hold on;
end
for ii=1:length(labels)
    labelfound=false;
    for jj=1:length(refpts.labels)
        if strcmpi(labels{ii}, refpts.labels{jj})
            labelfound=true;
            refpts.pos(jj,:) = pos(ii,:);
            refpts.handles.selected(jj) = markSelectedPt(refpts.handles.selected(jj), pos(ii,:), headsurf.orientation, hAxes);
        end
    end
    if ~labelfound        
        refpts.pos(end+1,:) = pos(ii,:);
        refpts.labels{end+1} = labels{ii};
        if isempty(refpts.handles.selected)
            refpts.handles.selected(1) = -1;
            refpts.handles.selected(1) = markSelectedPt(refpts.handles.selected(1), pos(ii,:), headsurf.orientation, hAxes);
        else
            refpts.handles.selected(end+1) = -1;
            refpts.handles.selected(end) = markSelectedPt(refpts.handles.selected(end), pos(ii,:), headsurf.orientation, hAxes);
        end
    end
end





% -------------------------------------------------------------------------
function hp = markSelectedPt(hp, p, orientation, hAxes)

% Display function needs to know how to order axes so left-right sides 
% appear correctly
if leftRightFlipped(orientation)
    axes_order=[2 1 3];
else
    axes_order=[1 2 3];
end
p = [p(axes_order(1)), p(axes_order(2)), p(axes_order(3))];

if hp==0
    hp=-1;
end
if ishandles(hp)
    delete(hp);
    hp = -1;
end
if ishandles(hAxes)
    hp = plot3(p(1), p(2), p(3), '.m','markersize',30);
end

