import os
import numpy as np
import matplotlib.pyplot as plt
from omelette import hm_jerman, hm_filtered2skeleton
from omelette import hm_load_nii_as_np_array, hm_save_np_array_as_nii
from omelette import hm_create_mip

def image2segmentation(fn_tof, dir_tof, dir_seg, taus):
   
    # load
    data, affine, hdr = hm_load_nii_as_np_array(os.path.join(dir_tof, fn_tof))

    # get filename without extension (required later for saving)
    if fn_tof.endswith(".nii.gz"):
        fn_base = fn_tof.split(".nii.gz")[0]
    else:  # ".nii"
        fn_base = fn_tof.split(".nii")[0]

    # create output directory if required
    if not os.path.exists(dir_seg):
        os.makedirs(dir_seg)

    # plot settings
    mip_start_ax = 0
    mip_end_ax = int(data.shape[2])
    mip_start_cor = int(0.4 * data.shape[1])
    mip_end_cor = int(0.75 * data.shape[1])

    # normalize
    data = (data - np.min(data)) / (np.max(data) - np.min(data))

    # get voxel size
    voxel_size = hdr.get_zooms()

    # compute tophat size
    # - fixed to 2.5 cm (along direction with highest resolution)
    # - specified in voxels; truncated to integer
    tophat_size = np.int_(2.5//np.min(voxel_size))

    # set scales (specified in voxels)
    # - min_scale == 1 voxel
    # - max_scale == 1.5 cm (along direction with highest resolution)
    # - number of scales == 5
    scales = np.linspace(1.0, 1.5/np.min(voxel_size), 5)

    # compute pruning_cut_off
    # - any object with a volume below (1mm)^3 will be removed
    pruning_cut_off = np.int_(1//np.prod(voxel_size))

    # filter data
    for tau in taus:
        filtered, _ = hm_jerman(data, sigmas=scales, tau=tau, black_ridges=False,
                                       do_tophat=True, tophat_size=tophat_size)
        # save
        hm_save_np_array_as_nii(filtered, affine, hdr,
                                os.path.join(dir_seg, fn_base + "_filt_tau" + str(tau) + ".nii.gz"))

        # thresholding:
        _, segmentation = hm_filtered2skeleton(filtered, pruning_cut_off=pruning_cut_off)
        # save
        hm_save_np_array_as_nii(segmentation, affine, hdr,
                                os.path.join(dir_seg, fn_base + "_seg_tau" + str(tau) + ".nii.gz"))

        # do plot
        fig, axs = plt.subplots(ncols=3, nrows=2, subplot_kw={'xticks': [], 'yticks': []})
        cmap_str = "gray"

        axs[0, 0].imshow(hm_create_mip(data, mip_start_ax, mip_end_ax, projection_axis=2), cmap=cmap_str)
        axs[1, 0].imshow(hm_create_mip(data, mip_start_cor, mip_end_cor, projection_axis=1), cmap=cmap_str)

        axs[0, 1].imshow(hm_create_mip(filtered, mip_start_ax, mip_end_ax, projection_axis=2), cmap=cmap_str)
        axs[0, 2].imshow(hm_create_mip(segmentation, mip_start_ax, mip_end_ax, projection_axis=2), cmap=cmap_str)

        axs[1, 1].imshow(hm_create_mip(filtered, mip_start_cor, mip_end_cor, projection_axis=1), cmap=cmap_str)
        axs[1, 2].imshow(hm_create_mip(segmentation, mip_start_cor, mip_end_cor, projection_axis=1), cmap=cmap_str)

        # save plot
        plt.savefig(os.path.join(dir_seg, fn_base + "_overview_tau" + str(tau) + ".jpg"),
                    dpi=300,
                    format='jpg',
                    bbox_inches='tight')
        plt.close(fig)