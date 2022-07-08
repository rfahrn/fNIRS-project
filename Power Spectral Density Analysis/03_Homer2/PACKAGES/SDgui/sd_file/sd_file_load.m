function [filedata err]=sd_file_load(filename,handles)

    filedata=[];
    err = 0;
    SDo = [];
    h=sd_file_panel_GetErrMsgHandle(handles);
    p = sd_file_panel_GetPos(handles);
    if(~isempty(h))
        delete(h);
        h=[];
        sd_file_panel_SetErrMsgHandle(handles,h);
    end

    
    newpos = [p(1)-20 p(2)-70 300 55];
    
    if(isempty(filename))
        h = uicontrol('style','text','units','pixels','position',newpos,'string','Error: file does not exist.');
        set(h,'units','normalized');
        sd_file_panel_SetErrMsgHandle(handles,h);
        err=1;
        return;
    end

    try
        filedata=load(filename,'-mat');
        SDo=filedata.SD;
    catch
        h = uicontrol('style','text','units','pixels','position',newpos, 'string','Error: can''t open file not in .mat format.');
        set(h,'units','normalized');
        sd_file_panel_SetErrMsgHandle(handles,h);
        err=2;
        return;
    end 

    if(isempty(SDo))
        h = uicontrol('style','text','units','pixels','position',newpos,'string','Error: Can''t find SD data in file...');
        set(h,'units','normalized');
        sd_file_panel_SetErrMsgHandle(handles,h);
        err=3;
        return;
    end
