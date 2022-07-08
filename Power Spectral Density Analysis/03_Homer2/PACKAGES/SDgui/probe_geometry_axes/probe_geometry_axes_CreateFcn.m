function probe_geometry_axes_CreateFcn(hObject, eventdata, handles)

    cla(hObject);
    set(hObject, 'xlim', [0 100]);
    set(hObject, 'ylim', [0 100]);
    set(hObject, 'zlim', [0 100]);
    set(hObject, 'xgrid', 'on');
    set(hObject, 'ygrid', 'on');
    set(hObject, 'zgrid', 'on');

    set(hObject,'units','pixels')
    p=get(hObject, 'position');
    set(hObject,'units','normalized');
    offset=40;

    hxlabel=uicontrol('style','text','units','pixels','position',[p(1)+p(3)/2, p(2)-offset, 20, 20], ...
                      'string','x','visible','on','fontsize',12);
    hylabel=uicontrol('style','text','units','pixels','position',[p(1)-offset, p(2)+p(4)/2, 20, 20], ...
                      'string','y','visible','on','fontsize',12);

    set(hxlabel,'units','normalized');
    set(hylabel,'units','normalized');

    optselect=struct('src',[],'det',[]);
    edges=struct('color',[.45 .85 .65],'thickness',2,'handles',[]);
    probe_geometry_axes_data=struct('optselect',optselect,'h_nodes_s',[],'h_nodes_d',[],'h_nodes_dummy',[],...
                                    'edges',edges,'fontsize',[11 14],'fontsize_dummy',[11 14],'view','xy',...
                                    'hxlabel',hxlabel,'hylabel',hylabel,'threshold',[0 0 0],...
                                    'fontcolor_s',[1.00 0.00 0.00; 0.85 0.45 0.55],...
                                    'fontcolor_d',[0.00 0.00 1.00; 0.55 0.45 0.85],...
                                    'fontcolor_dummy',[1.00 0.00 1.00; 0.85 0.35 0.85]);
    set(hObject,'userdata',probe_geometry_axes_data);

