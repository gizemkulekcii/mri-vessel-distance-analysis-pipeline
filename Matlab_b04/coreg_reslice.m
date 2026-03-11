%--------------------------------------------------------------------------
% Function: coreg_reslice
% Gizem Külekci
% Created: September 2024
%
% Description:
%  
% This function reslices an image (source) to match the space of another image
% (reference), ensuring that both images have the same dimensions, voxel
% sizes, and orientation. 
% The reslicing is done based on coregistration between the reference
% and source images, and the function assumes that coregistration has
% already  been performed.
%
% Inputs:
%  - ref_path: Path to the reference image that defines the target space.
%  - source_path: Path to the source image that will be resliced to match
%    the reference image's space.
%
% Outputs:
%
%  - The function does not return any variables, but it saves the reslied
%  image with a prefix 'r' in front of the file name in the same directory
%  as the original source image.
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

function [] = coreg_reslice(ref_path, source_path)


    % Define the file paths for reslicing
    ref_img_path = fullfile([ref_path, ',1']); % the reference image path (the image space that the source will be resliced to)
    source_img_path = fullfile([source_path,',1']); % the source image path (the image that will be resliced)

    % Initialize an empty batch for SPM job manager
    matlabbatch = {};

    % Specify the reference image 
    matlabbatch{1}.spm.spatial.coreg.write.ref= {ref_img_path};

    % Specify the source image 
    matlabbatch{1}.spm.spatial.coreg.write.source= {source_img_path}; 

    % Reslicing options
    matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4; % Interpolation method: 4th degree B-spline
    %matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0; % Nearest Neighbour
    matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap  = [0 0 0]; % No wrapping
    matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0; % No masking
    matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r'; % Prefix for resliced files

    % Run the SPM job
    spm_jobman('run', matlabbatch);

    % Clear the batch variable after execution
    clear matlabbatch

end

