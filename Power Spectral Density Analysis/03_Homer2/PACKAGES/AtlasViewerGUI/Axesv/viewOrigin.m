function viewOrigin(hAxes, mode)

hOrigin = getappdata(hAxes, 'hOrigin');

if ~exist('mode','var')
    mode = 'redraw';
end
axes(hAxes); hold on
hViewOrigin = getappdata(hAxes, 'hViewOrigin');
onoff = get(hViewOrigin,'checked');

s = 64;
if strcmp(mode,'redraw')
    if ishandles(hOrigin)
        delete(hOrigin);
    end
    
    hxcoord = line([s,-s], [0,0], [0,0], 'color','m'); hold on
    hycoord = line([0,0], [s,-s], [0,0], 'color',[.2,.6,.1]); hold on
    hzcoord = line([0,0], [0,0], [s,-s], 'color',[.2,.1,.6]); hold on
    hxt = text(s,0,0, 'x','fontweight','bold','color','m'); hold on
    hyt = text(0,s,0, 'y','fontweight','bold','color',[.2,.6,.1]); hold on
    hzt = text(0,0,s, 'z','fontweight','bold','color',[.2,.1,.6]); hold on
    hOrigin = [hxcoord, hycoord, hzcoord, hxt, hyt, hzt];
       
    axislimits = get(gca, {'xlim','ylim','zlim'});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

setappdata(hAxes, 'hOrigin', hOrigin);
if ishandles(hOrigin)
    if strcmp(onoff, 'on')
        set(hOrigin, 'visible','on');
        
        % Set axis limits so that origin is visible
        setAxisLimits(s);
    elseif strcmp(onoff, 'off')
        set(hOrigin, 'visible','off');
    end
end




% ------------------------------------------------------------------------
function setAxisLimits(s)

alim = get(gca, {'xlim','ylim','zlim'});
xlim = alim{1};
ylim = alim{2};
zlim = alim{3};

if xlim(1) > -s
    xlim(1) = -s-20;
end
if xlim(2) < s
    xlim(2) = s+20;
end
if ylim(1) > -s
    ylim(1) = -s-20;
end
if ylim(2) < s
    ylim(2) = s+20;
end
if zlim(1) > -s
    zlim(1) = -s-20;
end
if zlim(2) < s
    zlim(2) = s+20;
end

set(gca,'xlim',xlim);
set(gca,'ylim',ylim);
set(gca,'zlim',zlim);


