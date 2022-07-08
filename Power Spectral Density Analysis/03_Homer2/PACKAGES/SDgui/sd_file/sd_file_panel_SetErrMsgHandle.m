function sd_file_panel_SetErrMsgHandle(handles,h)

    hObject = handles.sd_file_panel;
    
    % Save pathname in sd_file_panel
    userdata = get(hObject,'userdata');
    userdata.h = h;
    set(hObject, 'userdata', userdata);
