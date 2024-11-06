#!/bin/bash
# Script for BOLD CVR data analysis of The Maternal Brain Study (JPinto, Oxford, 2024)

# List of subjects
subjects=('022')
#subjects=('002' '003' '004' '006' '007' '008' '009' '010' '011' '012' '013' '014' '015' '016' '017' '018' '019' '020' '021' '022' '023' '024' '025')

shift=('9')
#('1' '2' '3' '4' '5' '6' '7' '8' '9' '10')
# ('11' '12' '13' '14' '15' '16' '17' '18' '19' '20' '21')

mainpath=/Users/joana/OneDrive_Nexus365/TBMS

# Iterate over each subject
for sub in "${subjects[@]}"
do

# Defining paths
outpath=${mainpath}/$sub/derivatives/bold_cvr
for shi in "${shift[@]}"
do
    echo "Performing GLM from subject $sub with shift $shi"
    feat ${outpath}/stats/design_shift${shi}.fsf&  
   
done
done
