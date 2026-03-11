%--------------------------------------------------------------------------
% Function: tissueSeg
% Gizem Külekci
% Created: 08.2024
%
% Description:
%
%   This function performs tissue segmentation on an anatomical MRI image
%   using SPM12. It sets up and runs an SPM batch for segmentation, which
%   classifies the anatomical image into different tissue types such as gray
%   matter, white matter, cerebrospinal fluid, and others.
%
% Inputs:
%  - source_path: Path to the anatomical MRI image file to be segmented.
%
% Outputs:
%  - The function does not return any variables, but it saves the
%  segmentation results in the specified directory.
%
% Requirements:
%  - The function relies on SPM12's TPM(Tissue Probability Map) file for
%    accurate segmentation
%
% Acknowledgment:
%
%   This function utilizes SPM12 (Statistical Parametric Mapping) for
%   image segmentation. 
%
%   For more information on SPM12, visit:
%   https://www.fil.ion.ucl.ac.uk/spm/software/spm12/
%--------------------------------------------------------------------------
function [] = tissueSeg(source_path)

    % Define the full path to the anatomical image to be segmented
    % Append ',1' to specify the first volume in the image
    img_path = fullfile([source_path,',1']);

    % Define the path to SPM12 directory containing the Tissue Probability
    % Map (TPM) file
    spm_dir = fullfile('C:', 'Users', 'gizem', 'Desktop', 'b04', 'spm', 'spm12', 'spm12');
    tpm_path = fullfile(spm_dir, 'tpm', 'TPM.nii');

    % Initialize an empty batch for SPM to hold the segmentation job
    matlabbatch = {};

    % Specitify the MRI image to be segmented
    matlabbatch{1}.spm.spatial.preproc.channel.vols = {img_path};
    matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001; % Bias regularization
    matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60; % Bias FWHM (full width at half max)
    matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0]; % No bias field correction output
   
    % Define tissue classes for segmentation
   
    % Tissue class 1: Gray Matter
    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[tpm_path, ',1']};
    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1; % Number of Gaussians
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0]; % Output native space(yes) and DARTEL-imported(no)
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0]; % No warped tissue class output

    %Tissue class 2: White Matter
    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[tpm_path, ',2']};
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
    
    % Tissue class 3: Cerebrospinal Fluid
    matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[tpm_path, ',3']};
    matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
    
    % Tissue class 4: Bone
    matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[tpm_path, ',4']};
    matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    
    % Tissue class 5: Soft Tissue
    matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[tpm_path, ',5']};
    matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
    
    % Tissue class 6: Background/Non-brain
    matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[tpm_path, ',6']};
    matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];

    % Warping and cleanup settings
    matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1; % Markov Random Field strength
    matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1; % Clean up partitions (light cleanup)
    matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2]; % Regularization of warping
    matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni'; % Affine regularization ( to MNI space)
    matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0; % No smoothing
    matlabbatch{1}.spm.spatial.preproc.warp.samp = 3; % Sampling distance
    matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0]; % No writing of normalized images
    matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN; % Voxel size(NaN for default)
    matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN % Bounding box (NaN for default)
                                              NaN NaN NaN];
    
    % Run the SPM job to perform segmentation
    spm_jobman('run', matlabbatch);

    %Clear the batch variable to free memory
    clear matlabbatch
end
