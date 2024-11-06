%% This codes runs feat with shifted regressors
clear all; clc; close all

sub = {'002','003','004','006','007','008','009','010','011','012','013', ...
    '014','015','016','017','018','019', '020','021','022','023','024','025'};
setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ');
addpath(path,'/Users/joana/OneDrive_Nexus365/pCASL_efficiency/MATLAB/general_code')
fsl_parallelcomp (0,1)

path_init = '/Users/joana/OneDrive_Nexus365/TBMS';
path_stats=[path_init '/002/derivatives/bold_cvr/stats/shift1.feat/'];

for s = 12%:size(sub,2)
    s
    mkdir([path_init '/' sub{s} '/derivatives/bold_cvr/stats/'],'w')
    for shift=1:21
        shift
        fid  = fopen([path_stats 'design.fsf'],'r');
        f=fread(fid,'*char')';
        fclose(fid);
        f = strrep(f,'002',char(sub(s)));
        f = strrep(f,'shift1',['shift' num2str(shift)]);
        fid  = fopen([path_init '/' sub{s} '/derivatives/bold_cvr/stats/design_shift' num2str(shift) '.fsf'],'w');
        fprintf(fid,'%s',f);
        fclose(fid);
%         system(['feat ' path_init '/' sub{s} '/derivatives/bold_cvr/stats/design_shift' num2str(shift) '.fsf']);   

   
    end
    
end
