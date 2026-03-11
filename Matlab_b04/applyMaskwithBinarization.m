%--------------------------------------------------------------------------
% Function: applyMaskwithBinarization
% Gizem Külekci
% Created: 08.2024
%
% Description:
%
%  This function applies a binary mask to a given NIfTI image, 
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
%
%--------------------------------------------------------------------------
function processed_img = applyMaskwithBinarization(img_path, mask_path, output_path)

% Load the image using SPM functions
% spm_vol loads the image header information(volume), and spm_read_vols
% loads the image data
img = spm_read_vols(spm_vol(img_path)); % Load the NIfTI image
mask = spm_read_vols(spm_vol(mask_path)); % Load the binary mask

 % Ensure the dimensions of the mask and the image are the same
if ~isequal(size(img), size(mask))
        error('Image and hippocampus mask have different sizes!');
end

 % Binarize the mask 
 bmask = mask > 0;

 % Apply the binary mask to the image
 % Multiplying the image by the binary mask zeros out reigons outside the
 % mask
 processed_img = img .* bmask;

 % Prepare header information for the processed image
 % Use the header from the original image to maintain spatial orientation
 % and resolution
 img_vol = spm_vol(img_path); % Load the header information
 img_vol.fname = output_path; % Set the file name for the processed image

 % Save the processed image to the specified output path
 spm_write_vol(img_vol, processed_img);

 % Display message to confirm that image has been saved to the output path
 fprintf('Processed image saved to: %s\n', output_path);

end