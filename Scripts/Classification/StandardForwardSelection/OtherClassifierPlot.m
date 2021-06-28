clear all; close all; clc;

%% Plot Classifier Results

addpath(genpath('/home/laurai/matlab/BBCBCode/tools/export_fig/'))
addpath('/home/laurai/matlab/Features/Functions/')
addpath('/home/laurai/matlab/Features/')


filepath='/Users/laura.imperatori/Desktop/ClassificationFileCollectionForGitHub/';


% load('/home/laurai/matlab/Features_CleanCode/BStrap_Joint.mat', 'AllPOWER257', ...
%     'AllMedwPLI257', 'AllMedwSMI257', 'AllwPLI257', 'AllwSMI257')

NWorker=18;

Nboot=2000;
Nperm=2000;

COMPARISON={'ALL', 'CUC', 'WREM'}
CF={'SVM', 'QuadLDA', 'LinLDA', 'NB'}
DISTColl=zeros(3,4,7,Nboot);
for comp=1
    Comp=COMPARISON{comp};
    for nclassifier=1:4
        for test=1:7
            load([filepath 'Data/ClassifierComparison/' Comp '_BStrap_OneIteration_REV_' CF{nclassifier} '_' num2str(test) '.mat'], 'IncFeat', 'LDAAccuracy', 'CICount', 'Dist')
            idx=find(diff(mean(Dist,2))<=0,1);
            idx(idx==0) = 1;
            idxmed=find(diff(median(Dist,2))<=0,1);
            idx=min([idx, idxmed]);
            
             ACC(comp, nclassifier, test)=LDAAccuracy(idx);

             DISTColl(comp, nclassifier, test, :)=Dist(idx,:);

end
end
end

save([filepath 'Data/AllClassifiers.mat'], 'ACC', 'DISTColl')

% figure;
% for comp=1
%     %subplot(1,3, comp)
%     bar(squeeze(ACC(comp, [3,2,1,4], :)))
%     set(gca, 'xticklabels', CF([3,2,1,4]))
%     title(Comp)
% end