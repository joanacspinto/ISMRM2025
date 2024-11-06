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
for s = 1%:n
    s
    path_data=[path_init '/' sub{s} '/derivatives/'];
    path_data_bold=[path_init '/' sub{s} '/derivatives/bold_cvr/preproc.feat'];
    bold=load_untouch_nii([path_data_bold '/mean_func.nii.gz']);
    bold_mf=bold.img;
    
    path_data_stats=[path_init '/' sub{s} '/derivatives/bold_cvr/stats/'];
    for shift=1:21
        cope=niftiread([path_data_stats 'shift' num2str(shift) '.feat/stats/cope1.nii.gz']);
        zstat=niftiread([path_data_stats 'shift' num2str(shift) '.feat/thresh_zstat1.nii.gz']);
        delta  = load([path_data '/bold_cvr/regressors/co2_delta.txt'],'r');
        
        CVRshif= 100.*(cope./bold_mf)./delta(3);
        CVRshif(zstat==0)=0;
        CVR_all(:,:,:,shift)=CVRshif;       
    end
    [CVR, CVD] = max(CVR_all,[],4);
    CVD=CVD-1;
    
    bold.img=CVR;
    save_untouch_nii(bold,[path_data_stats 'CVR.nii.gz']);
    bold.img=CVD;
    save_untouch_nii(bold,[path_data_stats 'CVD.nii.gz']);
    CVR_all_all(s,:,:,:)=CVR;
    CVD_all_all(s,:,:,:)=CVD;
    
end

%%

path_init = '/Users/joana/OneDrive_Nexus365/TBMS';

for s = 1:n%size(sub,2)
    s
     path_data_stats=[path_init '/' sub{s} '/derivatives/bold_cvr/stats/'];
     path_out=[path_init '/' sub{s} '/derivatives/bold_cvr/regressors'];
    CVR_map=load_untouch_nii([path_data_stats 'CVR.nii.gz']);
    CVD_map=load_untouch_nii([path_data_stats 'CVD.nii.gz']);
    CVRD_mean(s,1)=mean(nonzeros(CVR_map.img));
    CVRD_mean(s,2)=mean(nonzeros(CVD_map.img));
    optimal=load([path_out '/optimal_shift.txt']); 
    CVRD_mean(s,4)=optimal(1);
    delta=load([path_out '/co2_delta.txt']); 
    CVRD_mean(s,5:7)=delta;
end
%%
CVRD_mean(:,3)=status(1:n);

vec = CVRD_mean(:,1);
mean(vec(CVRD_mean(:,3)==2),1)
mean(vec(CVRD_mean(:,3)==1),1)
mean(vec(CVRD_mean(:,3)>1))

[h,p]=ttest2(vec(CVRD_mean(:,3)==1),vec(CVRD_mean(:,3)==2))

[h,p]=ttest2(vec,BMI)

[h,atab,ctab,stats] = aoctool(vec,BMI, age);

%% age

age=[34,34,23,33,24,27,34,29,28,29,33,31,38,26,34,26,38,31,40,35,35,42,43];
demean_age=round(age-mean(age),1);
