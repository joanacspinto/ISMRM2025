#!/bin/bash
# Script for BOLD CVR data analysis of The Maternal Brain Study (JPinto, Oxford, 2024)

# List of subjects
#subjects=('010')
subjects=('002' '003' '004' '006' '007' '008' '009' '010' '011' '012' '013' '014' '015' '016' '017' '018' '019' '020' '021' '022' '023' '024' '025')

mainpath=/Users/joana/OneDrive_Nexus365/TBMS

# Iterate over each subject
for sub in "${subjects[@]}"
do
echo $sub

# Defining paths
path2=${mainpath}/$sub/derivatives/bold_cvr
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

# echo "Performing reg $sub from func 2 struct"
# flirt -ref $MPRAGE -in ${path2}/preproc.feat/example_func.nii.gz -out ${outpath}/whole_func2highres -omat ${outpath}/whole_func2highres.mat

# echo "Performing reg $sub from struct 2 std"
# flirt -ref /Users/joana/fsl/data/standard/MNI152_T1_2mm_brain -in $MPRAGE -out ${outpath}/highres2standard -omat ${outpath}/highres2standard.mat

# convert_xfm -concat ${outpath}/highres2standard.mat -omat ${outpath}/example_func2standard.mat ${outpath}/whole_func2highres.mat

# flirt -ref /Users/joana/fsl/data/standard/MNI152_T1_2mm_brain -in ${path2}/stats/CVR.nii -applyxfm -init ${outpath}/example_func2standard.mat -out ${path2}/stats/CVR2standard
# flirt -ref /Users/joana/fsl/data/standard/MNI152_T1_2mm_brain -in ${path2}/stats/CVD.nii -applyxfm -init ${outpath}/example_func2standard.mat -out ${path2}/stats/CVD2standard
# fslmaths ${path2}/stats/CVR2standard -mas /Users/joana/fsl/data/standard/MNI152_T1_2mm_brain_mask ${path2}/stats/CVR2standard_masked
# fslmaths ${path2}/stats/CVD2standard -mas /Users/joana/fsl/data/standard/MNI152_T1_2mm_brain_mask ${path2}/stats/CVD2standard_masked

echo "Performing reg $sub from std 2 func"
convert_xfm -omat ${outpath}/standard2example_func.mat -inverse ${outpath}/example_func2standard.mat 
flirt -ref ${path2}/preproc.feat/example_func.nii.gz -in /Users/joana/fsl/data/atlases/MNI/MNI-maxprob-thr25-2mm -applyxfm -init ${outpath}/standard2example_func.mat -out ${path2}/stats/MNI_atlas2functional -interp nearestneighbour

done