%--------------------------------------------------------------------------
% Function: coreg_est_reslice
% Gizem Külekci
% Created: September 2024
%
% Description:
%  
%  This function performs coregistration of anatomical MRI images using SPM12
%  It sets up and runs an SPM batch for aligning a source image to a 
%  reference image for the specified subject
%
% Inputs:
%  - ref_path: Path to the reference image (the image to which others will be aligned)
%  - source_path: Path to the source image (the image that will be aligned to the reference)
%
% Outputs:
%  - The function does not return any variables, but it saves the
%  coregistration results in the specified directory with a prefix 'r'
%  added to the file
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
function [] = coreg_est_reslice(ref_path, source_path)

    % Define the file paths for the reference, source and other images
    ref_img_path = fullfile([ref_path, ',1']);
    source_img_path = fullfile([source_path,',1']);

    % Initialize the SPM batch 
    matlabbatch = {};

    % Specify the reference image (the image to which others will be aligned)
    matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {ref_img_path};

    % Specify the source image (the image that will be aligned to the reference)
    matlabbatch{1}.spm.spatial.coreg.estwrite.source = {source_img_path};
    
    % Coregistration estimation options
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi'; % Cost function (normalized mutual information)
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2]; % Separation ( optimized steps in mm)
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001]; % Tolerances for coregistration
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7]; % Smoothing (FWHM in mm)

    % Reslicing options
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4; % Interpolation method (4th degree B-spline)
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0]; % No wrapping
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0; % No masking
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r'; % Prefix for resliced files
    
    % Run the SPM job
    spm_jobman('run', matlabbatch);

    % Clear the batch variable after execution
    clear matlabbatch
 
end
