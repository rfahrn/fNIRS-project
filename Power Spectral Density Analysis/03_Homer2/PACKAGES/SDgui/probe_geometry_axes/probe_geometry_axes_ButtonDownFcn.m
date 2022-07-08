function probe_geometry_axes_ButtonDownFcn(hObject, eventdata, handles)

    pos = get(hObject,'currentpoint');

    probe_geometry_axes_data = get(hObject,'userdata');
    optselect = probe_geometry_axes_data.optselect;
    h_nodes_s = probe_geometry_axes_data.h_nodes_s;
    h_nodes_d = probe_geometry_axes_data.h_nodes_d;
    edges     = probe_geometry_axes_data.edges;
    h_edges   = edges.handles;
    axes_view = probe_geometry_axes_data.view;
    fs        = probe_geometry_axes_data.fontsize;
    fc_s      = probe_geometry_axes_data.fontcolor_s;
    fc_d      = probe_geometry_axes_data.fontcolor_d;
    threshold = probe_geometry_axes_data.threshold;
    
    % Set threshold level
    l = 1;
        
    optpos_det = getOptPosFromAxes(h_nodes_d);
    optpos_src = getOptPosFromAxes(h_nodes_s);
    optpos=[optpos_src; optpos_det];
    if(isempty(optpos))
        return;
    end
    p = get_pt_from_buttondown(pos,optpos,axes_view);
 
    src=[];
    det=[];

    [p1 isrc d1]=nearest_point(optpos_src,p);
    [p2 idet d2]=nearest_point(optpos_det,p);
    
    % Check whether a source was selected 
    if isrc>0  &&  d1<threshold(3) && (idet==0 || d1<d2)
         
        if(optselect.src(isrc)==1)
            optselect.src(isrc)=0;
            set(h_nodes_s(isrc),'fontweight','bold','fontsize',fs(1),'color',fc_s(1,:));
        elseif all(~optselect.src)
            optselect.src(isrc)=1;
            set(h_nodes_s(isrc),'fontweight','bold','fontsize',fs(2),'color',fc_s(2,:));
            src=p1;
            
            % Optode selected is a src. Check if there's a det
            % selected.
            idet=find(optselect.det==1);
            if(~isempty(idet))
                det=optpos_det(idet,:);
            end
        end
        
    % Check whether a detector was selected
    elseif idet>0  &&  d2<threshold(3) && (isrc==0 || d2<d1)

        if(optselect.det(idet)==1)
            optselect.det(idet)=0;
            set(h_nodes_d(idet),'fontweight','bold','fontsize',fs(1),'color',fc_d(1,:));
        elseif all(~optselect.det)
            optselect.det(idet)=1;
            set(h_nodes_d(idet),'fontweight','bold','fontsize',fs(2),'color',fc_d(2,:));
            det=p2;
            
            % Optode selected is a det. Check if there's a src
            % selected.
            
            isrc=find(optselect.src==1);
            if(~isempty(isrc))
                src=optpos_src(isrc,:);
            end
        end
        
    end


    % If a source and detector were selected then 
    % draw a line between them.  
    ml = getMeasListFromAxes(optpos_src,optpos_det,h_edges);
    if(~isempty(src) & ~isempty(det))
        if(~isempty(ml))
            i=find(ml(:,1)==isrc & ml(:,2)==idet);
        else
            i=[];
        end
        % Check whether the measurement pair alreasy exists
        % in ml
        if(isempty(i))
            h_edges(end+1) = line([src(:,1) det(:,1)],[src(:,2) det(:,2)],[src(:,3) det(:,3)],...
                                  'color',edges.color,'linewidth',edges.thickness,...
                                  'hittest','off','ButtonDownFcn','probe_geometry_axes_ButtonDownFcn');
            ml(end+1,:) = [isrc idet];

            % We want the optodes to be drawn over the new edge
            % so redraw the two the are involved in the measurement 
            % pair
            h_nodes_s(isrc)=redraw_text(h_nodes_s(isrc));
            h_nodes_d(idet)=redraw_text(h_nodes_d(idet));
        else
            delete(h_edges(i));
            h_edges(i)=[];
            ml(i,:)=[];
        end

        % Update SD Measuremnt List
        i=sd_data_SetMeasList(ml);
        h_edges(i) = h_edges;

	% reset node all node selections zero 
        optselect.src(:)=0;
        set(h_nodes_s(:),'fontweight','bold','fontsize',fs(1),'color',fc_s(1,:));

        optselect.det(:)=0;
        set(h_nodes_d(:),'fontweight','bold','fontsize',fs(1),'color',fc_d(1,:));
    end
    
    % Save the changes the user made
    probe_geometry_axes_data.optselect=optselect;
    probe_geometry_axes_data.edges.handles=h_edges;
    probe_geometry_axes_data.h_nodes_s = h_nodes_s;
    probe_geometry_axes_data.h_nodes_d = h_nodes_d;
    set(hObject,'userdata',probe_geometry_axes_data);

