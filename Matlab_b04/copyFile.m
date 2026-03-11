%-----------------------------------------------------------------------
% File name: copyFile.py
% Gizem Külekci
% Created: 09.2024
%
% Description:
%
%   This script is designed to organize and copy MRI angiography files from a 
%   set of subject folders into a new directory.
%--------------------------------------------------------------------------

% Define the home directory where subject folders are located
home_dir = fullfile('C:', 'Users', 'gizem', 'Desktop', 'b04', 'new_data');

% Get a list of all folders in the home directory
folders = dir(home_dir);

% Initialize an array to store subject names, skipping '.' and '..' entries
folderNames = cell([length(folders)-2 1]);

% Extract subject names from the folder list
for idx =1 :length(folders)-2
   folderNames(idx) = cellstr(folders(idx+2).name) ; % Store folder names as subject IDs
end

% Create a new folder named 'angio_data' in the home directory
newFolderName = 'new_angio_data'; 
mkdir(fullfile(home_dir, newFolderName));

% Loop through each subject for processing
for i = 1: length(folderNames)
    currentFolder = folderNames{i}; % Current subject's folder name

    % Define the source file path for the stripped angiography file
    sourceFile = fullfile(home_dir, currentFolder, 'anat', ['r', currentFolder, '_strippedAngio.nii']);
    
    % Create a corresponding folder in the new 'angio_data' directory for
    % the current subject
    mkdir(fullfile(home_dir, newFolderName, currentFolder));
    
    % Define the destination file path were the stripped angiography file
    % will be copied
    destinationFile = fullfile(home_dir, newFolderName, currentFolder,['r', currentFolder, '_strippedAngio.nii']);
    
    % Copy the stripped angiography file from the source to the destination
    copyfile(sourceFile, destinationFile);
end


