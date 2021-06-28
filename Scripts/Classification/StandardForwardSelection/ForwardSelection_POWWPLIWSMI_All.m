clear all; close all; clc;

%% New Script to perform LDA all-in-one
% MeanwPLI, MeanwSMI etc. are structured in the following way:
% 1D Subjects
% 2D Stages (N2, N3, REM, N2end, W1, W2) 
% 3D Frequencies (Delta, Theta, Alpha, Sigma, Beta, Gamma, Broadband)
% 4D Iterations
addpath(genpath('/home/laurai/matlab/BBCBCode/tools/export_fig/'))
addpath('/home/laurai/matlab/Features/Functions/')

% load('POW24Coll.mat');
% POWColl=permute(POWColl, [1, 2, 4, 3]);
% % load('/home/laurai/matlab/Features/RelPOW257All_Updated.mat')
% % POWColl=median(CollRelPOWAll, 5);
% % 
% % load('/home/laurai/matlab/Features/OverallColl.mat')
% % CollwPLIAll=CollwPLI;
% % CollwSMIAll=CollwSMI;
load('/home/laurai/matlab/Features_CleanCode/BStrap_Joint.mat', 'AllPOWER257', ...
    'AllMedwPLI257', 'AllMedwSMI257', 'AllwPLI257', 'AllwSMI257')
% load('/home/laurai/matlab/BStrapScripts/Results2/BStrap_All2.mat')
% 24        2000           6         257           4
% Subjects, BStrap, Freqs, Channel, Stages
% Subjects, Stages, Freqs, BStrap, Channel


% Subjects, BStrap, Freqs, BIG/SMALL, Channel, Stages
%24        2000           6           2           1      4


% Test=zeros(24,4,6,1000);
% for s=1:24
%     Test(s,:,:,:)=s;
% end
% 
% for stage=1:4
%     Test(:,stage,:,:)=Test(:,stage,:,:)+100*stage;
% end
% Test=permute(Test, [2,1,3,4]);
% Test=reshape(Test, [24*4, 6, 1000]);

NWorker=16;

Nboot=2000;
Nperm=2000;

% PermAllBStrap=zeros(NFeat,Nboot, Nperm);

indsstages=[1,2,3,4]; numstages=4;
Stages={'REM', 'N2' 'N3', 'W'}; 
%Stages={'C', 'UC' 'UC', 'C'}; 

CollRelPOWAll=permute(AllPOWER257, [1, 5, 3, 2, 4]);
POWColl=median(CollRelPOWAll, 5);

CollPOWAll=POWColl(:, indsstages, :, :);
CollPOWAll=permute(CollPOWAll, [2,1,3,4]);
CollPOWAll=reshape(CollPOWAll, [24*numstages, 6, Nboot]);


CollwPLIAll=permute(AllMedwPLI257, [1, 6, 3, 2, 4, 5]);
CollwPLIAll=CollwPLIAll(:, indsstages, 1:6, :, 1, 1);
CollwPLIAll=permute(CollwPLIAll, [2,1,3,4]);

CollwSMIAll=permute(AllMedwSMI257, [1, 6, 3, 2, 4, 5]);
CollwSMIAll=CollwSMIAll(:, indsstages, 1:6, :, 1, 1);
CollwSMIAll=permute(CollwSMIAll, [2,1,3,4]);


CollwPLIAll=reshape(CollwPLIAll, [24*numstages, 6, Nboot]);

CollwSMIAll=reshape(CollwSMIAll, [24*numstages, 6, Nboot]);

TestList={'POW', 'wPLI', 'wSMI', 'POW+wPLI', 'POW+wSMI', 'wPLI+wSMI', 'POW+wPLI+wSMI'};

Stages{indsstages};      
Labs=repmat({Stages{indsstages}}.', [24,1]);

% 
% ShuffLabsPerm=cell(size(Labs,1), Nperm);
% for perm=1:Nperm
% for s=1:24
%     FeatSubj=Labs((s-1)*numstages+1:s*numstages);
%     ShuffLabsPerm((s-1)*numstages+1:s*numstages,perm)=FeatSubj(randp(numstages));
% end
% end

load(['/home/laurai/matlab/Features_CleanCode/ALL_BStrap_OneIteration_Scheme.mat'], 'ShuffLabsPerm')

mcount=0;


for test=7
    if test==1
        AllVals=CollPOWAll; 
    elseif test==2
        AllVals=CollwPLIAll; 
    elseif test==3
        AllVals=CollwSMIAll; 
    elseif test==4
        AllVals=cat(2, CollPOWAll, CollwPLIAll); 
    elseif test==5
        AllVals=cat(2, CollPOWAll, CollwSMIAll); 
    elseif test==6
        AllVals=cat(2, CollwPLIAll, CollwSMIAll); 
    elseif test==7
        AllVals=cat(2, CollPOWAll, CollwPLIAll, CollwSMIAll); 
    end
    
NFeat=size(AllVals,2);
NFeatperModel=zeros(7,1);
LDAperModel=zeros(7,1);

CICount=zeros(NFeat,2);
Dist=zeros(NFeat,Nboot);

IncFeat=[];
count=0;
status=0;

while length(IncFeat)<NFeat
    count=count+1;
    AccFeats=zeros(NFeat,1);
    
%     tic
%     parpool(12);
%     parfor feat=1:length(idxtotest)
%         Feats=[idxtotest(feat),IncFeat];    
%         AccDist=zeros(Nboot,1);
%         for bstrap=1:Nboot
%             Vals=AllVals(:,Feats,bstrap);   
%             Acc=obtainAcc(Vals, Labs);
%             AccDist(bstrap)=Acc;
%         end
%         AccFeats(feat)=mean(AccDist);
%         AccFeats25(feat)=prctile(AccDist,2.5);
%         AccFeats975(feat)=prctile(AccDist,97.5);
%     end
%     toc    
    
   %% New Version 
    
    tic
    parpool(NWorker);
    parfor feat=1:NFeat
        if ~ismember(feat,IncFeat)
            Feats=[feat,IncFeat];    
            AccDist=zeros(Nboot,1);
            for bstrap=1:Nboot
                Vals=AllVals(:,Feats,bstrap);   
                Acc=obtainAcc(Vals, Labs);
                AccDist(bstrap)=Acc;
            end
            AccFeats(feat)=mean(AccDist);
            AccFeats25(feat)=prctile(AccDist,2.5);
            AccFeats975(feat)=prctile(AccDist,97.5);
            AccFeatsColl(feat, :)=AccDist;
        end
    end
    toc    
    delete(gcp('nocreate'))


    MultFeat=find(AccFeats==max(AccFeats));
    [MaxAcc, MaxAccFeat]=max(AccFeats); %Should give rise to the correct index now.
    LDAAccuracy(count)=MaxAcc;

    if length(MultFeat)>1
       IncFeat(count)=randsample(MultFeat,1);
       disp('WARNING: Multiple Features')
       mcount=mcount+1;
    else
       IncFeat(count)=MaxAccFeat;
    end
     
    
    CICount(count,:)=[AccFeats25(MaxAccFeat), AccFeats975(MaxAccFeat)];
    Dist(count, :)=AccFeatsColl(MaxAccFeat,:);
    %% We are interested in saving files of the feature giving rise to the highest accuracy.
   if count>1 && ((LDAAccuracy(count)<=LDAAccuracy(count-1)) || (median(Dist(count, :),2) <=median(Dist(count-1, :),2))) && status==0
       
        TLabsOrig=table(Labs);  

        status=status+1;
       
        Feats=IncFeat(1:count-1)
        NFeatperModel=length(Feats);
        LDAperModel(test)=LDAAccuracy(count-1);

        tic
        PermAll=zeros(Nperm, Nboot);
        parpool(NWorker);
        parfor perm=1:Nperm
    %             Feats=[(ind),IncFeat];  
            ShuffLabs=ShuffLabsPerm(:,perm);
%             ShuffLabs=cell(size(Labs));
%             for s=1:24
%                 FeatSubj=Labs((s-1)*numstages+1:s*numstages);
%                 ShuffLabs((s-1)*numstages+1:s*numstages)=FeatSubj(randp(numstages));
%             end
            
            PermAccDist=zeros(Nboot,1);
            for bstrap=1:Nboot
                %% Here values of the already selected features need to be combined with the new feature. 
%                 % [PrevVals, ShuffVals]
                PermAcc=obtainAcc_permshuff(AllVals(:,Feats,bstrap), ShuffLabs);
%                 if count>=1
%                     PrevVals=AllVals(:, IncFeat(1:count-1), bstrap);
%                     PermAcc=obtainAcc(cat(2, PrevVals, ShuffLabs), Labs);
%                 else
%                     PermAcc=obtainAcc([ShuffLabs], Labs);
%                 end
                PermAccDist(bstrap)=PermAcc;
            end
            PermAll(perm, :)=PermAccDist;
        end
        toc
        delete(gcp('nocreate'))
   
   end
%     tic
%     PermAll=zeros(Nboot,Nperm);
%     parpool(NWorker);
%     parfor bstrap=1:Nboot
%         PermAccDist=zeros(Nperm,1);
%         Vals=AllVals(:,MaxAccFeat,bstrap);   
%         for perm=1:Nperm
%     %             Feats=[(ind),IncFeat];  
%                 ShuffVals=zeros(size(Vals));
%                 for s=1:24
%                     FeatSubj=Vals((s-1)*numstages+1:s*numstages);
%                     ShuffVals((s-1)*numstages+1:s*numstages,1)=FeatSubj(randp(numstages));
%                 end
% 
%                 %% Here values of the already selected features need to be combined with the new feature. 
%                 % [PrevVals, ShuffVals]
%                 if count>=1
%                     PrevVals=AllVals(:, IncFeat(1:count-1), bstrap);
%                     PermAcc=obtainAcc(cat(2, PrevVals, ShuffVals), Labs);
%                 else
%                     PermAcc=obtainAcc([ShuffVals], Labs);
%                 end
%                 PermAccDist(perm)=PermAcc;
%         end
%         PermAll(bstrap, :)=PermAccDist;
%     end
%     toc
%     delete(gcp('nocreate'))
    
%     PermAllBStrap(count,:,:)=PermAll;
    % Take prctile here.   
    
end
dis=mean(PermAll,2);
p=sum(dis>=LDAperModel(test))./Nperm;

save(['/home/laurai/matlab/Results/ALL_BStrap_OneIteration_' num2str(test) '.mat'], 'IncFeat', 'LDAAccuracy', 'CICount', 'Dist', 'PermAll', 'p')

end
disp('Multiple Features')
disp(mcount)
% save(['/home/laurai/matlab/Features_CleanCode/REV1/ALL_BStrap_OneIteration_REV2000_Scheme.mat'], 'ShuffLabsPerm', 'Labs')

