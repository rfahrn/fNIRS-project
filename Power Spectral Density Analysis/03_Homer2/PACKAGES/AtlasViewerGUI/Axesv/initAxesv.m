function axesv = initAxesv(handles, mode)

if ~exist('handles','var')
    axesv = struct(...
        'name', 'axesv', ...
        'handles', struct(...
              'axesSurfDisplay', [], ...
              'panelRotate', [], ...
              'menuItemLight1',[], ...
              'menuItemLight2',[], ...
              'menuItemLight3',[], ...
              'menuItemLight4',[], ...
              'menuItemLight5',[], ...
              'menuItemLight6',[], ...
              'menuItemLight7',[], ...
              'menuItemLight8',[], ...
              'menuItemViewOrigin',[], ...
              'lighting', [], ...
              'pushbuttonRotVerticalLeft', [], ...
              'pushbuttonRotVerticalRight', [], ...
              'pushbuttonRotUp', [], ...
              'pushbuttonRotDown', [], ...
              'pushbuttonRotHorizontalLeft', [], ...
              'pushbuttonRotHorizontalRight', [], ...
              'pushbuttonZoomIn', [], ...
              'pushbuttonZoomOut', [], ...
              'editDegRotation', [], ...
              'axes',[] ...
        ), ...
        'zoominitfactor', 5, ...
        'zoomincr', 1.2, ...
        'rotation', struct('degrees',10), ...
        'lighting', ones(8,2), ...
        'campos', [], ...
        'cameraupvector',[0 1 0], ...
        'mode', 'surface', ...
        'checkCompatability',@checkCompatability, ...
        'prepObjForSave',[] ...
        );
    return;
end

if ~exist('mode','var') | isempty(mode)
    mode=0;
end

if isunix() | ismac()
    fontsize_RotLRBttn = 12;
    fontsize_RotBttn = 14;
elseif ispc()
    fontsize_RotLRBttn = 10;
    fontsize_RotBttn = 12;
end

axesv = struct(...
               'name', 'axesv', ...
               'handles', struct(...
                                 'axesSurfDisplay', handles.axesSurfDisplay, ...
                                 'panelRotate', handles.panelRotateZoomAxes, ...
                                 'menuItemLight1',handles.menuItemLight1, ...
                                 'menuItemLight2',handles.menuItemLight2, ...
                                 'menuItemLight3',handles.menuItemLight3, ...
                                 'menuItemLight4',handles.menuItemLight4, ...
                                 'menuItemLight5',handles.menuItemLight5, ...
                                 'menuItemLight6',handles.menuItemLight6, ...
                                 'menuItemLight7',handles.menuItemLight7, ...
                                 'menuItemLight8',handles.menuItemLight8, ...
                                 'menuItemViewOrigin',handles.menuItemViewOrigin, ...
                                 'lighting', [], ...
                                 'pushbuttonRotVerticalLeft', [], ...
                                 'pushbuttonRotVerticalRight', [], ...
                                 'pushbuttonRotUp', [], ...
                                 'pushbuttonRotDown', [], ...
                                 'pushbuttonRotHorizontalLeft', [], ...
                                 'pushbuttonRotHorizontalRight', [], ...
                                 'pushbuttonZoomIn', handles.pushbuttonZoomIn, ...
                                 'pushbuttonZoomOut', handles.pushbuttonZoomOut, ...
                                 'editDegRotation', [], ...
                                 'axes',[] ...
                                ), ...
               'zoominitfactor', 5, ...
               'zoomincr', 1.2, ...
               'rotation', struct('degrees',10), ...
               'lighting', ones(8,2), ...
               'campos', [], ...
               'cameraupvector',[0 1 0], ... 
               'mode', 'surface', ...
               'checkCompatability',[], ...
               'prepObjForSave',[] ...
              );

if mode==0
    persistent hPushbuttonRotVerticalLeft;
    persistent hPushbuttonRotVerticalRight;
    persistent hPushbuttonRotHorizontalLeft;
    persistent hPushbuttonRotHorizontalRight;
    persistent hPushbuttonRotUp;
    persistent hPushbuttonRotDown;
    persistent hEditDegRotation;
else
    hPushbuttonRotVerticalLeft=[];
    hPushbuttonRotVerticalRight=[];
    hPushbuttonRotHorizontalLeft=[];
    hPushbuttonRotHorizontalRight=[];
    hPushbuttonRotUp=[];
    hPushbuttonRotDown=[];
    hEditDegRotation=[];
end

hPanelRotate = handles.panelRotateZoomAxes;

poffsetx = -.15;
px1 = .180+poffsetx;
px2 = .200+poffsetx;
px3 = .400+poffsetx;
px4 = .570+poffsetx;
px5 = .620+poffsetx;

poffsety = -.01;
py1 = .100+poffsety;
py2 = .400+poffsety;
py3 = .700+poffsety;

soffsetx = +.02;
sx1 = .150+soffsetx;
sx2 = .180+soffsetx;

soffsety = -.02;
sy1 = .250+soffsety;

if ~ishandles(hPushbuttonRotVerticalLeft)
    hPushbuttonRotVerticalLeft = ...
        uicontrol('parent',hPanelRotate, 'style','pushbutton', 'tag','pushbuttonRotVerticalLeft','string','Rot L',...
                  'units','normalized','position', [px2 py3 sx2 sy1],'fontweight','bold',...
                  'fontsize',fontsize_RotLRBttn,'enable','on','callback',@pushbuttonRotVerticalLeft_Callback);
end

if ~ishandles(hPushbuttonRotVerticalRight)
    hPushbuttonRotVerticalRight = ...
        uicontrol('parent',hPanelRotate, 'style','pushbutton', 'tag','pushbuttonRotVerticalRight','string','Rot R',...
                  'units','normalized','position', [px4 py3 sx2 sy1],'fontweight','bold',...
                  'fontsize',fontsize_RotLRBttn,'enable','on','callback',@pushbuttonRotVerticalRight_Callback);
end

if ~ishandles(hPushbuttonRotUp)
    hPushbuttonRotUp = ...
        uicontrol('parent',hPanelRotate, 'style','pushbutton', 'tag','pushbuttonRotUp',...
                  'string','/\', 'units','normalized',...
                  'position', [px3 py3 sx1 sy1],'fontweight','bold','fontsize',fontsize_RotBttn,...
                  'fontweight','bold','enable','on','callback',@pushbuttonRotUp_Callback);
end

if ~ishandles(hPushbuttonRotDown)
    hPushbuttonRotDown = ...
        uicontrol('parent',hPanelRotate, 'style','pushbutton', 'tag','pushbuttonRotDown',...
                  'string','\/', 'units','normalized',...
                  'position', [px3 py1 sx1 sy1],'fontweight','bold','fontsize',fontsize_RotBttn,...
                  'fontweight','bold','enable','on','callback',@pushbuttonRotDown_Callback);
end

if ~ishandles(hPushbuttonRotHorizontalLeft)
    hPushbuttonRotHorizontalLeft = ...
        uicontrol('parent',hPanelRotate, 'style','pushbutton',  'tag','pushbuttonRotHorizontalLeft',...
                  'string','<','units','normalized',...
                  'position',[px1 py2 sx1 sy1],'fontweight','bold','fontsize',fontsize_RotBttn,'enable','on',...
                  'fontweight','bold','callback',@pushbuttonRotHorizontalLeft_Callback);
end


if ~ishandles(hPushbuttonRotHorizontalRight)
    hPushbuttonRotHorizontalRight = ...
        uicontrol('parent',hPanelRotate, 'style','pushbutton', 'tag','pushbuttonRotHorizontalRight',...
                  'string','>', 'units','normalized',...
                  'position', [px5 py2 sx1 sy1],'fontweight','bold','fontsize',fontsize_RotBttn,'enable','on',...
                  'fontweight','bold','callback',@pushbuttonRotHorizontalRight_Callback);
end

if ~ishandles(hEditDegRotation)
    hEditDegRotation = ...
        uicontrol('parent',hPanelRotate,'style','edit','tag','editDegRotation',...
                  'string',num2str(axesv.rotation.degrees),'units','normalized',...
                  'position',[px3 py2 sx1 sy1],'enable','on','callback',@editDegRotation_Callback);              
end


cla(handles.axesSurfDisplay,'reset');
set(handles.axesSurfDisplay,{'xgrid','ygrid','zgrid'},{'on','on','on'});
set(handles.axesSurfDisplay,'visible','off');
set(handles.axesSurfDisplay,'cameraviewangle', axesv.zoominitfactor);

axesv.rotation.degrees                     = str2num(get(hEditDegRotation,'string'));
axesv.handles.panelRotate                  = handles.panelRotateZoomAxes;
axesv.handles.pushbuttonRotVerticalLeft    = hPushbuttonRotVerticalLeft;
axesv.handles.pushbuttonRotVerticalRight   = hPushbuttonRotVerticalRight;
axesv.handles.pushbuttonRotUp              = hPushbuttonRotUp;
axesv.handles.pushbuttonRotDown            = hPushbuttonRotDown;
axesv.handles.pushbuttonRotHorizontalLeft  = hPushbuttonRotHorizontalLeft;
axesv.handles.pushbuttonRotHorizontalRight = hPushbuttonRotHorizontalRight;
axesv.handles.editDegRotation              = hEditDegRotation;
axesv.handles.axesSurfDisplay              = handles.axesSurfDisplay;

setappdata(axesv.handles.axesSurfDisplay, 'hOrigin',[]);
setappdata(axesv.handles.axesSurfDisplay, 'hViewOrigin',handles.menuItemViewOrigin);

axes(axesv.handles.axesSurfDisplay);


% --------------------------------------------------------------------
function pushbuttonRotVerticalLeft_Callback(hObject, eventdata, handles)
global atlasViewer;
axesv = atlasViewer.axesv;
ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.pushbuttonRotVerticalLeft)
        if hObject==axesv(ii).handles.pushbuttonRotVerticalLeft
            ax=axesv(ii);
        end
    end
end
if ~isempty(ax)
    rotVerticalLeft(ax);
end



% --------------------------------------------------------------------
function pushbuttonRotVerticalRight_Callback(hObject, eventdata, handles)
global atlasViewer;
axesv = atlasViewer.axesv;
ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.pushbuttonRotVerticalRight)
        if hObject==axesv(ii).handles.pushbuttonRotVerticalRight
            ax=axesv(ii);
        end
    end
end
if ~isempty(ax)
    rotVerticalRight(ax);
end


% --------------------------------------------------------------------
function pushbuttonRotUp_Callback(hObject, eventdata, handles)
global atlasViewer;
axesv = atlasViewer.axesv;
ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.pushbuttonRotUp)
        if hObject==axesv(ii).handles.pushbuttonRotUp
            ax=axesv(ii);
        end
    end
end
if ~isempty(ax)
    rotUp(ax);
end


% --------------------------------------------------------------------
function pushbuttonRotDown_Callback(hObject, eventdata, handles)
global atlasViewer;
axesv = atlasViewer.axesv;
ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.pushbuttonRotDown)
        if hObject==axesv(ii).handles.pushbuttonRotDown
            ax=axesv(ii);
        end
    end
end
if ~isempty(ax)
    rotDown(ax);
end


% --------------------------------------------------------------------
function pushbuttonRotHorizontalLeft_Callback(hObject, eventdata, handles)
global atlasViewer;
axesv = atlasViewer.axesv;
ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.pushbuttonRotHorizontalLeft)
        if hObject==axesv(ii).handles.pushbuttonRotHorizontalLeft
            ax=axesv(ii);
        end
    end
end
if ~isempty(ax)
    rotHorizontalLeft(ax);
end


% --------------------------------------------------------------------
function pushbuttonRotHorizontalRight_Callback(hObject, eventdata, handles)
global atlasViewer;
axesv = atlasViewer.axesv;
ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.pushbuttonRotHorizontalRight)
        if hObject==axesv(ii).handles.pushbuttonRotHorizontalRight
            ax=axesv(ii);
        end
    end
end
if ~isempty(ax)
    rotHorizontalRight(ax);
end



% --------------------------------------------------------------------
function editDegRotation_Callback(hObject, eventdata, handles)
global atlasViewer;
axesv = atlasViewer.axesv;
ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.editDegRotation)
        if hObject==axesv(ii).handles.editDegRotation            
            val = str2num(get(hObject,'string'));
            axesv(ii).rotation.degrees = val;
            atlasViewer.axesv(ii) = axesv(ii);
        end
    end
end



