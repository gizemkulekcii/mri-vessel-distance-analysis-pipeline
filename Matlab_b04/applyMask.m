%--------------------------------------------------------------------------
% Function: applyMask
% Gizem Külekci
% Created: 08.2024
%
% Description:
%
%  This function applies a mask to a given NIfTI image, 
%  stripping away parts of the image that are not of interest. The
%  resulting masked image is saved to the specified output path.
%
% Inputs:
%  - img_path: The file path to the NIfTI image that needs to be processed.
%  - mask_path: The file path to the binary mask that will be applied to
%    the image.
%  - output_path: The file path where the processed (masked) image will be
%    saved.
%
% Outputs:
%  - processed_image: The resulting image matrix after applying the binary
%    mask.
%
% Requirements:
% - SPM12 must be installed.
%--------------------------------------------------------------------------
function processed_img = applyMask(img_path, mask_path, output_path)

% Load the image using SPM functions
img = spm_read_vols(spm_vol(img_path));
mask = spm_read_vols(spm_vol(mask_path));

% Ensure the dimensions of the mask and the image are the same
if ~isequal(size(img), size(mask))
        error('Image and hippocampus mask have different sizes!');
end

 % Apply the mask by multipliying the binarized image with the mask
 processed_img = img .* mask;

 % Prepare header information for the processed image
 img_vol = spm_vol(img_path);
 img_vol.fname = output_path; 

 % Save the processed image
 spm_write_vol(img_vol, processed_img);

 % Display completion message
 fprintf('Processed image saved to: %s\n', output_path);

end
