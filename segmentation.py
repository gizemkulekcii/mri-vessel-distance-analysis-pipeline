import os
from image2segmentation import image2segmentation

# Define the home directory where the angio_data is stored
home_dir =  "C:\\Users\\gizem\\Desktop\\Omelette\\new_angio_data"

# Get a list of all subjects in the home directory
# Filters the list to include only directories within the home directory
subjects = [subject for subject in os.listdir(home_dir) if os.path.join(home_dir, subject)]

# Iterate over each subject in the subjects list
for subject in subjects: 
  
  # Construct the input path for the current subject
  input_path =  os.path.join(home_dir , subject)
  
  # Define the file name for the ToF NIfTI file to be processed
  file_name = "r" + subject + "_strippedAngio.nii"
  tof_path = os.path.join(input_path, file_name)
  
  # Define the output path where the segmentation results will be stored
  output_path = os.path.join(input_path, subject + "_output")

  # Perform the image segmentation using image2segmentation function
  # fn_tof: the NIfTI file name to process
  # dir_tof: the directory where the NIfTI file is located
  # dir_seg: the output directory where segmentation results will be saved
  # taus: tuple of thresholds to be used during segmentation
  image2segmentation(fn_tof= file_name, dir_tof=input_path, dir_seg= output_path, taus=(0.5, 0.75))
  

# Note: The image2segmentation function is taken from the following link:
# https://gitlab.com/hmattern/omelette/-/blob/master/data_and_results/benchmark/Script_Segmentation.py?ref_type=heads