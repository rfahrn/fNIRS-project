function AtlasViewerGUI_enableDisable()
global atlasViewer

refpts       = atlasViewer.refpts;
digpts       = atlasViewer.digpts;
headsurf     = atlasViewer.headsurf;

if isempty(digpts.refpts.pos) | isempty(refpts.pos) | isempty(headsurf.mesh.vertices)
    set(atlasViewer.handles.menuItemRegisterAtlasToDigpts,'enable','off')
else
    set(atlasViewer.handles.menuItemRegisterAtlasToDigpts,'enable','on')
end

