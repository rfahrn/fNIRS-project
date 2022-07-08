function genMultWavelengthSimInFluenceFiles(fwmodel, nWl, dirnameDst)

%
% Example usage:
%   
%    genMultWavelengthSimInFluenceFiles(atlasViewer.fwmodel)
%
%

if ~exist('nWl','var') | isempty(nWl)
    nWl = 2;
end
if ~exist('dirnameDst','var') | isempty(dirnameDst)
    dirnameDst = './';
else
    if dirnameDst(end)~='/' && dirnameDst(end)~='\'
        dirnameDst(end+1)='/';
    end
end

if isstruct(fwmodel)
    fluenceProfFnames = fwmodel.fluenceProfFnames;
else
    fluenceProfFnames{1} = fwmodel;
end

for ii=1:length(fluenceProfFnames)
    
    [pathnm, filenm, ext] = fileparts(fluenceProfFnames{ii});
    filenmNew = [dirnameDst, filenm, ext];        
    copyfile(fluenceProfFnames{ii}, filenmNew);
    
    s = loadFluenceProf(fluenceProfFnames{ii});
    
    nWlactual = size(s.intensities,3);
    d = nWl - nWlactual; 
    if d>0
        for iW=nWlactual+1:nWl
            
            s.intensities(:,:,iW) = s.intensities;
            s.normfactors(:,:,iW) = s.normfactors;
            for ii=1:length(s.tiss_prop)
                s.tiss_prop(ii).scattering(iW) = s.tiss_prop(ii).scattering(1);
                s.tiss_prop(ii).absorption(iW) = s.tiss_prop(ii).absorption(1);
                s.tiss_prop(ii).anisotropy(iW) = s.tiss_prop(ii).anisotropy(1);
                s.tiss_prop(ii).refraction(iW) = s.tiss_prop(ii).refraction(1);
            end
            
        end
        
        intensities = s.intensities;
        normfactors = s.normfactors;
        tiss_prop = s.tiss_prop;
        
        fprintf('Saving %d wavelength simulation in %s\n', nWl, filenmNew);
        save(filenmNew, '-append', 'intensities', 'normfactors', 'tiss_prop');
    end
    
end

