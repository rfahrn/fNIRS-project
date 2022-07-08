function sd_file_panel_SetPathname(handles,pathname)

    hObject = handles.sd_file_panel;
    
    % Save pathname in sd_file_panel
    userdata = get(hObject,'userdata');
    userdata.pathname = pathname;
    set(hObject, 'userdata', userdata);
