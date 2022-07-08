function sd_data_ErrorFix()

    global SD;
    
    if(~isfield(SD,'SrcPos'))
        SD.SrcPos=[];
    end
    if(~isfield(SD,'DetPos'))
        SD.DetPos=[];
    end
    SD.nSrcs=size(SD.SrcPos,1);
    SD.nDets=size(SD.DetPos,1);

    ml=sd_data_GetMeasList();
    nwl=sd_data_GetNwl();
    if(~isfield(SD,'Lambda') || isempty(SD.Lambda))
        SD.Lambda=[];
    end
    if(~isfield(SD,'MeasList'))
        SD.MeasList=[];
    elseif ~isempty(SD.MeasList)
        if size(SD.MeasList,2)<3
            SD.MeasList(:,3)=1;
        end
        ml=sd_data_GetMeasList();
        nwl=sd_data_GetNwl();
        if(nwl~=length(unique(SD.MeasList(:,end))) & (SD.nSrcs>0))
            sd_data_SetMeasList(ml);
        end
    end
    
    if(~isfield(SD,'SpringList'))
        SD.SpringList=[];
    end
    
    if(~isfield(SD,'AnchorList'))
        SD.AnchorList=[];
    end
        
    if isfield(SD,'SpatialUnit')
        if strcmpi(SD.SpatialUnit,'cm')
            ch = menu(sprintf('We recommend Spatial Units of mm to be consistent with Homer.\nWe will convert cm to mm for you.'),'Okay','Cancel');
            if ch==1
                SD.SpatialUnit = 'mm';
                SD.SrcPos = SD.SrcPos * 10;
                SD.DetPos = SD.DetPos * 10;
                lst = find(SD.SpringList(:,3)~=-1);
                SD.SpringList(lst,3) = SD.SpringList(lst,3) * 10;
            end
        end
    elseif ~isfield(SD,'SpatialUnit')
        ch = menu('What spatial units are used for the optode positions?','cm','mm','Do not know');
        if ch==1
            ch = menu('We will convert cm to mm for you.','Okay','Cancel');
            if ch==1
                SD.SpatialUnit = 'mm';
                SD.SrcPos = SD.SrcPos * 10;
                SD.DetPos = SD.DetPos * 10;
                if isfield(SD,'SpringList')
                    if size(SD.SpringList,2)==3
                        lst = find(SD.SpringList(:,3)~=-1);
                        SD.SpringList(lst,3) = SD.SpringList(lst,3) * 10;
                    end
                end
            else
                SD.SpatialUnit = 'cm';
            end
        elseif ch==2
            SD.SpatialUnit = 'mm';
        elseif ch==3
            SD.SpatialUnit = 'mm';
        end
    end

    if(isfield(SD,'MeasListAct') && isempty(SD.MeasListAct))
        SD.MeasListAct=ones(size(SD.MeasList,1),1);
    end

    if(~isfield(SD,'SrcMap'))
        SD.SrcMap=[];
    elseif(nwl>0 & SD.nSrcs>0 & isempty(SD.SrcMap))
        sd_data_SetSrcMapDefault();
    elseif(nwl>0 & SD.nSrcs>0 & (size(SD.SrcMap,1) ~= nwl))
        SD.SrcMap=reshape(SD.SrcMap(:),nwl,SD.nSrcs);
    end
