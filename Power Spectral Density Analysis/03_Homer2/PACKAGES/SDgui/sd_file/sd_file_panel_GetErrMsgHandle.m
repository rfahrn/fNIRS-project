function h=sd_file_panel_GetErrMsgHandle(handles)

    hObject = handles.sd_file_panel;
    
    % Save pathname in sd_file_panel
    userdata = get(hObject,'userdata');
    h=userdata.h;

