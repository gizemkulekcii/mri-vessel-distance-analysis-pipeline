%--------------------------------------------------------------------------
% Function: coreg_est
% Gizem Külekci
% Created: September 2024
%
% Description: 
%  
%  This function performs coregistration between two images using SPM12.
%  The source image is aligned to the reference image. This coregistration
%  process only estimates the alignment parameters but does not reslice the
%  images.
%
% Inputs:
%  - ref_path: Path to the reference image (the image space to align to)
%  - source_path: Path to the source image (the image that will be aligned to the reference)
%
% Outputs:
%  - The function does not return any variables but applies the
%  coregistration transformation to the source image and updates its header
%  with the estimated transformation matrix.
%
% Requirements:
%   - SPM12 must be installed.
%
% Acknowledgment:
%
%   This function utilizes SPM12 (Statistical Parametric Mapping) for
%   image coregistration. 
%
%   For more information on SPM12, visit:
%   https://www.fil.ion.ucl.ac.uk/spm/software/spm12/
%--------------------------------------------------------------------------

function [] = coreg_est(ref_path, source_path, other_paths)

  % Define the file paths for the reference and source images
    ref_img_path = [ref_path, ',1'];
    source_img_path =[source_path,',1'];

    for i = 1:length(other_paths)
        other_paths{i} = [other_paths{i},',1'];
    end 
   
    % Initialize the SPM batch 
    matlabbatch = {};

    % Specify the reference image (the image to which others will be aligned)
    matlabbatch{1}.spm.spatial.coreg.estimate.ref = {ref_img_path};

    % Specify the source image (the image that will be aligned to the reference)
    matlabbatch{1}.spm.spatial.coreg.estimate.source = {source_img_path};

    matlabbatch{1}.spm.spatial.coreg.estimate.other = other_paths;

    % Coregistration estimation options
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun= 'nmi'; % Cost function (normalized mutual information)
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 1]; % Separation 
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];  % Tolerances for coregistration
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7]; % Smoothing (FWHM in mm)

    % Run the SPM job
    spm_jobman('run', matlabbatch);

    % Clear the batch variable after execution
    clear matlabbatch
end

