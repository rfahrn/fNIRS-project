function axesv = rotUp(axesv,deg)

if ~exist('deg','var')
    deg = axesv.rotation.degrees;
end
camorbit(axesv.handles.axesSurfDisplay,0,-deg,'camera');
%disp(sprintf('Rot Up: %s',num2str(deg)));
