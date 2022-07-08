function axesv = rotHorizontalRight(axesv,deg)

if ~exist('deg','var')
    deg = axesv.rotation.degrees;
end
camorbit(axesv.handles.axesSurfDisplay,-deg,0,'camera');
%disp(sprintf('Rot Horizontal Right: %s',num2str(deg)));
