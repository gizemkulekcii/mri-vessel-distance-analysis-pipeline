%--------------------------------------------------------------------------
% Function: hippocampalMask
% Gizem Külekci
% Created: September 2024
%
% Description:
%
%  This function generates binary masks of the hippocampus based on the
%  hippocampal subfield segmentation obtained from ASHS tool. It selects
%  specific subfields, creates binary masks for each subfield, and then
%  combines them into a final hippocampus mask. The resulting binary masks
%  are saved as NIfTI files.
%
% Inputs:
%  - subject: Subject ID (string)
%  - ashs_dir: Directory where ASHS output is stored. (string)
%  - seg_path: Path to the hippocampal subfield segmentation file.
%  - direction: 'left' or 'right', indicating the hippocampal hemisphere.
%
% Output:
%  - hippocampusMask: Binary mask combining all selected hippocampal
%    subfields
%
% Requirements: 
%  - SPM12 must be installed.
%-------------------------------------------------------------------------
function hippocampusMask = hippocampalMask(subject,ashs_dir, seg_path, direction )

% Load the segmentation file. This contains the segmented
% hippocampal subfields for the specified hemisphere (left or right).
seg_info = spm_vol(seg_path); % Load NIfTI header information
seg_img = spm_read_vols(seg_info); % Read the data (image volume)

% Create an empty mask of the same size as the segmentation image
% This will hold the binary mask for all selected hippocampal subfields
hippocampusMask = zeros(size(seg_img));

% These are the labels for the hippocampal subfields of interest in the
% segmentation image. Subfields are labeled with integer values.
subfields = [1 2 3 4 5 8];

% Loop over subfields to create individual masks
for idx = 1:length(subfields)
    % Create a binary mask for each subfield by checking if the voxel
    % values in the segmentation image correspond to the current subfield
    subfield_mask = seg_img == subfields(idx);

    % Combine this subfield's mask with the overall hippocampus mask
    % Logical OR is used to include all selected subfields in the final
    % mask
    hippocampusMask = subfield_mask | hippocampusMask;

    % Create a copy of the NIfTI header for saving the subfield-specific
    % mask
    %subfield_info = spm_vol(seg_path);

    % Define the filename for this subfield mask
    %subfield_info.fname = fullfile(ashs_dir, [subject, '_', direction, '_label', num2str(subfields(idx)), '_hippocampusMask.nii']);
    
    % Set the data type for the NIfTI file to unsigned 8-bit
    % integers (binary mask)
    %subfield_info.dt = [spm_type('uint8'), spm_platform('bigend')]; 

    % Sve the binary mask for this subfield as a new NIfTI file
    %spm_write_vol(subfield_info, subfield_mask);
end

 % Prepare to save the final combined hippocampal mask (including all
 % subfields)
 mask_info = seg_info; % Copy the NIfTI header from the original segmentation img

 % Define the filenmae for the combined mask
 mask_info.fname = fullfile(ashs_dir,[subject,'_',direction,'_binaryHippocampusMask.nii']);

 % Set the data type for the combined mask to unsigned 8-bit integers
 mask_info.dt = [spm_type('uint8'), spm_platform('bigend')]; 

 % Write the combined hippocampus mask as a new NIfTI file
 spm_write_vol(mask_info, uint8(hippocampusMask));

end

