
fp = './PACKAGES/AtlasViewerGUI/Data/Colin/fw/fluenceProf*.mat';
files = dir(fp);
if isempty(files)
    fp = '../PACKAGES/AtlasViewerGUI/Data/Colin/fw/fluenceProf*.mat';
end
files = dir(fp);

if isempty(files)
    return;
end

[pp, fs] = getpathparts(fp);
sp = buildpathfrompathparts(pp(1:end-1), fs(1:end-1,:));

fprintf('Found fluence files in %s\n', sp)
copyfile(fp, '.');
for ii=1:length(files)
    genMultWavelengthSimInFluenceFiles(['./', files(ii).name], 2, sp);
end
delete('./fluenceProf*.mat');

