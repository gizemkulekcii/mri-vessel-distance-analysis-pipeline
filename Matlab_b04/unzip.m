%--------------------------------------------------------------------------
% Function: unzip
% Gizem Külekci
% Created: 08.2024
%
% Description:
%
%   This function unzips all `.gz` files in a specified directory. It
%   identifies `.gz` files in the given directory and extracts their
%   contents using MATLAB's `gunzip` function.
%
% Inputs:
%   - dir_path: The path to the directory containing `.gz` files (string).
%
% Outputs:
%   - The function does not return any variables. It extracts the contents
%     of the `.gz` files in the specified directory.
%
%--------------------------------------------------------------------------
function [] = unzip(dir_path)

% Get a list of all .gz files in the specified directory
gz_files = dir(fullfile(dir_path, '*.gz'));

% Iterate over each .gz file in the directory
for idx = 1: length(gz_files)
    % Construct the full path to the .gz file
    gz_file = fullfile(dir_path, gz_files(idx).name);

    % Check if the file exists 
    if isfile(gz_file) == 1
        % Unzip the .gz file
        gunzip(gz_file);
        %delete(gz_file)
        
    end
end
end