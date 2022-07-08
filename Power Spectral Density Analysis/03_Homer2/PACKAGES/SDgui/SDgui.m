function varargout = SDgui(varargin)
% SDGUI M-file for SDgui.fig
%      SDGUI, by itself, creates a new SDGUI or raises the existing
%      singleton*.
%
%      H = SDGUI returns the handle to a new SDGUI or the handle to
%      the existing singleton*.
%
%      SDGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SDGUI.M with the given input arguments.
%
%      SDGUI('Property','Value',...) creates a new SDGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SDgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SDgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SDgui

% Last Modified by GUIDE v2.5 01-Aug-2014 10:03:42

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @SDgui_OpeningFcn, ...
                       'gui_OutputFcn',  @SDgui_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);

    if nargin && ischar(varargin{1}) && ~strcmp(varargin{end},'userargs')
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT




% -------------------------------------------------------------------
function SDgui_OpeningFcn(hObject, eventdata, handles, varargin)

    global SD;
    SD = [];

    % Choose default command line output for SDgui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes SDgui wait for user response (see UIRESUME)
    % uiwait(handles.SDgui);

    set(hObject,'menubar','none');

    hfilemenu = uimenu('parent',hObject,'handlevisibility','callback','label','file');
    hnewmenuitem = uimenu('parent',hfilemenu,'handlevisibility','callback',...
                          'label','New','callback',@SDgui_newmenuitem_Callback);

    hopenmenuitem = uimenu('parent',hfilemenu,'handlevisibility','callback',...
                           'label','Open','callback',@SDgui_openmenuitem_Callback);

    hsavemenuitem = uimenu('parent',hfilemenu,'handlevisibility','callback',...
                           'label','Save','callback',@SDgui_savemenuitem_Callback);

    hsaveasmenuitem = uimenu('parent',hfilemenu,'handlevisibility','callback',...
                            'label','Save as','callback',@SDgui_saveasmenuitem_Callback);

    hexitsmenuitem = uimenu('parent',hfilemenu,'handlevisibility','callback',...
                            'label','Exit','callback',@SDgui_DeleteFcn);

    set(hObject,'userdata',pwd);

    sd_data_Create();
    % loadSDfile(handles);

    vrnum='v1.0';
    set(hObject,'name',sprintf('SDgui - %s',vrnum));

    SDgui_chooseMode(handles.radiobuttonSpringEnable, handles);

    probe_geometry_axes_SetAxisEqual(handles);
    probe_geometry_axes2_SetAxisEqual(handles);

    [filename, pathname] = getCurrPathname(varargin);
    if ~isempty(filename) & filename ~= 0
        sd_filename_edit_Set(handles,filename);
        sd_file_panel_SetPathname(handles,pathname);
        sd_file_open(filename, pathname, handles);
        % cd(pathname);
    else
        SDgui_newmenuitem_Callback(hnewmenuitem);
    end

    % Set the AtlasViewerGUI version number
    V = SDgui_version();
    if str2num(V{2})==0
        set(hObject,'name', sprintf('SDgui  (v%s) - %s', [V{1}],cd) )
    else
        set(hObject,'name', sprintf('SDgui  (v%s) - %s', [V{1} '.' V{2}],cd) )
    end
    SD.vrnum = V;



% -------------------------------------------------------------------
function SDgui_DeleteFcn(hObject, eventdata, handles)

    global SD;
    SD = [];
    hSDgui = get(get(hObject,'parent'),'parent');
    delete(hSDgui);



% -------------------------------------------------------------------
function varargout = SDgui_OutputFcn(hObject, eventdata, handles) 

    % Get default command line output from handles structure
    varargout{1} = handles.output;



% -------------------------------------------------------------------
function SDgui_clear_all_bttn_Callback(hObject, eventdata, handles)

    % Clear central data object first 
    sd_data_Clear();

    if ~exist('handles','var') || isempty(handles)
        return;
    end
    
    % Clear Axes
    probe_geometry_axes_Clear(handles);

    % Clear Axes2
    probe_geometry_axes2_Clear(handles);

    % Clear source optode table
    optode_src_tbl_Clear(handles);

    % Clear detector optode table
    optode_det_tbl_Clear(handles);

    % Clear detector optode table
    optode_dummy_tbl_Clear(handles);

    % Clear position probe related optode table
    optode_spring_tbl_Clear(handles);
    optode_anchor_tbl_Clear(handles);

    % Clear SD file panel
    sd_file_panel_Clear(handles);

    % Clear Lambda panel
    wavelength1_edit_Update(handles,[]);
    wavelength2_edit_Update(handles,[]);
    wavelength3_edit_Update(handles,[]);



% -------------------------------------------------------------------
function handles = SDgui_gethandles(hObject)

    hchildren = get(get(get(hObject,'parent'), 'parent'),'children');
    for i=1:length(hchildren)
        tag = get(hchildren(i),'tag');
        switch tag
        case 'sd_file_panel'
            handles.sd_file_panel = hchildren(i);
            hc = get(handles.sd_file_panel,'children');
            for k=1:length(hc)
                tag = get(hc(k),'tag');
                switch tag
                case 'sd_file_load_bttn'
                    handles.sd_file_load_bttn = hc(k);
                case 'sd_file_save_bttn'
                    handles.sd_file_save_bttn = hc(k);
                case 'sd_filename_edit'
                    handles.sd_filename_edit = hc(k);
                end
            end
        case 'wavelength_panel'
            handles.wavelength_panel = hchildren(i);
            hc = get(handles.wavelength_panel,'children');
            for k=1:length(hc)
                tag = get(hc(k),'tag');
                switch tag
                case 'wavelength1_edit'
                    handles.wavelength1_edit = hc(k);
                case 'wavelength2_edit'
                    handles.wavelength2_edit = hc(k);
                case 'wavelength3_edit'
                    handles.wavelength3_edit = hc(k);
                end
            end
        case 'probe_geometry_axes'
            handles.probe_geometry_axes = hchildren(i);
        case 'probe_geometry_axes2'
            handles.probe_geometry_axes2 = hchildren(i);
        case 'optode_tbls_panel'
            handles.optode_tbls_panel = hchildren(i);
            hc = get(handles.optode_tbls_panel,'children');
            for k=1:length(hc)
                tag = get(hc(k),'tag');
                switch tag
                case 'optode_src_tbl'
                    handles.optode_src_tbl = hc(k);
                case 'optode_src_tbl_srcmap_show'
                    handles.optode_src_tbl_srcmap_show = hc(k);
                case 'optode_det_tbl'
                    handles.optode_det_tbl = hc(k);
                end
            end
        case 'optode_tbls2_panel'
            handles.optode_tbls2_panel = hchildren(i);
            hc = get(handles.optode_tbls2_panel,'children');
            for k=1:length(hc)
                tag = get(hc(k),'tag');
                switch tag
                case 'optode_spring_tbl'
                    handles.optode_spring_tbl = hc(k);
                case 'optode_anchor_tbl'
                    handles.optode_anchor_tbl = hc(k);
                case 'optode_dummy_tbl'
                    handles.optode_dummy_tbl = hc(k);
                end
            end
        case 'radiobuttonSpringEnable'
            handles.radiobuttonSpringEnable = hchildren(i);
        end
    end




% -------------------------------------------------------------------
function SDgui_openmenuitem_Callback(hObject, eventdata, handles)
    global SD;

    handles = SDgui_gethandles(hObject);
    pathname = sd_file_panel_GetPathname(handles);

    % Change directory SDgui
    [filename, pathname] = uigetfile({'*.SD; *.sd';'*.nirs'},'Open SD file',pathname);
    if(filename == 0)
        return;
    end
    
    SDgui_clear_all_bttn_Callback(hObject, eventdata, handles);
    sd_file_open(filename, pathname, handles);



% -------------------------------------------------------------------
function SDgui_newmenuitem_Callback(hObject, eventdata, handles)
    global SD;
    
    handles = SDgui_gethandles(hObject);
    SDgui_clear_all_bttn_Callback(hObject, [], handles);



% -------------------------------------------------------------------
function loadSDfile(handles)

   


% -------------------------------------------------------------------
function SDgui_savemenuitem_Callback(hObject, eventdata)

    % Get current pathname
    handles = SDgui_gethandles(hObject);
    filename = sd_filename_edit_Get(handles);
    pathname = sd_file_panel_GetPathname(handles);

    % Save file 
    filename = sd_filename_edit_Get(handles);
    if(isempty(filename))
        [filename, pathname, filterindex] = uiputfile({'*.SD'; '*.sd'; '*.nirs'},'Save SD file',pathname);
        if(filename == 0)
            return;
        end
    end
    sd_file_save(filename, pathname, handles);
   


% -------------------------------------------------------------------
function SDgui_saveasmenuitem_Callback(hObject, eventdata)

    % Get current pathname
    handles = SDgui_gethandles(hObject);
    filename = sd_filename_edit_Get(handles);
    pathname = sd_file_panel_GetPathname(handles);

    % Save file 
    [filename, pathname, filterindex] = uiputfile({'*.SD'; '*.sd'; '*.nirs'},'Save SD file as under another file name',pathname);
    if(filename == 0)
        return;
    end
    sd_file_save(filename, pathname, handles);


% -------------------------------------------------------------------
function SDgui_radiobuttonSpringEnable_Callback(hObject, eventdata, handles)
    
    SDgui_chooseMode(hObject, handles);



% -------------------------------------------------------------------
function SDgui_chooseMode(hObject, handles)

    if get(handles.radiobuttonSpringEnable,'value')==0
        probe_geometry_axes_Hide(handles,'on');
        optode_tbls_Hide(handles,'on');

        probe_geometry_axes2_Hide(handles,'off');
        optode_tbls2_Hide(handles,'off');
    else
        probe_geometry_axes_Hide(handles,'off');
        optode_tbls_Hide(handles,'off');

        probe_geometry_axes2_Hide(handles,'on');
        optode_tbls2_Hide(handles,'on');
    end




% -------------------------------------------------------------------
function [filename, pathname] = getCurrPathname(arg)

pathname = [];
filename = [];
if length(arg)==2
    pathname = arg{1};
    if isempty(pathname)
        return;
    end
    k = find(pathname == '/' | pathname == '\');
    if length(k)>0
        filename = pathname(k(end)+1:end);
        pathname = pathname(1:k(end));
    else
        filename = pathname;
        pathname = [];
    end
elseif length(arg)==3
    pathname = arg{1};
    filename = arg{2};
end

if isempty(filename)
    [filename, pathname] = uigetfile({'*.SD; *.sd';'*.nirs'},'Open SD file',pathname);
    if(filename == 0)
        return;
    end
end



% -------------------------------------------------------------------
function sd_filename_edit_Callback(hObject, eventdata, handles)
filename = get(hObject,'string');
if isempty(filename);
    return;
end
k=findstr(filename,'.');
if ~isempty(k)
    ext=filename(k(end):end);
else
    ext=[];
end
if ~strcmpi(ext,'.nirs') & ~strcmpi(ext,'.sd')
    filename = [filename '.SD'];
    set(hObject,'string',filename);
end
