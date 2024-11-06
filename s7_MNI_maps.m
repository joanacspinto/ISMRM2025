%% This codes creates CVR and CVD maps
clear all; clc; close all

sub = {'002','003','004','006','007','008','009','010','011','012','013','014' ...
    '015','016','017','018','019', '020','021','022','023','024','025'};

status = [1,1,1,2,1,1,2,2,1,3,2,3,2,2,3,1,2,1,1,2,3,2,1];
status2 = [1,1,1,2,1,1,2,2,1,2,2,2,2,2,2,1,2,1,1,2,2,2,1];
age=[34,34,23,33,24,27,34,29,28,29,33,31,38,26,34,26,38,31,40,35,35,42,43];
BMI = [23.6, 27.3,20.3,20.2,23.5,20.8,18.0,27.6,23.1,28.4,20.4,35.1,30.9,31.5,29.7,26.0,...
    20.0,34.8,29.2,20.1,24.6,26.9,32.6];

setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ');
addpath(path,'/Users/joana/OneDrive_Nexus365/pCASL_efficiency/MATLAB/general_code')
addpath(path,'/Users/joana/OneDrive_Nexus365/pCASL_efficiency/MATLAB/general_code/NifTI_20140122/')
fsl_parallelcomp (0,1)

path_init = '/Users/joana/OneDrive_Nexus365/TBMS';

n=23;
k1=1;
k2=1;
for s = 1:n
    s
    path_data_stats=[path_init '/' sub{s} '/derivatives/bold_cvr/stats/'];
    CVR=load_untouch_nii([path_data_stats 'CVR2standard_masked.nii.gz']);
    CVD=load_untouch_nii([path_data_stats 'CVD2standard_masked.nii.gz']);
    CVR_all(:,:,:,s)=CVR.img;
    CVD_all(:,:,:,s)=CVD.img;
    
    
    if status2(s)==1
        CVR_null(:,:,:,k1)=CVR.img;
        CVD_null(:,:,:,k1)=CVD.img;
        k1=k1+1;
    elseif status2(s)==2
        CVR_multi(:,:,:,k2)=CVR.img;
        CVD_multi(:,:,:,k2)=CVD.img;
        k2=k2+1;
    end
    
    
end

CVR_multi_avg=mean(CVR_multi,4);
CVD_multi_avg=mean(CVD_multi,4);
CVR_null_avg=mean(CVR_null,4);
CVD_null_avg=mean(CVD_null,4);

%% Save

CVR.img=CVR_multi_avg;
save_untouch_nii(CVR,[path_init '/group/CVR_multi_avg.nii.gz']);
CVR.img=CVD_multi_avg;
save_untouch_nii(CVR,[path_init '/group/CVD_multi_avg.nii.gz']);
CVR.img=CVR_null_avg;
save_untouch_nii(CVR,[path_init '/group/CVR_null_avg.nii.gz']);
CVR.img=CVD_null_avg;
save_untouch_nii(CVR,[path_init '/group/CVD_null_avg.nii.gz']);


CVR.img=CVR_all;
CVR.hdr.dime.dim=[4,91,109,91,n,1,1,1,1];
save_untouch_nii(CVR,[path_init '/group/CVR_all.nii.gz']);
CVR.img=CVD_all;
save_untouch_nii(CVR,[path_init '/group/CVD_all.nii.gz']);

CVR.img=CVR_null;
bold.hdr.dime.dim=[4,91,109,91,k1,1,1,1,1];
save_untouch_nii(CVR,[path_init '/group/CVR_null.nii.gz']);
CVR.img=CVD_null;
save_untouch_nii(CVR,[path_init '/group/CVD_null.nii.gz']);
CVR.img=CVR_multi;
bold.hdr.dime.dim=[4,91,109,91,k2,1,1];
save_untouch_nii(CVR,[path_init '/group/CVR_multi.nii.gz']);
CVR.img=CVD_multi;
save_untouch_nii(CVR,[path_init '/group/CVD_multi.nii.gz']);



