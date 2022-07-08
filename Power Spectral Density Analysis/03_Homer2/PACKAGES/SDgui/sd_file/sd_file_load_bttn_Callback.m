function sd_file_load_bttn_Callback(hObject, eventdata, handles)
% --- Executes on button press in sd_file_load_bttn.
% hObject    handle to sd_file_load_bttn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    filename = sd_filename_edit_Get(handles);
    pathname = sd_file_panel_GetPathname(handles);
    
    [filename, pathname, filterindex] = uigetfile({'*.SD; *.sd';'*.nirs'}, ...
        'Open SD file', [pathname, filename]);
    if(filename == 0)
        return;
    end
    sd_file_open(filename, pathname, handles);
