close all; clear all; clc;
addpath(genpath('D:\MATLAB\fullfig\'))

filepath='/Users/laura.imperatori/Desktop/ClassificationFileCollectionForGitHub/';

TestList={'POW', 'wPLI', 'wSMI', 'POW+wPLI', 'POW+wSMI', 'wPLI+wSMI', 'POW+wPLI+wSMI'};
% Frequencies={'Delta', 'Theta', 'Alpha', 'Sigma', 'Beta', 'Gamma','Delta1', 'Theta1', 'Alpha1', 'Sigma1', 'Beta1', 'Gamma1','Delta2', 'Theta2', 'Alpha2', 'Sigma2', 'Beta2', 'Gamma2' }
String={'Top 20: Dataset 1 to Dataset 2' , 'Top 20: Dataset 2 to Dataset 1', 'Top 20: Mean Occurrence'}
Comparison={'ALL', 'CUC', 'WREM'}
Nboot=2000;
MeanAcc=zeros(3,7);
StdAcc=zeros(3,7);
COUNTOCCMean=zeros(18,3,7);
AccOCCMean=zeros(18,3,7);
for cond=1:3
for comp=1:7
    if comp<=3
      Frequencies={'Delta', 'Theta', 'Alpha', 'Sigma', 'Beta', 'Gamma','Delta1', 'Theta1', 'Alpha1', 'Sigma1', 'Beta1', 'Gamma1','Delta2', 'Theta2', 'Alpha2', 'Sigma2', 'Beta2', 'Gamma2' }
    elseif comp==4
      Frequencies={'DeltaPow', 'ThetaPow', 'AlphaPow', 'SigmaPow', 'BetaPow', 'GammaPow','DeltawPLI', 'ThetawPLI', 'AlphawPLI', 'SigmawPLI', 'BetawPLI', 'GammawPLI' }
    elseif comp==5
      Frequencies={'DeltaPow', 'ThetaPow', 'AlphaPow', 'SigmaPow', 'BetaPow', 'GammaPow','DeltawSMI', 'ThetawSMI', 'AlphawSMI', 'SigmawSMI', 'BetawSMI', 'GammawSMI'}
    elseif comp==6
      Frequencies={'DeltawPLI', 'ThetawPLI', 'AlphawPLI', 'SigmawPLI', 'BetawPLI', 'GammawPLI','DeltawSMI', 'ThetawSMI', 'AlphawSMI', 'SigmawSMI', 'BetawSMI', 'GammawSMI'}
    elseif comp==7
      Frequencies={'DeltaPow', 'ThetaPow', 'AlphaPow', 'SigmaPow', 'BetaPow', 'GammaPow', 'DeltawPLI', 'ThetawPLI', 'AlphawPLI', 'SigmawPLI', 'BetawPLI', 'GammawPLI','DeltawSMI', 'ThetawSMI', 'AlphawSMI', 'SigmawSMI', 'BetawSMI', 'GammawSMI'}
    end
    
% %     fullfig;
    COUNTOCC=zeros(18,2);
    AccOccCalc=zeros(18,2);
    for dir=1:2
        load([filepath 'Data/CrossValidatedForwardSelection/' Comparison{cond} '_' TestList{comp} '_DIR' num2str(dir) '.mat'], 'SEQ', 'AccDist')
        [COUNTOCC(:,dir) AccOcc]=CountOccinSEQs(SEQ, AccDist);
        AccOccCalc(:,dir)=AccOcc./COUNTOCC(:,dir);
    end
    COUNTOCCMean(:,cond, comp)=mean(COUNTOCC,2);
    AccOCCMean(:,cond, comp)=mean(AccOccCalc,2);

end
end
figure;
subplot(2,1,1)
bar(squeeze(COUNTOCCMean(:, :, 7))/2000);
subplot(2,1,2)
bar(squeeze(AccOCCMean(:, :, 7)));

save([filepath 'Data/CrossValidatedForwardSelection.mat'], 'AccOCCMean' , 'COUNTOCCMean')