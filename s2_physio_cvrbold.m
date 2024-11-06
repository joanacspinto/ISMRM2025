%% This codes retrieves physiological recordings and creates petco2 regressors
clear all; clc; close all

sub = {'002','003','004','006','007','008','009','010','011','012','013', ...
    '014','015','016','017','018','019', '020','021','022','023','024','025'};
setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ');

path_init = '/Users/joana/OneDrive_Nexus365/TBMS';
tr=80; % TR of your sequence
nvol=450; % time of volumes *=(length of sequence)
initial=35;
nshifts=10;
air_pres = 1020; % Enter barometric pressure in mbars:
mmHg = air_pres/1.33322387415; % pressure bar
min_peak = [800, 800, 800, 700, 800, 800, 800, 800, 800, 800, 800, 600, 600, ...
    800, 800, 600, 600, 600, 800, 700, 600, 600, 800]; % visual inspection

for s = 12%:size(sub,2)
    s
    path_physio=[path_init '/' sub{s} '/derivatives/physio'];
    path_data=[path_init '/' sub{s} '/derivatives/'];
    path_data_bold=[path_init '/' sub{s} '/derivatives/bold_cvr/preproc.feat'];

    delete([path_init '/' sub{s} '/derivatives/bold_cvr/regressors/*']);
    path_out=[path_init '/' sub{s} '/derivatives/bold_cvr/regressors'];
    
    %% PETCO2 TRACE
    % Peak detection & interpolation
    physio = load([path_physio '/physio_cvrbold.txt']);
    
    [co2_peaks, co2_peaks_pos]=findpeaks(physio(:,2),'MinPeakDistance',min_peak(s), 'MinPeakHeight',max(physio(:,2))-std(physio(:,2)));
    co2_interp=interp1(co2_peaks_pos, co2_peaks, 1:size(physio(:,2)), 'linear', 'extrap');
    co2_interp=smoothdata(co2_interp, 'movmean',2000);
    
    % PETCO2 in mmHG
    co2_interp_mmHG = (co2_interp.*mmHg)./100; % petco2 in mmHg div by 100 as values are in percent
    
    %% BOLD
    bold_preproc=niftiread([path_data_bold '/filtered_func_data.nii.gz']);
    
    bold_preproc(bold_preproc==0)=NaN;
    tc_bold=squeeze(nanmean(nanmean(nanmean(bold_preproc,3),2),1));
    tc_bold_norm=(tc_bold - min(tc_bold))./(max(tc_bold) - min(tc_bold));
    tc_bold_norm_interp=interp1(1:length(tc_bold_norm),tc_bold_norm,1:1/80:length(tc_bold_norm));
    figure; plot(tc_bold_norm_interp);
    
    %% SHIFT
    corr = xcorr(tc_bold_norm_interp,co2_interp_mmHG);
    [~, corr_pos]=max(corr); 
    optimal_shift=corr_pos;
    test_shifts=optimal_shift-tr*nshifts:tr:optimal_shift+tr*nshifts;
    optimal_shift=[corr_pos, round(size(corr,2)/2)];
    writematrix(optimal_shift,[path_out '/optimal_shift.txt']); 
    
    figure;
    for shift=1:size(test_shifts,2)
        co2_interp_mmHG_oshift=circshift(co2_interp_mmHG,test_shifts(shift),2);
        
        % cut (dependent on shift) to match BOLD size (450TR)
        co2_interp_mmHG_cut=co2_interp_mmHG_oshift(1:nvol*tr);
        
        % resamp
        co2_interp_mmHG_cut_res=interp1(1:length(co2_interp_mmHG_cut),co2_interp_mmHG_cut,1:80:length(co2_interp_mmHG_cut));
       
        % normalise to 0-1
        co2_norm_out_res=(co2_interp_mmHG_cut_res - min(co2_interp_mmHG_cut_res))./( max(co2_interp_mmHG_cut_res) - min(co2_interp_mmHG_cut_res));
        plot(co2_norm_out_res); hold on;   
        
        % SAVE regressors as txt file
        writematrix(co2_norm_out_res',[path_out '/co2_norm_shift' num2str(shift) '.txt']);
        
    end
     plot(tc_bold_norm,'r');
    %% calculate and save delta petco2
    co2_mmHG_val(1)= mean(co2_interp_mmHG_cut_res(1,[134:164, 300:360])');
    co2_mmHG_val(2) = mean(co2_interp_mmHG_cut_res(1,[10:45, 206:268, 404:446])');
    co2_mmHG_val(3) = co2_mmHG_val(1)-co2_mmHG_val(2);
    writematrix(co2_mmHG_val,[path_out '/co2_delta.txt']);      
end
