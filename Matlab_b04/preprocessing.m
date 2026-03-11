%-----------------------------------------------------------------------
% File name: preprocessing.py
% Gizem Külekci
% Created: August 2024
% Last Modified: 30.08.2024
%
% Description:
%
%   This script processes MRI data for multiple subjects by performing
%   tissue segmentation, brain masking, coregistration, and applying binary
%   masks to anatomical.
%
% Requirements:
%
% - SPM12 must be installed.
%-----------------------------------------------------------------------
clc; % Clear command window
clear; % Clear workspace

% Initialize SPM with default settings for fMRI and configure the job
% manager
spm('defaults', 'fMRI'); % Load SPM's default configurations for fMRI processing
spm_jobman('initcfg'); % Initialize the SPM job manager

% Define the home directory where subject folders are located
home_dir = fullfile('C:', 'Users', 'gizem', 'Desktop', 'b04', 'new_data');

% Get a list of all folders in the home directory
folders = dir(home_dir);

% Initialize an array to store subject names, skipping '.' and '..' entries
subjects = cell([length(folders)-2 1]);

% Extract subject names from the folder list
for idx =1 :length(folders)-2
   subjects(idx) = cellstr(folders(idx+2).name) ; % Store folder names as subject IDs
end

% Loop through each subject for processing
for i = 1: length(subjects)
    subject = subjects{i}; % Get the current subject ID

    % Define the directory where the anatomical files are located
    anat_dir = fullfile(home_dir, subject, 'anat');
    
    % Unzip any compressed files in the anatomical directory
    unzip(anat_dir);

    % Define paths for the reference image(ToF) and source
    % image(T1-weighted)
    ref_img_path = fullfile(anat_dir,[subject,'_angio.nii']);
    source_img_path = fullfile(anat_dir,[subject,'_inv-2_MP2RAGE.nii']);
    
    % Perform tissue segmentation on the source image
    % This function segments the anatomical image into different tissue types
    tissueSeg(source_img_path);

    % Load segmented tissue probability images
    gm_path = spm_select('FPList', anat_dir, ['c1',subject,'_inv-2_MP2RAGE.nii']); % Gray matter
    wm_path = spm_select('FPList', anat_dir, ['c2',subject,'_inv-2_MP2RAGE.nii']); % White matter
    csf_path = spm_select('FPList', anat_dir, ['c3',subject,'_inv-2_MP2RAGE.nii']); % CSF(Cerebrospinal Fluid)
   
    % Generate a brain mask based on the tissue segmentation results
    brainMask(subject, anat_dir, gm_path, wm_path, csf_path);
    
    % Define path for the brain mask image
    other_img_path = fullfile(anat_dir,[subject,'_brainMask.nii']);
   
    % Perform coregistration between the reference image(ToF), source
    % image(T1-weighted) and the brain mask
    % Coregistration aligns the images to a common space for further
    % processing
    coregistration(ref_img_path,source_img_path, other_img_path);
    
    % Define paths for the coregistered T1-weighted image and brain mask 
    t1_path = fullfile(anat_dir, ['r', subject, '_inv-2_MP2RAGE.nii']);
    brain_mask_path = fullfile(anat_dir, ['r', subject, '_brainMask.nii']);
    
    % Define path for the Time-of-Flight(ToF) image
    tof_path = fullfile(anat_dir, [subject, '_angio.nii']);
    
    % Apply a binary mask to the T1-weighted image using the brain mask
    % This step binarizes the T1 image and applies the brain mask to it
    stripped_t1 = applyMaskwithBinarization(t1_path, brain_mask_path, fullfile(anat_dir,['r', subject, '_strippedT1.nii']));
    
    % Define path for the stripped (masked) T1 image
    stripped_t1_path = fullfile(anat_dir, [ 'r', subject, '_strippedT1.nii']);
    
    % Apply a binary mask to the ToF image using the stripped T1 image as a
    % mask
    %This step binarizes the ToF image and applies the stripped T1
    %image as the mask
    stripped_angio = applyMaskwithBinarization(tof_path, stripped_t1_path, fullfile(anat_dir,['r', subject, '_strippedAngio.nii']));

end

%-----------------------------------------------------------------------
% End of script
%-----------------------------------------------------------------------