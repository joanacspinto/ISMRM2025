%% This codes retrieves physiological recordings and splits into corresponding MR sequence
clear all; clc; close all

sub = {'002','003','004','006','007','008','009','010','011','012','013', ...
    '014','015','016','017','018','019', '020','021','022','023','024','025'};
setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ');

% SET PATHS AND VARIABLES
path_init = '/Users/joana/OneDrive_Nexus365/TBMS';
thres = 3; % threshold for peak detection
extra = 2800; % ms extra datapoints before and after (35TR, 28s)
TR_BOLD = 80;
TR_ASL = 410;
% Cut timecourses
for s = 1:size(sub,2)
    path = [path_init '/' sub{s} '/Physio/'];
    mkdir([path_init '/' sub{s} '/derivatives/physio']);
    path_physio=[path_init '/' sub{s} '/derivatives/physio/'];
    
    %% CO2 & O2
    % Exceptions, files that were split in data acquisition
%     if s == 5
%         physio1 = readtable([path 'TMBS_' num2str(sub{s}) '.txt']); % data split in two text files
%         physio2 = readtable([path 'TMBS_' num2str(sub{s}) '_02.txt']);
%         physio = cat(1, physio1, physio2);
%     else
%         physio = readtable([path 'TMBS_' num2str(sub{s}) '.txt']);
%     end
%     
%     % Cut additional triggers at beginning (if applicable)
%     if s == 6 || s == 7
%         physio = physio (30000:end,:);
%     elseif s == 8
%         physio = physio (50000:end,:);
%     elseif s == 23
%         physio = physio (75000:end,:);
%     end
%     physio = physio (10000:end,:);
%     
%     figure;plot(str2double(physio.Channel1), 'g'); hold on; plot(str2double(physio.Channel3), '.');
%     
%     % Select subset based on triggers
%     format longg
%     MR=str2double(physio.Channel3);
%     [MR_pos,~]=find(MR(:)>thres); % find triggers
%     trans=find(diff(MR_pos)>1000); % where the difference between triggers is higher than a value
%     
%     % Reordering (participants that require reordering of sequences)
%     if s == 15
%         start = [MR_pos(1) MR_pos(trans(2)-96) MR_pos(trans(3)+1) MR_pos(trans(3)-47)]; % find starting point
%         stop = [MR_pos(trans(1))+TR_BOLD MR_pos(trans(2))+TR_ASL MR_pos(end)+TR_BOLD MR_pos(trans(3))+TR_ASL]; % find end
%     else
%         start = [MR_pos(1) MR_pos(trans(1)+1) MR_pos(trans(2)+1) MR_pos(trans(3)+1)]; % find starting point
%         stop = [MR_pos(trans(1))+TR_BOLD MR_pos(trans(2))-3 MR_pos(trans(3))+400 MR_pos(end)+TR_BOLD]; % find end
%     end
%     
%     % Split into specific sequences
%     physio_cvrbold = [];
%     physio_cvrbold(1,:) =  str2double(physio.ChannelTitle_(start(1)-extra:stop(1)+extra));
%     physio_cvrbold(2,:) =  str2double(physio.Channel1(start(1)-extra:stop(1)+extra));
%     physio_cvrbold(3,:) =  str2double(physio.Channel2(start(1)-extra:stop(1)+extra));
%     physio_cvrbold(4,:) =  str2double(physio.Channel3(start(1)-extra:stop(1)+extra));
%     figure;plot(physio_cvrbold(2,:), 'g'); hold on; plot(physio_cvrbold(4,:), '.');
%     
%     physio_rsasl = [];
%     physio_rsasl(1,:) = str2double(physio.ChannelTitle_(start(2)-extra:stop(2)+extra));
%     physio_rsasl(2,:) = str2double(physio.Channel1(start(2)-extra:stop(2)+extra));
%     physio_rsasl(3,:) = str2double(physio.Channel2(start(2)-extra:stop(2)+extra));
%     physio_rsasl(4,:) = str2double(physio.Channel3(start(2)-extra:stop(2)+extra));
%     figure;plot(physio_rsasl(2,:), 'g'); hold on; plot(physio_rsasl(4,:), '.');
%     
%     physio_hyperasl = [];
%     physio_hyperasl(1,:) =  str2double(physio.ChannelTitle_(start(3)-extra:stop(3)+extra));
%     physio_hyperasl(2,:) = str2double(physio.Channel1(start(3)-extra:stop(3)+extra));
%     physio_hyperasl(3,:) = str2double(physio.Channel2(start(3)-extra:stop(3)+extra));
%     physio_hyperasl(4,:) = str2double(physio.Channel3(start(3)-extra:stop(3)+extra));
%     figure;plot(physio_hyperasl(2,:), 'g'); hold on; plot(physio_hyperasl(4,:), '.');
%     
%     physio_rsbold = [];
%     physio_rsbold(1,:) =  str2double(physio.ChannelTitle_(start(4)-extra:stop(4)+extra));
%     physio_rsbold(2,:) = str2double(physio.Channel1(start(4)-extra:stop(4)+extra));
%     physio_rsbold(3,:) = str2double(physio.Channel2(start(4)-extra:stop(4)+extra));
%     physio_rsbold(4,:) = str2double(physio.Channel3(start(4)-extra:stop(4)+extra));
%     figure;plot(physio_rsbold(2,:), 'g'); hold on; plot(physio_rsbold(4,:), '.');
%     
%     % Save data separately
%     writematrix(physio_cvrbold',[path_physio '/physio_cvrbold.txt']);
%     writematrix(physio_rsasl',[path_physio '/physio_rsasl.txt']);
%     writematrix(physio_hyperasl',[path_physio '/physio_hyperasl.txt']);
%     writematrix(physio_rsbold',[path_physio '/physio_rsbold.txt']);
    
    
    %% CARDIAC & RESP
    if s == 5
        physio3 = load([path 'TMBS_bio_' num2str(sub{s}) '.txt']); % data split in two text files
        physio4 = load([path 'TMBS_bio_' num2str(sub{s}) '_02.txt']);
        physio_bio = vertcat(physio3, physio4);
    else
        physio_bio = load([path 'TMBS_bio_' num2str(sub{s}) '.txt']);
    end
    
  %  Cut additional triggers at beginning (if applicable)
   
    physio_bio = physio_bio (40000:end,:);
   figure; plot(physio_bio(:,1)); hold on; plot(physio_bio(:,2), 'b'); plot(physio_bio(:,3),'.')

  %  Select subset based on triggers
    bio=physio_bio(:,3);
    [MR_pos,~]=find(bio(:)>3); % find triggers
    trans=find(diff(MR_pos)>15000); % where the difference between triggers is higher than a value
    
   % Reordering (participants that require reordering of sequences)
    if s == 15
          start = [MR_pos(1) MR_pos(trans(2)-96) MR_pos(trans(3)+1) MR_pos(trans(3)-47)]; % find starting point
        stop = [MR_pos(trans(1))+TR_BOLD MR_pos(trans(2))+TR_ASL MR_pos(end)+TR_BOLD MR_pos(trans(3))+TR_ASL]; % find end
    else
        start = [MR_pos(1) MR_pos(trans(1)+1) MR_pos(trans(2)+1) MR_pos(trans(3)+1)]; % find starting point
        stop = [MR_pos(trans(1))+TR_BOLD MR_pos(trans(2))-3 MR_pos(trans(3))+400 MR_pos(end)+TR_BOLD]; % find end
    end
    
    bio_rsbold = [];
    bio_rsbold(1,:) = physio_bio(start(4):stop(4),1);
    bio_rsbold(2,:) = physio_bio(start(4):stop(4),2);
    bio_rsbold(3,:) = physio_bio(start(4):stop(4),3);
  
   
    writematrix(bio_rsbold',[path_physio '/card_resp_rsbold.txt']);
    
    figure;plot(bio_rsbold(1,:), 'g'); hold on; plot(bio_rsbold(2,:), 'r');
    
    
end



