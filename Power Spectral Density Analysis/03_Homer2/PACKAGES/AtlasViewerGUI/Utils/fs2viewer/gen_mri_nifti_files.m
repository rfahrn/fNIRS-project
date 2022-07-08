function status = gen_mri_nifti_files()

status = 0;
flags=zeros(4,1);
if isunix() 
    
    if(exist('./mri/T1.mgz') & ~exist('./mri/T1.nii'))
        %!mri_convert ./mri/T1.mgz ./mri/T1.nii
        flags(1) = 1;
    elseif ~exist('./mri/T1.nii')
        flags(1) = 1;
    end
    if(exist('./mri/brain.mgz') & ~exist('./mri/brain.nii'))
        %!mri_convert ./mri/brain.mgz ./mri/brain.nii
        flags(2) = 1;
    elseif ~exist('./mri/brain.nii')
        flags(2) = 1;
    end
    if(exist('./mri/aseg.mgz') & ~exist('./mri/aseg.nii'))
        %!mri_convert ./mri/aseg.mgz ./mri/aseg.nii
        flags(3) = 1;
    elseif ~exist('./mri/aseg.nii')
        flags(3) = 1;
    end
    if(exist('./mri/wm.mgz') & ~exist('./mri/wm.nii'))
        %!mri_convert ./mri/wm.mgz ./mri/wm.nii
        flags(4) = 1;        
    elseif ~exist('./mri/wm.nii')
        flags(4) = 1;
    end
    
elseif ispc()
    
    filelist='';
    if(exist('./mri/T1.mgz') & ~exist('./mri/T1.nii'))
        filelist='T1.nii; ';
        flags(1) = 2;
    end
    if(exist('./mri/brain.mgz') & ~exist('./mri/brain.nii'))
        filelist=sprintf('%sbrain.nii; ', filelist);
        flags(2) = 2;
    end
    if(exist('./mri/aseg.mgz') & ~exist('./mri/aseg.nii'))
        filelist=sprintf('%saseg.nii; ', filelist);
        flags(3) = 2;
    end
    if(exist('./mri/wm.mgz') & ~exist('./mri/wm.nii'))
        filelist=sprintf('%swm.nii; ', filelist);
        flags(4) = 2;
    end
    if ~isempty(filelist)
        UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
        set(0, 'DefaultUIControlFontSize', 12);
        menu(sprintf('Warning: Missing the following nifti files: %s.\nUse mri_convert untility to generate them.', filelist), 'OK');
        set(0, 'DefaultUIControlFontSize', UIControl_FontSize_bak);
    end
    
end

%if flags(1)>0 | (flags(2)>0 & flags(3)>0)
if flags(1)>0
     status = 1;
end

