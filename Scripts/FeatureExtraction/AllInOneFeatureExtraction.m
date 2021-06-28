%% 
clear all
close all
clc

restoredefaultpath
addpath('/home/laurai/matlab/fieldtrip-20190219/')
ft_defaults

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('/home/laurai/matlab/BStrapScripts/ScriptsforBStrap/')

SubjList;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(['/home/laurai/matlab/FilesfromCaracalla/GSN-HydroCel-257-GHmatrix.mat'],'G','H','M');

% addpath(genpath('/home/laura.imperatori/matlab/Toolboxes/CSDtoolbox/'));


addpath('/home/laurai/matlab/BBCB/')

load(['/home/laurai/matlab/FilesfromCaracalla/EyesClosed/' SubjectID{1} '/MAT/' SubjectID{1} '_EC04.mat'], 'chanlocs');
x=[chanlocs.X];
y=[chanlocs.Y];
z=[chanlocs.Z];
chanlocs={chanlocs.labels};

vars=struct();
vars.fs=500;
vars.maxorigtr=35;
vars.origeplength=4;
vars.eplength=2;
vars.maxoriglength_in_s=(vars.origeplength*vars.maxorigtr);
vars.origlength=(vars.origeplength*vars.maxorigtr*vars.fs);
vars.maxtr=floor(vars.maxoriglength_in_s/vars.eplength);
vars.length=vars.eplength*vars.maxtr*vars.fs;
vars.frames=vars.eplength*vars.fs;
vars.nbchan=257;

nrandom=15;

load('PSDFreqLegend.mat')
IDX=[StartInd, EndInd];

ntr=2000;

POWER257=zeros(24,ntr,6, 257,4);
wPLI257=zeros(24,ntr, 6, 257,2,4);
wSMI257=zeros(24,ntr,6, 257, 2,4);
MedwPLI257=zeros(24,ntr, 6, 2,1,4);
MedwSMI257=zeros(24,ntr, 6, 2,1,4);

for s = 1:24
    %% Wakefulness
    
   awakeEEG=zeros(257,vars.fs*vars.origeplength,1);
   if s<=12
       for i=4:6
       load(['/home/laurai/matlab/FilesfromCaracalla/EyesClosed/' SubjectID{s} '/MAT/' SubjectID{s} '_EC0' num2str(i) '.mat'], 'datavr');
       EEG_data=datavr(:,251:2250,:);
       awakeEEG=cat(3, awakeEEG, EEG_data);   
       clear datavr;
       end
   else
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       for i=4:6
       load(['/home/laurai/matlab/FilesfromCaracalla/PreprocessingDreamStudies/' SubjectID{s} '/MAT/' SubjectID{s} '__EC0' num2str(i) '.mat'], 'datavr');
       EEG_data=datavr(:,251:2250,:);
       awakeEEG=cat(3, awakeEEG, EEG_data);   
       clear datavr;
       end
   end
   
   awakeEEG(:,:,1)=[];    
   awakeEEG=reshape(awakeEEG, [vars.nbchan, size(awakeEEG,2)/2, 2*size(awakeEEG,3)]);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Sleep
        if s<=12
            Struct1=load(['/home/laurai/FilesSleep/scoring/' Score{s} '.mat'], 'scoring');
        else
            Struct1=load(['/home/laurai/FilesSleep/' SubjectID{s} '/' SubjectID{s} '_scoring.mat'], 'scoring');
        end
    
        scoring=Struct1.scoring;
        scoring(scoring==-1)=NaN;
        scoring(scoring== 0)=NaN;
        nbeg=find(~isnan(scoring),1,'first');
        nend=find(~isnan(scoring),1,'last');
        halfnight=nbeg+round((nend-nbeg)/2);
        
        end_n2=sum(scoring(1:halfnight) == -2);
        end_n3=sum(scoring(1:halfnight) == -3);
        end_rem=sum(scoring(:) == 1);
        remepochs=find(scoring==1);
    
    for i=1:length(remepochs) 
    
        if remepochs(i) < halfnight
            %disp('Warning: REM epochs start earlier than 3h before end of night.')
            continue
        else 
            break
        end
        
    end
    start_rem=i;

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%
    epochstarts=1:1000:14001;
    epochends=1000:1000:15000;
    %%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   W_PowerperTrial=NaN(ntr,6,257);
   W_wPLIperTrial=NaN(ntr,6,257,2);
   W_wSMIperTrial=NaN(ntr,6,257,2);
   W_MedwPLIperTrial=NaN(ntr,6,2);
   W_MedwSMIperTrial=NaN(ntr,6,2);
   
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   N2_PowerperTrial=NaN(ntr,6,257);
   N2_wPLIperTrial=NaN(ntr,6,257,2);
   N2_wSMIperTrial=NaN(ntr,6,257,2);
   N2_MedwPLIperTrial=NaN(ntr,6,2);
   N2_MedwSMIperTrial=NaN(ntr,6,2);
   
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   N3_PowerperTrial=NaN(ntr,6,257);
   N3_wPLIperTrial=NaN(ntr,6,257,2);
   N3_wSMIperTrial=NaN(ntr,6,257,2);
   N3_MedwPLIperTrial=NaN(ntr,6,2);
   N3_MedwSMIperTrial=NaN(ntr,6,2);

         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   REM_PowerperTrial=NaN(ntr,6,257);
   REM_wPLIperTrial=NaN(ntr,6,257,2);
   REM_wSMIperTrial=NaN(ntr,6,257,2);
   REM_MedwPLIperTrial=NaN(ntr,6,2);
   REM_MedwSMIperTrial=NaN(ntr,6,2);


parpool(18);
parfor trial=1:ntr 
   
       wake2inds= randperm(size(awakeEEG,3), nrandom);   
       BootEEG=awakeEEG(:,:, wake2inds);
       
       [POWColl, wPLI_med, wSMI_med, wPLI_onetoall, wSMI_onetoall] = GetMedPowandConn(BootEEG, G, H, IDX, chanlocs);
       W_PowerperTrial(trial, :, :)=POWColl; 
       W_wPLIperTrial(trial, :, :, :)=wPLI_onetoall;
       W_wSMIperTrial(trial, :, :, :)=wSMI_onetoall;
       W_MedwPLIperTrial(trial, :,:)=wPLI_med;
       W_MedwSMIperTrial(trial, :,:)=wSMI_med;


        n2inds=sort(randperm(15*(end_n2-1), nrandom));
        n2inds(n2inds==0)=[];
        n2epochs=floor(n2inds/15)+1;
        n2epochidxs=mod(n2inds,15);
        n2epochidxs(n2epochidxs==0)=15;
       count=0;
       N2CleanData=zeros(257,1000);
       for ep=1:end_n2
            if ismember(ep, n2epochs)   
               StructN2=load(['/home/laurai/FilesSleep/' SubjectID{s} '/N2/' N2{s} '_' num2str(ep,'%03.f') '.mat'], 'datavr');
               for j=1:(sum(n2epochs(:)==ep))
                   count=count+1;
                   idep=n2epochidxs(count);
                   data=StructN2.datavr(:,epochstarts(idep):epochends(idep));
                   N2CleanData=cat(3, N2CleanData, data);     
               end
            end
       end
       N2CleanData(:,:,1)=[];
       [POWColl, wPLI_med, wSMI_med, wPLI_onetoall, wSMI_onetoall] = GetMedPowandConn(N2CleanData, G, H, IDX, chanlocs);
       N2_PowerperTrial(trial, :, :)=POWColl; 
       N2_wPLIperTrial(trial, :, :, :)=wPLI_onetoall;
       N2_wSMIperTrial(trial, :, :, :)=wSMI_onetoall;
       N2_MedwPLIperTrial(trial, :,:)=wPLI_med;
       N2_MedwSMIperTrial(trial, :,:)=wSMI_med;

 %% N3 Beginning    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   
        n3inds=randperm(15*(end_n3-1), nrandom);
        n3inds(n3inds==0)=[];
        n3epochs=floor(n3inds/15)+1;
        n3epochidxs=mod(n3inds,15);
        n3epochidxs(n3epochidxs==0)=15;
       count=0;
       N3CleanData=zeros(257,1000);
       for ep=1:end_n3
            if ismember(ep, n3epochs)   
               StructN3=load(['/home/laurai/FilesSleep/' SubjectID{s}  '/N3/' N3{s} '_' num2str(ep,'%03.f') '.mat'], 'datavr');
               for j=1:(sum(n3epochs(:)==ep))
                   count=count+1;
                   idep=n3epochidxs(count);
                   data=StructN3.datavr(:,epochstarts(idep):epochends(idep));
                   N3CleanData=cat(3, N3CleanData, data);     
               end
            end
       end
       N3CleanData(:,:,1)=[];
       
       [POWColl, wPLI_med, wSMI_med, wPLI_onetoall, wSMI_onetoall] = GetMedPowandConn(N3CleanData, G, H, IDX, chanlocs);
       N3_PowerperTrial(trial, :, :)=POWColl; 
       N3_wPLIperTrial(trial, :, :, :)=wPLI_onetoall;
       N3_wSMIperTrial(trial, :, :, :)=wSMI_onetoall;
       N3_MedwPLIperTrial(trial, :,:)=wPLI_med;
       N3_MedwSMIperTrial(trial, :,:)=wSMI_med;

       %% REM   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
        reminds=15*start_rem+sort(randperm(15*(end_rem-start_rem-1), nrandom));
        remepochs=floor(reminds/15)+1;
        remepochidxs=mod(reminds,15);
        remepochidxs(remepochidxs==0)=15;
       count=0;
       REMCleanData=zeros(257,1000);
       for ep=start_rem:end_rem
            if ismember(ep, remepochs)   
               StructREM=load(['/home/laurai/FilesSleep/' SubjectID{s}  '/REM/' REM{s} '_' num2str(ep,'%03.f') '.mat'], 'datavr');
               for j=1:(sum(remepochs(:)==ep))
                   count=count+1;
                   idep=remepochidxs(count);
                   data=StructREM.datavr(:,epochstarts(idep):epochends(idep));
                   REMCleanData=cat(3, REMCleanData, data);     
               end
            end
       end
       REMCleanData(:,:,1)=[];
       
       [POWColl, wPLI_med, wSMI_med, wPLI_onetoall, wSMI_onetoall] = GetMedPowandConn(REMCleanData, G, H, IDX, chanlocs);
       REM_PowerperTrial(trial, :, :)=POWColl; 
       REM_wPLIperTrial(trial, :, :, :)=wPLI_onetoall;
       REM_wSMIperTrial(trial, :, :, :)=wSMI_onetoall;
       REM_MedwPLIperTrial(trial, :,:)=wPLI_med;
       REM_MedwSMIperTrial(trial, :,:)=wSMI_med;
       
end

delete(gcp('nocreate'))
    
    POWERperTrial=cat(4, REM_PowerperTrial, N2_PowerperTrial, N3_PowerperTrial, W_PowerperTrial); 
    wPLIperTrial=cat(5, REM_wPLIperTrial, N2_wPLIperTrial, N3_wPLIperTrial, W_wPLIperTrial); 
    wSMIperTrial=cat(5, REM_wSMIperTrial, N2_wSMIperTrial, N3_wSMIperTrial, W_wSMIperTrial); 
    MedwPLIperTrial=cat(5, REM_MedwPLIperTrial, N2_MedwPLIperTrial, N3_MedwPLIperTrial, W_MedwPLIperTrial); 
    MedwSMIperTrial=cat(5, REM_MedwSMIperTrial, N2_MedwSMIperTrial, N3_MedwSMIperTrial, W_MedwSMIperTrial); 


    POWER257(s, :, :, :, :)=POWERperTrial;
    wPLI257(s, :, :, :, :, :)=wPLIperTrial;
    wSMI257(s, :, :, :, :, :)=wSMIperTrial;
    MedwPLI257(s, :, :, :, :)=MedwPLIperTrial;
    MedwSMI257(s, :, :, :, :)=MedwSMIperTrial;

   save(['/home/laurai/matlab/BStrapScripts/Results/InterimResperSubj_BStrap_' num2str(s) '.mat'], 'POWER257', 'wPLI257', 'wSMI257', 'MedwPLI257', 'MedwSMI257', '-v7.3');   

end

save(['/home/laurai/matlab/BStrapScripts/Results/BStrap_All.mat'], 'POWER257', 'wPLI257', 'wSMI257', 'MedwPLI257', 'MedwSMI257', '-v7.3');   

