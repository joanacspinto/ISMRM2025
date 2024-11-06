#!/bin/bash
# Script for BOLD CVR data analysis of The Maternal Brain Study (JPinto, Oxford, 2024)

# List of subjects
subjects=('003' '004' '006' '007' '008' '009' '010' '011' '012' '013' '014' '015' '016' '017' '018' '019' '020' '021' '022' '023' '024' '025')
#subjects=('002' '003' '004' '006' '007' '008' '009' '010' '011' '012' '013' '014' '015' '016' '017' '018' '019' '020' '021' '022' '023' '024' '025')

mainpath=/Users/joana/OneDrive_Nexus365/TBMS

# Iterate over each subject
for sub in "${subjects[@]}"
do
echo $sub

# Defining paths
path2=${mainpath}/$sub/derivatives/bold_cvr
mkdir ${mainpath}/$sub/derivatives/bold_cvr/fast
mkdir ${mainpath}/$sub/derivatives/bold_cvr/reg
outpath=${mainpath}/$sub/derivatives/bold_cvr/reg

if [ $sub = '006' ];
then
MPRAGE=${mainpath}/$sub/MRI/images_033_t1_mpr_ax_1mm_iso_PSN.nii
elif [ $sub = '010' ];
then
MPRAGE=${mainpath}/$sub/MRI/images_029_t1_mpr_ax_1mm_iso_PSN.nii
elif [ $sub = '017' ];
then
MPRAGE=${mainpath}/$sub/MRI/images_025_t1_mpr_ax_1mm_iso_PSN.nii
elif [ $sub = '025' ];
then
MPRAGE=${mainpath}/$sub/MRI/images_025_t1_mpr_ax_1mm_iso_PSN.nii
else 
MPRAGE=${mainpath}/$sub/MRI/images_028_t1_mpr_ax_1mm_iso_PSN.nii
fi

# Perform registration
echo "Performing segmentation on struct $sub"
mkdir ${mainpath}/$sub/derivatives/fast

bet ${MPRAGE} ${mainpath}/$sub/derivatives/fast/brain_bet -m
fast -g -p -o ${mainpath}/$sub/derivatives/fast/fast ${mainpath}/$sub/derivatives/fast/brain_bet

echo "Performing registration on tissues $sub"
convert_xfm -omat ${outpath}/highres2whole_func.mat -inverse ${outpath}/whole_func2highres.mat

flirt -ref ${path2}/preproc.feat/example_func.nii.gz -in ${mainpath}/$sub/derivatives/fast/fast_seg_0.nii.gz -applyxfm -init ${outpath}/highres2whole_func.mat -out ${path2}/fast/seg_02func -interp nearestneighbour
flirt -ref ${path2}/preproc.feat/example_func.nii.gz -in ${mainpath}/$sub/derivatives/fast/fast_seg_1.nii.gz -applyxfm -init ${outpath}/highres2whole_func.mat -out ${path2}/fast/seg_12func -interp nearestneighbour
flirt -ref ${path2}/preproc.feat/example_func.nii.gz -in ${mainpath}/$sub/derivatives/fast/fast_seg_2.nii.gz -applyxfm -init ${outpath}/highres2whole_func.mat -out ${path2}/fast/seg_22func -interp nearestneighbour

flirt -ref ${path2}/preproc.feat/example_func.nii.gz -in ${mainpath}/$sub/derivatives/fast/fast_pve_1.nii.gz -applyxfm -init ${outpath}/highres2whole_func.mat -out ${path2}/fast/pve_12func -interp nearestneighbour

done