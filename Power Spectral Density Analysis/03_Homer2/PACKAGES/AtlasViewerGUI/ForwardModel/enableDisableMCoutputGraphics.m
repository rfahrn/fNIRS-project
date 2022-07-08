function fwmodel = enableDisableMCoutputGraphics(fwmodel, onoff)

handles = fwmodel.handles;
if strcmp(onoff,'off')
    set(handles.menuItemGenerateLoadSensitivityProfile,'enable','off');
    set(handles.menuItemEnableSensitivityMatrixVolume,'enable','off');
    set(handles.menuItemLoadPrecalculatedProfile,'enable','off');
elseif strcmp(onoff,'on')
    set(handles.menuItemGenerateLoadSensitivityProfile,'enable','on');
    set(handles.menuItemEnableSensitivityMatrixVolume,'enable','on');
    set(handles.menuItemLoadPrecalculatedProfile,'enable','on');
end
