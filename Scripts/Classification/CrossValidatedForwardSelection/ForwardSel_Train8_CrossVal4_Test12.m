clear all; close all; clc;

addpath(genpath('/home/laurai/matlab/BBCBCode/tools/export_fig/'))
addpath('/home/laurai/matlab/Features/Functions/')
addpath('/home/laurai/matlab/Features/')


load('/home/laurai/matlab/Data/BStrap_Joint.mat', 'AllPOWER257', ...
    'AllMedwPLI257', 'AllMedwSMI257', 'AllwPLI257', 'AllwSMI257')

COMP={'ALL', 'CUC', 'WREM'}
NWorker=18;
Nboot=2000;
Nperm=2000;


for comp=2:3
    if comp==1
        indsstages=[1,2,3,4]; numstages=4;
        Stages={'REM', 'N2', 'N3', 'W'}; 
    elseif comp==2
        indsstages=[1,2,3,4]; numstages=4;
        Stages={'C', 'UC' 'UC', 'C'}; 
    elseif comp==3
        indsstages=[1,4]; numstages=2;
        Stages={'REM', 'N2', 'N3', 'W'}; 
    end

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

for dir=1:2
    for test=1:7
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

        SEQ=zeros(Nboot,NFeat); 

        AccDist=NaN(Nboot,1);

        for bstrap=1:Nboot


            IncFeat=[];LDAAccuracy=[];
            count=0;
            status=0;


            while status==0
                count=count+1;

                AccFeats=zeros(NFeat,1);

                for feat=1:NFeat
                    if ~ismember(feat,IncFeat)
                        Feats=[IncFeat, feat];    
                        Vals=AllVals(1:size(AllVals,1)/2,Feats,bstrap);   
                        Acc=obtainAcc_84(Vals, Labs(1:size(Vals,1)));
                        AccFeats(feat)=Acc;                  
                    end
                end
                
                MultFeat=find(AccFeats==max(AccFeats));
                [MaxAcc, MaxAccFeat]=max(AccFeats); %Should give rise to the correct index now.
                LDAAccuracy(count)=MaxAcc;
                
                if length(MultFeat)>1
                   IncFeat(count)=randsample(MultFeat,1);
                else
                   IncFeat(count)=MaxAccFeat;
                end
                


               
               
%                 if length(MultFeat)>1
%                     for m=1:length(MultFeat)
%                         AccFeatsTest=NextStepForwardSelection(AllVals, Labs,bstrap, MultFeat(m), NFeat);
%                         MVAL(m)=max(AccFeatsTest);
%                     end
%                     if length(find(MVAL==max(MVAL)))>1
%                         print('Error')
%                     end
%                     IncFeat(count)=MultFeat(find(MVAL==max(MVAL)));
%                 else
%                 
%                     [MaxAcc, MaxAccFeat]=max(AccFeats); %Should give rise to the correct index now.
%                     IncFeat(count)=MaxAccFeat;
%                 end
%                 Acc=AccFeats(IncFeat(count));
%                 LDAAccuracy(count)=Acc;
%                 %% We are interested in saving files of the feature giving rise to the highest accuracy.

                
               if count>1 && (LDAAccuracy(count)<=LDAAccuracy(count-1)) && status==0 
                    status=status+1;
                    IncFeat(end:NFeat)=nan;
                    SEQ(bstrap, :)= IncFeat;
                    Vals=AllVals(:,IncFeat(1:count-1),bstrap);   
                    Acc=obtainAcc_AB(Vals, Labs, dir);
                    AccDist(bstrap)=Acc;
               elseif length(IncFeat)==NFeat && status==0
                    status=status+1;
                    IncFeat=IncFeat(1:NFeat);
                    SEQ(bstrap, :)= IncFeat;
                    Vals=AllVals(:,IncFeat(1:count-1),bstrap);   
                    Acc=obtainAcc_AB(Vals, Labs, dir);
                    AccDist(bstrap)=Acc;
               end
            end

        end
        save(['/home/laurai/matlab/Results/8412/' COMP{comp} '_' TestList{test} '_DIR' num2str(dir) '.mat'], 'SEQ', 'AccDist')
    end
end
end
% SEQ(isnan(SEQ))=0;
% [Mu,ia,ic] = unique(SEQ, 'rows', 'stable'); % Unique Values By Row, Retaining Original Order
% h = accumarray(ic, 1); % Count Occurrences
% maph = h(ic); % Map Occurrences To ?ic? Values
% Result = [SEQ, maph]
% Counter=unique(Result, 'rows', 'stable')


