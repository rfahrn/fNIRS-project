function pathname = sd_file_panel_GetPathname(handles)

    hObject = handles.sd_file_panel;
    
    % Save pathname in sd_file_panel
    userdata = get(hObject,'userdata');
    pathname = userdata.pathname;
