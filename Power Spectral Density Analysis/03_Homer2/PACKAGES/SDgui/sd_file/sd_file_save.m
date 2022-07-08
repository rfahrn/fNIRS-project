function sd_file_save(filename, pathname, handles)
    global filedata;

    h=sd_file_panel_GetErrMsgHandle(handles);
    if(~isempty(h))
        delete(h);
        sd_file_panel_SetErrMsgHandle(handles,[]);
    end
    p = sd_file_panel_GetPos(handles);
    
    newpos = [p(1)-20 p(2)-70 300 55];

    i=findstr('/',filename);
    j=findstr('\',filename);
    k = [i j];
    if(~isempty(k))
        sd_dir = filename(1:k(end));
        if(~exist(sd_dir,'dir'))
            msg=sprintf('Error: couldn''t save SD file - no such directory %s', sd_dir);
            h=uicontrol('style','text','units','pixels','position',newpos,'string',msg);
            set(h,'units','normalized');

            sd_file_panel_SetErrMsgHandle(handles,h);
            ch=menu(msg,'ok');
            return;
        end
    end
    
    if(isempty(sd_data_Get('Lambda')));
        msg=sprintf('Error: could not save file - need to set Lamda');
        h=uicontrol('style','text','units','pixels','position',newpos,'string',msg);
        set(h,'units','normalized');
        sd_file_panel_SetErrMsgHandle(handles,h);
        ch=menu(msg,'ok');
        return;
    end

    sd_filename_edit_Set(handles,filename);
    sd_data_ErrorFix();
    SD=sd_data_Get('all');
    k=findstr(filename,'.');
    if ~isempty(k) 
        ext=filename(k(end):end);
    else
        ext='.SD';
        filename = [filename, ext];
    end
    if ~isempty(ext) & strcmp(ext,'.nirs')
        filedata.SD = SD;
        sd_file_save2nirs([pathname filename],filedata);
    else
        save([pathname filename],'SD','-mat');
    end

    msg=sprintf('File %s saved in %s',filename, pathname);
    h=uicontrol('style','text','units','pixels','position',newpos,'string',msg);
    set(h,'units','normalized');
    sd_file_panel_SetErrMsgHandle(handles,h);
    sd_file_panel_SetPathname(handles,pathname);

