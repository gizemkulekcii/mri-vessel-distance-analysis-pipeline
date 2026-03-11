%-------------------------------------------------------------------------
% File name: hippocampus_seg.m
% Gizem Külekci
% Created: September 2024
%
% Description:
%
%  This script processes MRI data by applying hippocampal masks to
%  Time-of-Flight (ToF) angiography images for multiple subjects.
%
% Requirements:
% - SPM12 must be installed.
% - Hippocampal subfield segmentation files should already be generated
%   using ASHS
%-------------------------------------------------------------------------
clc; % Clear command window
clear; % Clear workspace

% Initialize SPM with default settings for fMRI processing
spm('defaults', 'FMRI');  % Load SPM's default configurations for fMRI
spm_jobman('initcfg');  % Initialize the SPM job manager

% Define the home directory where the data is stored
home_dir = fullfile('C:', 'Users', 'gizem', 'Desktop','ashs');

% Define the directory path containing subject folders
subject_names = fullfile(home_dir);

% Get a list of all folders in the data directory
folders = dir(subject_names);

% Initialize an array to store subject names, skipping '.' and '..' entries
subjects = cell([length(folders)-2 1]); % '-2' to exclude '.' and '..'

% Extract subject names from the folder list
for idx =1 :length(folders)-2
   subjects(idx) = cellstr(folders(idx+2).name) ; % Store folder names as subject IDs
end

% Process each subject in the dataset
for i = 1: length(subjects)
    subject = subjects{i}; % Current subject ID
   
    % Define directory paths
    anat_dir = fullfile(home_dir, subject, 'anat'); % Path for anatomical images
    ashs_dir = fullfile(home_dir, subject); % Path for ASHS segmentation data
    ashs_final_dir = fullfile(ashs_dir, 'final'); % Path for ASHS/Final output directory
    
    % If the directoies are zipped, unzip them
    unzip(ashs_dir);
    unzip(ashs_final_dir);

    % Define paths for images 
    tof_path = fullfile(anat_dir, [subject, '_angio.nii']);  % Path to ToF image
    t1_path = fullfile(anat_dir, [subject, '_inv-2_MP2RAGE.nii']);  % Path to T1-weighted image
    t2_path = fullfile(ashs_dir, 'tse.nii');  % Path to T2-weighted image

    % Define paths for the hippocampal subfield segmentations (left and right)
    left_hs_path = fullfile(ashs_final_dir, [subject, '_left_lfseg_corr_nogray.nii']);
    right_hs_path = fullfile(ashs_final_dir, [subject, '_right_lfseg_corr_nogray.nii']);
    
    hs_paths = {left_hs_path; right_hs_path};

    % Coregister ToF and T2-weighted images to the T1-weighted image space
    coreg_est(t1_path, t2_path, hs_paths); % Coregister T2 to T1
    coreg_est2(t1_path, tof_path); % Coregister ToF to T1

    % Generate binary masks for the left and right hippocampal regions
    left_hippocampusMask = hippocampalMask(subject, ashs_final_dir, left_hs_path, 'left');
    right_hippocampusMask = hippocampalMask(subject, ashs_final_dir, right_hs_path, 'right');

    % Define paths for the saved binary hippocampal masks (left and right)
    left_hp_path = fullfile(ashs_final_dir,[subject,'_left_binaryHippocampusMask.nii']);
    right_hp_path = fullfile(ashs_final_dir,[subject,'_right_binaryHippocampusMask.nii']);

    % Coregister (reslice) the binary hippocampal masks to the ToF image space
    coreg_reslice(tof_path, left_hp_path);  % Reslice left mask to ToF space
    coreg_reslice(tof_path, right_hp_path);  % Reslice right mask to ToF spac

 
end

%-----------------------------------------------------------------------
% End of script
%-----------------------------------------------------------------------