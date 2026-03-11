
function [] = coreg_est2(ref_path, source_path)

  % Define the file paths for the reference and source images
    ref_img_path = [ref_path, ',1'];
    source_img_path =[source_path,',1'];
   
    % Initialize the SPM batch 
    matlabbatch = {};

    % Specify the reference image (the image to which others will be aligned)
    matlabbatch{1}.spm.spatial.coreg.estimate.ref = {ref_img_path};

    % Specify the source image (the image that will be aligned to the reference)
    matlabbatch{1}.spm.spatial.coreg.estimate.source = {source_img_path};

    % Coregistration estimation options
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun= 'nmi'; % Cost function (normalized mutual information)
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 1]; % Separation ( optimized steps in mm)
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];  % Tolerances for coregistration
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7]; % Smoothing (FWHM in mm)

    % Run the SPM job
    spm_jobman('run', matlabbatch);

    % Clear the batch variable after execution
    clear matlabbatch
end