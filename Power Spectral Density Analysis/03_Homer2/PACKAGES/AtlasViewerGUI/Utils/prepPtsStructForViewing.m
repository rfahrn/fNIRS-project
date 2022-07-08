function pts = prepPtsStructForViewing(pos,nsrc,mode,col,siz,str)

if ~exist('mode','var')
    mode='numbers';
end


pts = repmat(struct('pos',[0 0 0],'col',[1 0 0],'size',10,'str','i','type',''), size(pos,1), 1);

if strcmp(mode,'numbers')
    if ~exist('col','var') || isempty(col)
        c{1}=[1 0 0];
        c{2}=[0 0 1];
    else
        c{1}=col;
        c{2}=col;
    end
    if ~exist('siz','var') || isempty(siz)
        siz=11;
    end
    for ii=1:size(pos)
        pts(ii).pos  = pos(ii,:);
        pts(ii).textsize = siz;
        pts(ii).circlesize = siz*2;
        if ii<=nsrc
            pts(ii).col  = c{1};
            pts(ii).str  = num2str(ii);
            pts(ii).type = 's';
        else
            pts(ii).col  = c{2};
            pts(ii).str  = num2str(ii-nsrc);
            pts(ii).type = 'd';
        end
    end
elseif strcmp(mode,'circles')
    if ~exist('col','var')  || isempty(col)
        c{1}=[1 0 0];
        c{2}=[0 0 1];
    else
        c{1}=col;
        c{2}=col;
    end
    if ~exist('siz','var') || isempty(siz)
        siz=20;
    end
    for ii=1:size(pos)
        pts(ii).pos  = pos(ii,:);
        pts(ii).circlesize = siz;
        pts(ii).textsize = siz/2;
        pts(ii).str  = '';
        if ii<=nsrc
            pts(ii).col  = c{1};
            pts(ii).type = 's';
        else
            pts(ii).col  = c{2};
            pts(ii).type = 'd';
        end
    end
elseif strcmp(mode,'labels')
    if ~exist('col','var') || isempty(col)
        c=[1 1 0];
    else
        c=col;
    end
    if ~exist('siz','var') || isempty(siz)
        siz=11;
    end
    for ii=1:size(pos)
        pts(ii).pos  = pos(ii,:);
        pts(ii).textsize = siz;
        pts(ii).circlesize = siz/2;
    	pts(ii).str  = str{ii};
        pts(ii).col  = c;
        pts(ii).type = 'r';
        end
    end
end
            
