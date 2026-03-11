%--------------------------------------------------------------------------
% Function: brainMask
% Gizem Külekci
% Created: 08.2024
%
% Description:
%
% This function creates a brain mask from segmented tissue probability maps.
% It assumes that SPM tissue segmentation has already been performed
% and the resulting gray matter (GM), white matter (WM) and cerebrospinal
% fluid (CSF) probability maps are avaliable in the specified directory.
%  
% Inputs:
%  - subject: Identifier for the current subject
%  - anat_dir: Directory where the anatomical imagea are stored
%  - gm_path: Path to the gray matter probability map
%  - wm_path: Path to the white matter probability map
%  - csf_path: Path to the cerebrospinal fluid probability map
%
% Outputs:
%  - The function does not return any variables, but it saves a brain mask 
%    file named 'subject_brainMask.nii' in the same directory.
%
% Requirements:
%   - SPM12 must be installed.
%--------------------------------------------------------------------------
function [] = brainMask(subject, anat_dir, gm_path, wm_path, csf_path)

    % Load segmented tissue probability images
    %gm_path = spm_select('FPList', anat_dir, ['c1',subject,'_inv-2_MP2RAGE.nii']); % Gray matter
    %wm_path = spm_select('FPList', anat_dir, ['c2',subject,'_inv-2_MP2RAGE.nii']); % White matter
    %csf_path = spm_select('FPList', anat_dir, ['c3',subject,'_inv-2_MP2RAGE.nii']); % CSF
    
    % Read the volumes of the tissue probability maps
    gm_img = spm_read_vols(spm_vol(gm_path)); % Load gray matter probability map
    wm_img = spm_read_vols(spm_vol(wm_path)); % Load white matte probability map
    csf_img = spm_read_vols(spm_vol(csf_path)); % Load CSF probability map

    % Combine the tissue probability maps to create a brain mask
    % The threshold ensures that only voxels with combined probability 
    % greater than 0.9 are included in the brain mask.
    threshold = 0.9;
    brain_mask = (gm_img + wm_img + csf_img) > threshold;
    
    % Post-process the brain mask to improve quality
    brain_mask = imfill(brain_mask, 'holes'); % Fill ant hole in the mask
    brain_mask = imopen(brain_mask, strel('disk', 2)); % Remove small noise with morphological opening
    brain_mask = imclose(brain_mask, strel('disk', 3)); % Smooth edges with morphological closing
    
    % Create a new NIfTI header using header informantion from 
    % the gray matter image
    % The brain mask will inherit the spatial orientation and resolution
    % from the gray matter image
    bm_info = spm_vol(gm_path);

    % Define the output filename and path for the brain mask
    bm_info.fname = fullfile(anat_dir, [ subject, '_brainMask.nii']);

    % Write the brain mask to a new NIfTI file
    spm_write_vol(bm_info,brain_mask);

    %Display message to confirm that brain mask has been created
    fprintf('Brain mask has been successfully created and saved as %s\n', bm_info.fname);

end

