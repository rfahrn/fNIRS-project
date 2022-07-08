function probe_geometry_axes2_CreateFcn(hObject, eventdata, handles)

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

    edges=struct('color',[.45 .85 .65],'thickness',2,'handles',[]);
    probe_geometry_axes2_data=struct('optselect',[],'h_nodes',[],'edges',edges,'fontsize',[11 14],...
                                     'view','xy','hxlabel',hxlabel,'hylabel',hylabel,'threshold',[0 0 0],...
				                         'fontcolor',[1.00 0.00 0.00; 0.85 0.45 0.55],...
				                         'fontcolor_dummy',[0.20 0.30 0.25; 0.30 0.40 0.35],...
                                     'noptorig',0);
    set(hObject,'userdata',probe_geometry_axes2_data);
