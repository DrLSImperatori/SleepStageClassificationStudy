%% Reference:
% Laura Imperatori
% University e-mail: laura.imperatori@imtlucca.it
% Lifetime e-mail: laurasophie.imperatori@gmail.com

%% Load Data
% EEG is an array of the dimensions (number of channels x number of frames
% x number of trials)

% Example Values for Initialisation:
% fs=500; % sampling frequency
% frames=1000; tr=15; % maximum number of frames and trials (segments must
% be of same length; connectivity estimation should mostly be done in 2s-segments)
% freqrange=[0.5 4; 4 8; 8 12; 12 16; 18 25; 30 45; 0.5 45];
% tau=[41, 21, 14, 10, 6, 3, 3]; % fs/(kxtau) is the maximum resolved
% frequency for wSMI.


%% CSD Transforms
% Need to include CSD toolbox in path and compute G and H for channel setup. Happy to help with this.
fdata=zeros(size(EEG));
for i=1:15
fdata(:,:,i) = CSD(squeeze(EEG(:,:,i)), G, H);
end

%% Compute Connectivity
for freq=1:6
    wpli=compute_wPLI_LI(fdata,chanlocs,tr, freqrange(freq,:), fs, 1);
%     wpli=mirror_matrix_along_diagonal(wpli); 

    [wsmi_cell]=compute_wSMI_LI(fdata, tau(freq), fs, freqrange(freq,1));
    wsmi=cell2mat(wsmi_cell);
    wsmi=mean(wsmi,3);    % Take the mean across epochs
%     wsmi=mirror_matrix_along_diagonal(wsmi);
end

% You will obtain the resulting adjacency matrices for wPLI and wSMI. If
% you want to calculate one-to-all connectivity I would suggest to make
% them symmetric using 'mirror_along_diagonal', substitute the diagonal 
% with NaN and then take the nanmean or nanmedian along rows or columns. 
