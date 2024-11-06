%% This codes creates computes CVR and CVD averages across regions
clear all; clc; close all

sub = {'002','003','004','006','007','008','009','010','011','012','013','014' ...
    '015','016','017','018','019', '020','021','022','023','024','025'};

status = [1,1,1,2,1,1,2,2,1,3,2,3,2,2,3,1,2,1,1,2,3,2,1];
status2 = [1,1,1,2,1,1,2,2,1,2,2,2,2,2,2,1,2,1,1,2,2,2,1];
age=[34,34,23,33,24,27,34,29,28,29,33,31,38,26,34,26,38,31,40,35,35,42,43];
BMI = [23.6, 27.3,20.3,20.2,23.5,20.8,18.0,27.6,23.1,28.4,20.4,35.1,30.9,31.5,29.7,26.0,...
    20.0,34.8,29.2,20.1,24.6,26.9,32.6];
BPs=[101.0, 99.3,79.3,97.0,107.7,91.7,115.0,103.7,94.3,127.3,89.7,115.0,102.3,87.3,115.0,103.3,101.7,103.3,103.3,93.7,122.3,102.3,111.3];
BPd=[76.00, 81.7,58.7,61.3,68.0,67.0,79.0,74.0,59.0,79.3,62.0,96.0,79.0,65.0,80.3,80.7,76.7,69.7,71.7, 54.3,95.7,69.3, 81.3];
H2W=[1.261,1.267,1.386,1.338,1.391,1.360,1.312,1.205,1.433,1.274,1.192,1.337,1.133,1.342,1.348,1.260,1.227,1.290,1.214,1.191,1.069];
HR=[74.67,82.7,83.7,62.7,81.0,59.7,83.7,79.0,61.3,83.7,62.7,87.0,81.7,63.3,63.3,82.0,73.3,87.0,59.3,58.3,77.3,73.0,66.7];

setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ');
addpath(path,'/Users/joana/OneDrive_Nexus365/pCASL_efficiency/MATLAB/general_code')
addpath(path,'/Users/joana/OneDrive_Nexus365/pCASL_efficiency/MATLAB/general_code/NifTI_20140122/')
fsl_parallelcomp (0,1)

path_init = '/Users/joana/OneDrive_Nexus365/TBMS';

%% LOAD SUBJECT MAPS
n=23;
for s = 1:n
    s   
    path_data_stats=[path_init '/' sub{s} '/derivatives/bold_cvr/stats/'];
      path_data=[path_init '/' sub{s} '/derivatives/'];

    CVR_load=load_untouch_nii([path_data_stats 'CVR.nii.gz']);
    CVR(:,:,:,s)=CVR_load.img;
    CVD_load=load_untouch_nii([path_data_stats 'CVD.nii.gz']);
    CVD(:,:,:,s)=CVD_load.img;  
    
    delta(:,s) = load([path_data '/bold_cvr/regressors/co2_delta.txt'],'r');

    
    atlas_load=load_untouch_nii([path_data_stats 'MNI_atlas2functional.nii.gz']);
    atlas(:,:,:,s)=double(atlas_load.img);
    
    for ROI=1:max(atlas(:))
        CVR_load.img(CVR_load.img==0)=NaN;
                CVD_load.img(CVD_load.img==0)=NaN;

    CVR_avg(s,ROI)=nanmean(CVR_load.img(atlas_load.img==ROI));
    CVD_avg(s,ROI)=nanmean(CVD_load.img(atlas_load.img==ROI));
    end
end

%% STATS
ROI_vec=([ones(1,23),2*ones(1,23),3*ones(1,23),4*ones(1,23),5*ones(1,23),6*ones(1,23),7*ones(1,23),8*ones(1,23),9*ones(1,23)]);
status_vec=repmat(status2,1,9); % vector 1x207

[~,~,stats] = anovan(CVD_avg(:),{ROI_vec, status_vec}, "Model","interaction", "Varnames",["ROI","GROUP"]);
[results,~,~,gnames] = multcompare(stats, "Dimension",[1,2]);
tbl = array2table(results,"VariableNames", ...
    ["ROI","GROUP","Lower Limit","A-B","Upper Limit","P-value"]);
tbl.("ROI")=gnames(tbl.("ROI"));
tbl.("GROUP")=gnames(tbl.("GROUP"))

%% Figure

figure

model_series=[mean(CVR_avg(status2==1,:));mean(CVR_avg(status2==2,:))];
model_error=[std(CVR_avg(status2==1,:));std(CVR_avg(status2==2,:))];
b=bar(model_series, 'grouped','FaceColor','flat');
legend ('boxoff');
b(1).CData = [[1 0 0]; [1 0 0]];
b(2).CData = [[1 1 0]; [1 1 0]];
ylim([0 1]);
hold on
nbars = size(model_series, 2);
x = [];
for i = 1:nbars
    x = [x ; b(i).XEndPoints];
end
errorbar(x',model_series,model_error,'k','LineWidth', 1.5,'linestyle','none','HandleVisibility','off');
hold off
box off
ax = gca;
set(gca,'xticklabel',{'Control', 'Post-Partum'});
ylabel('Amplitude','FontSize', 12)
%%

figure; plot(CVD_avg(:,4),BMI,'*')
[h,p]=corr(CVD_avg(:,4),age')
%%
ROI=9;
[~,p]=corr(CVD_avg(3:end,ROI),H2W')
[~,p]=corr(CVD_avg(:,ROI),BMI')
%%

[h,p]=corr(CVR_avg(:,1),BPd')
figure; bar(CVR_avg')
CVR_avg_group(:,1)=nanmean(CVR_avg(status2==1,:));
CVR_avg_group(:,2)=nanmean(CVR_avg(status2==2,:));
CVR_std_group(:,1)=nanstd(CVR_avg(status2==1,:))
CVR_std_group(:,2)=nanstd(CVR_avg(status2==2,:))

figure; bar(1:9,CVR_avg_group')
hold on
er = errorbar(1:9,CVR_avg_group',CVR_std_group');    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
hold off

        
