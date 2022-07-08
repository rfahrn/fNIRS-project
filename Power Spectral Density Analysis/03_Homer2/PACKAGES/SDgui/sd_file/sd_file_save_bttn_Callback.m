function sd_file_save_bttn_Callback(hObject, eventdata, handles)
% --- Executes on button press in sd_file_save_bttn.
% hObject    handle to sd_file_save_bttn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    filename = sd_filename_edit_Get(handles);
    pathname = sd_file_panel_GetPathname(handles);
    if(isempty(filename))
        % Change directory
        [filename, pathname, filterindex] = uiputfile('*.*','Save SD file',pathname);
        if(filename == 0)
            return;
        end
    end
    
    if exist([pathname filename],'file')
        q = menu('File already exists. Do you want to overwrite it?','Yes','No');
        if q==2
            return;
        end
    end
    sd_file_save(filename,pathname,handles);
