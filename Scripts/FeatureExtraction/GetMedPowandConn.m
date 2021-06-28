function [POWColl, wPLI_med, wSMI_med, wPLI_onetoall, wSMI_onetoall] = GetMedPowandConn(EEG, G, H, IDX, chanlocs)
%% Reference:
% Laura Imperatori
% University e-mail: laura.imperatori@imtlucca.it
% Lifetime e-mail: laurasophie.imperatori@gmail.com

%% Load Data
% EEG is an array of the dimensions (number of channels x number of frames
% x number of trials)

% Example Values for Initialisation:
fs=500; % sampling frequency
frames=1000; tr=15; % maximum number of frames and trials (segments must
% be of same length; connectivity estimation should mostly be done in 2s-segments)
freqrange=[0.5 4; 4 8; 8 12; 12 16; 18 25; 30 45; 0.5 45];
tau=[41, 21, 14, 10, 6, 3, 3]; % fs/(kxtau) is the maximum resolved
% frequency for wSMI.

StartInd=IDX(:,1);
EndInd=IDX(:,2);

%% CSD Transforms
% Need to include CSD toolbox in path and compute G and H for channel setup. Happy to help with this.
fdata=zeros(size(EEG));
for i=1:15
fdata(:,:,i) = CSD(squeeze(EEG(:,:,i)), G, H);
end

POWColl=NaN(7, size(fdata,1));

PSD=computePSD_2019(fdata); 
for freq=1:7                   
    starti=StartInd(freq);
    endi=EndInd(freq);

    PSDINT=trapz(([freqrange(freq,1):0.5:freqrange(freq,2)].'),(PSD(:, starti:endi).'),1);
    POWColl(freq, :)=PSDINT;                                                      
end  

for freq=1:6
    POWColl(freq, :)=POWColl(freq, :)./POWColl(7,:);
end

POWColl(7,:)=[];

% Can do CSD on reduced channel set as well to compare performance.

IDXs=[33,19,47,41,15,214,2,69,59,257,183,202,94,190,95,86,101,162,178,124,149];

wPLI_med=zeros(6,1);
wSMI_med=zeros(6,1);
wPLIred_med=zeros(6,1);
wSMIred_med=zeros(6,1);


wPLI_onetoall=NaN(6, size(fdata,1));
wSMI_onetoall=NaN(6, size(fdata,1));

wPLIred_onetoall=NaN(6, size(fdata,1));
wSMIred_onetoall=NaN(6, size(fdata,1));

%% Compute Connectivity
for freq=1:6
    wpli=compute_wPLI_LI(fdata,chanlocs,tr, freqrange(freq,:), fs, 1);
    wpli=mirror_matrix_along_diagonal(wpli); 

    [wsmi_cell]=compute_wSMI_LI(fdata, tau(freq), fs, freqrange(freq,1));
    wsmi=cell2mat(wsmi_cell);
    wsmi=mean(wsmi,3);    % Take the mean across epochs
    wsmi=mirror_matrix_along_diagonal(wsmi);


% You will obtain the resulting adjacency matrices for wPLI and wSMI. If
% you want to calculate one-to-all connectivity I would suggest to make
% them symmetric using 'mirror_along_diagonal', substitute the diagonal 
% with NaN and then take the nanmean or nanmedian along rows or columns. 

wpli(wpli==0)=NaN;
wsmi(wsmi==0)=NaN;

wPLI_med(freq)=nanmedian(wpli(:));
wSMI_med(freq)=nanmedian(wsmi(:));

wPLI_onetoall(freq,:)=nanmedian(wpli);
wSMI_onetoall(freq,:)=nanmedian(wsmi);     

wplired=wpli(IDXs, IDXs);
wsmired=wsmi(IDXs, IDXs);

wPLIred_med(freq)=nanmedian(wplired(:));
wSMIred_med(freq)=nanmedian(wsmired(:));

wPLIred_onetoall(freq,1:length(IDXs))=nanmedian(wplired); 
wSMIred_onetoall(freq,1:length(IDXs))=nanmedian(wsmired);                 

end

wPLI_med=cat(2,wPLI_med, wPLIred_med);
wSMI_med=cat(2,wSMI_med, wSMIred_med);

wPLI_onetoall=cat(3,wPLI_onetoall, wPLIred_onetoall);
wSMI_onetoall=cat(3,wSMI_onetoall, wSMIred_onetoall);

end