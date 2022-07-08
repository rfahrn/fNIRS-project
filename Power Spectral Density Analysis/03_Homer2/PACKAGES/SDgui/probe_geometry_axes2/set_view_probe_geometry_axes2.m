function axes_view = set_view_probe_gemetry_axes2(hObject,optpos)

    axes_view='xy';
    if(isempty(optpos))
        return;
    end

    probe_geometry_axes2_data = get(hObject,'userdata');
    hxlabel = probe_geometry_axes2_data.hxlabel;
    hylabel = probe_geometry_axes2_data.hylabel;

    if(length(unique(optpos(:,3)))==1)
        set(hObject, 'view', [0 90]);
        set(hxlabel,'string','x');
        set(hylabel,'string','y');
        axes_view='xy';
    elseif(length(unique(optpos(:,2)))==1)
        set(hObject, 'view', [0 0]);
        set(hxlabel,'string','x');
        set(hylabel,'string','z');
        axes_view='xz';
    elseif(length(unique(optpos(:,1)))==1)
        set(hObject, 'view', [90 0]);
        set(hxlabel,'string','y');
        set(hylabel,'string','z');
        axes_view='yz';
    end

