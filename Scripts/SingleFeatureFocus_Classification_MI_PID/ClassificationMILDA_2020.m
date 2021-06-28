clear all; close all; clc;
addpath('/analyse/Project0110/labcode/')
addpath(genpath('/analyse/Project0110/labcode/gcmi/'))
addpath(genpath('/home/robini/code/gauss_info/'))
addpath(genpath('/home/robini/code/info/'))
addpath(genpath('/home/laurai/matlab/BBCBCode/tools/export_fig/'))
addpath('/home/laurai/matlab/fullfig/')
addpath(genpath('/home/laurai/matlab/Features/cbrewer/'))
addpath('/home/laurai/matlab/Marmosets/')
addpath(genpath('/home/laurai/matlab/BBCBCode/tools/export_fig/'))
addpath('/home/laurai/matlab/Features/Functions/')

load('/home/laurai/matlab/Features_CleanCode/BStrap_Joint.mat', 'AllPOWER257', ...
    'AllMedwPLI257', 'AllMedwSMI257', 'AllwPLI257', 'AllwSMI257')
load('InnerRadius.mat')

AllPOWER257=AllPOWER257(:, :, :, InnerRadius, :);
AllwPLI257=AllwPLI257(:, :, :, InnerRadius, :);
AllwSMI257=AllwSMI257(:, :, :, InnerRadius, :);


Comparison={'WN2N3REM', 'CUC', 'WREM'};

seg=50;

for comp=1:3
    if comp==1
        indsstages=[1,2,3,4]; numstages=4;
        Stages={'REM', 'N2' 'N3', 'W'}; 
        Ncond=4;
        ArrT=[zeros(seg,1); ones(seg,1); 2*ones(seg,1); 3*ones(seg,1)];
    elseif comp==2
        indsstages=[1,2,3,4]; numstages=4;
        Stages={'C', 'UC' 'UC', 'C'}; 
        Ncond=2;
        ArrT=[zeros(seg,1); ones(seg,1); ones(seg,1); zeros(seg,1)];
    elseif comp==3
        indsstages=[1,4]; numstages=2;
        Stages={'REM', 'N2' 'N3', 'W'}; 
        Ncond=2;
        ArrT=[zeros(seg,1); ones(seg,1)];
    end

NWorker=16;
NFeat=18;
Nboot=2000;
% Nperm=2000;


CollRelPSDAll=permute(AllPOWER257, [1, 5, 3, 2, 4]);
POWColl=median(CollRelPSDAll, 5);

CollPOWAll=POWColl(:, indsstages, :, :);
CollPOWAll=permute(CollPOWAll, [1,2,4,3]);


CollwPLIAll=permute(AllMedwPLI257, [1, 6, 3, 2, 4, 5]);
CollwPLIAll=CollwPLIAll(:, indsstages, 1:6, :, 1, 1);
CollwPLIAll=permute(CollwPLIAll, [1,2,4,3]);

CollwSMIAll=permute(AllMedwSMI257, [1, 6, 3, 2, 4, 5]);
CollwSMIAll=CollwSMIAll(:, indsstages, 1:6, :, 1, 1);
CollwSMIAll=permute(CollwSMIAll, [1,2,4,3]);


AllVals=cat(4, CollPOWAll, CollwPLIAll, CollwSMIAll); 

%%%%%%%%%%
iter=2000;
vars=NFeat;
numsubj=24;
%%%%%%%%%%
Nbin=4; 
Nthread=16;
%%%%%%%%%%

IIMATS=NaN(numsubj,vars,vars, Nboot);
I1S=NaN(numsubj,vars, Nboot);
IIMATSBIN=NaN(numsubj,vars,vars, Nboot);
I1SBIN=NaN(numsubj,vars, Nboot);
AllDataMix=zeros(numsubj,seg*numstages, vars, Nboot);
AllDataBin=zeros(numsubj,seg*numstages, vars,Nboot);


Labs=({Stages{indsstages}});
Labs=repmat(Labs(:), [1,seg]);
Labs=Labs.';
Labs=repmat(Labs(:), [12,1]);
LabsShort=({Stages{indsstages}});
LabsShort=repmat(LabsShort(:), [12,1]);

AllValsLDA=permute(AllVals, [2,1,4,3]);
AllValsLDA=reshape(AllValsLDA, [24*numstages, vars, Nboot]);

AccDist=NaN(Nboot, vars);

for boot=1:Nboot
    idxs=randperm(Nboot, seg);  
    %%%%%%%
    %% LDA 
        ValsAllSubs=squeeze(AllValsLDA(:, :, idxs)); % subs, stages, boots, features
        AccFeats=NaN(vars,1);
        for feat=1:vars
            ValsA=(ValsAllSubs(1:size(ValsAllSubs,1)/2,feat,:));
            ValsB=(ValsAllSubs(size(ValsAllSubs,1)/2+1:size(ValsAllSubs,1),feat,:)); 

            ValsA=permute(ValsA, [3,1,2]); ValsA=reshape(ValsA,[size(ValsA,1)*size(ValsA,2), size(ValsA,3)]);
            ValsB=permute(ValsB, [3,1,2]); ValsB=reshape(ValsB,[size(ValsB,1)*size(ValsB,2), size(ValsB,3)]);

            Acc=obtainAcc_AUG(ValsA,ValsB, Labs, seg);
            AccFeats(feat)=Acc;
        end
     AccDist(boot, :)=AccFeats;

     %%%%%%%
     %% MI
   
        for subj=1:24   
            Vals=squeeze(ValsAllSubs(subj, :, :, :));
            Vals=squeeze(AllVals(subj, :, randperm(Nboot, seg), :));
            Vals=permute(Vals, [2,1,3]);
            Vals=reshape(Vals, [seg*numstages,vars]);
            Coll=NaN(size(Vals,1),vars);

            bdat = bin.eqpop_slice_omp(Vals,Nbin,Nthread);
            bdat = int16(bdat); 
            S16 = int16(ArrT);
            Ntrl=size(bdat,1);
            for i=1:vars        
                Coll(:,i)=copnorm(Vals(:,i));
            end

            AllDataMix(subj, :, :, boot)=Coll;
            AllDataBin(subj, :, :, boot)=bdat;

            PColl=NaN(Nbin,Nbin,Nbin,(vars*(vars-1)/2));
            freqidx=0;
            I1=NaN(vars,1); I1BIN=NaN(vars,1); 
            IIMAT=NaN(vars, vars); IIMATBIN=NaN(vars, vars);
            for i=1:vars
                IABIN = info.calc_info_integer_c_int16_t(bdat(:,i),Nbin,S16,Ncond,size(Vals,1));
                IABIN = IABIN  - mmbias(Nbin,Ncond,Ntrl);            
                I1BIN(i)=IABIN;
                IA=mi_mixture_gd(Coll(:, i), ArrT, Ncond);
                I1(i)=IA;

                for j=1:vars
                    if i<j
                        IBBIN = info.calc_info_integer_c_int16_t(bdat(:,j),Nbin,S16,Ncond,size(Vals,1));
                        IBBIN = IBBIN  - mmbias(Nbin,Ncond,Ntrl);            
                        jdat = bdat(:,i)*Nbin + bdat(:,j);
                        IABBIN = info.calc_info_integer_c_int16_t(jdat,Nbin*Nbin, S16,Ncond,size(Vals,1));
                        IABBIN = IABBIN - mmbias(Nbin*Nbin,Ncond,Ntrl);


                        IB=mi_mixture_gd(Coll(:, j), ArrT, Ncond);
                        IAB=mi_mixture_gd([Coll(:, i), Coll(:, j)], ArrT, Ncond);


                        IIMAT(i,j)= (IA+IB)-IAB; 
                        IIMATBIN(i,j)= (IABIN+IBBIN)-IABBIN;        

                        %% Computation
                        freqidx=freqidx+1;

                        jDat = int16(numbase2dec(double([bdat(:, i), bdat(:,j)]'),Nbin))';
                        jDat = jDat + (Nbin^2)*S16; 
                        nTot = Nbin*Nbin*Nbin;

                        P = prob(jDat, nTot-1);        
                        P = [1-sum(P); P];
                        P = reshape(P, [Nbin Nbin Nbin]);
                        PColl(:, :, :, freqidx)=P; 

                    end
                end
            end
        
        % Used for PID script in Python
        save(['/home/laurai/matlab/Features/PVals2020/PVALs_' Comparison{comp} '_230920_Subj' num2str(subj) '_' num2str(boot) '.mat'],'PColl');               

        I1S(subj,:, boot)=I1;
        I1SBIN(subj,:, boot)=I1BIN;

        IIMATS(subj,:,:, boot)=IIMAT;
        IIMATSBIN(subj,:,:, boot)=IIMATBIN;
        end
end

save(['/home/laurai/matlab/Features/Data2020/MI_LDA_' Comparison{comp} '_230920_' num2str(Nbin) '.mat'], 'I1S', 'I1SBIN', 'IIMATS', 'IIMATSBIN', 'AccDist')


VALs=squeeze(mean(mean(IIMATS,4)));
VALs(logical(eye(18)))=mean(mean(I1S,3));
Frequencies={'Delta-PSD' 'Theta-PSD' 'Alpha-PSD' 'Sigma-PSD' 'Beta-PSD' 'Gamma-PSD' 'Delta-wPLI' 'Theta-wPLI' 'Alpha-wPLI' 'Sigma-wPLI' 'Beta-wPLI' 'Gamma-wPLI' 'Delta-wSMI' 'Theta-wSMI' 'Alpha-wSMI' 'Sigma-wSMI' 'Beta-wSMI' 'Gamma-wSMI'}
fullfig;
subplot(2,2,1)
imagesc(VALs), caxis([-1 1]*abs(max(VALs(:)))), axis square, 
set(gca, 'xtick', (1:18), 'ytick', (1:18), 'xticklabels', Frequencies, 'yticklabels', Frequencies, 'XTickLabelRotation',30,'fontsize', 5) 
colormap(flipud(cbrewer('div','RdBu',128))), 
colorbar,
title('Redundancy/Synergy (MI along diagonal) - MI Mixture')
VALs=squeeze(mean(mean(IIMATSBIN,4)));
VALs(logical(eye(18)))=mean(mean(I1SBIN,3));
subplot(2,2,2)
imagesc(VALs), caxis([-1 1]*abs(max(VALs(:)))), axis square, 
set(gca, 'xtick', (1:18), 'ytick', (1:18), 'xticklabels', Frequencies, 'yticklabels', Frequencies, 'XTickLabelRotation',30,'fontsize', 5) 
colormap(flipud(cbrewer('div','RdBu',128))), 
colorbar,
title('Redundancy/Synergy (MI along diagonal) - Binned')

subplot(2,2,3)
violin((I1S))
set(gca, 'xtick', (1:18), 'xticklabels', Frequencies,'XTickLabelRotation',30,'fontsize', 8) 
title('Mutual Information - MI Mixture')

subplot(2,2,4)
violin((I1SBIN))
set(gca, 'xtick', (1:18), 'xticklabels', Frequencies,'XTickLabelRotation',30,'fontsize', 8) 
title('Mutual Information - Binned')
suptitle('Mutual Information and Interaction Information of Wakefulness,  N2-, N3-, and REM-Sleep')
export_fig(['/home/laurai/matlab/Features/Figures/InteractionInformation_All2020' num2str(Nbin)], ...
     ['-r' num2str(150)], '-a2', '-nocrop', '-transparent');

 
end 
 
 
 
 
 
 
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% nperm=10000; nsubj=24;
% IPERMBIN=zeros(nperm, nsubj, vars);
% IPERMMIX=zeros(nperm, nsubj, vars);
% 
% subj=1;
% idx=(subj-1)*4000+1:subj*4000;
% ArrT=AllArrT(idx); 
% Ntrl=size(ArrT,1);
% 
%  %% Permutations
%  for perm=1:nperm
%     idx=randperm(Ntrl);
%     thsclass=ArrT(idx); 
%     S16 = int16(thsclass);
%  for subj=1:nsubj
%         for i=1:vars
%             
%             bsdat=squeeze(AllDataBin(subj, :, i)).';
%             bsdat=int16(bsdat);
%             
%             IABIN = info.calc_info_integer_c_int16_t(bsdat,Nbin,S16,Ncond,Ntrl);
%             IABIN = IABIN  - mmbias(Nbin,Ncond,Ntrl);            
%             IPERMBIN(perm, subj, i)=IABIN;
%             
%             IA=mi_mixture_gd(squeeze(AllDataMix(subj, :, i)).', thsclass, Ncond);
%             IPERMMIX(perm, subj,i)=IA;
%         end
%  end
%  end
 
%  save('PermTest_MI.mat', 'IPERMBIN', 'IPERMMIX')
 
%%
% % Get uncorrected P-values for features.
% PBIN=zeros(nsubj, vars);
% PMIX=zeros(nsubj, vars);
% 
% for subj=1:nsubj
%     for i=1:vars
%         PBIN(subj, i)=1-(sum(squeeze(IPERMBIN(:, subj, i)) >=I1SBIN(subj, i))./nperm);
%         PMIX(subj, i)=1-(sum(I1S(subj, i) >=squeeze(IPERMMIX(:, subj, i)))./nperm);
%     end
% end
% 
% figure;
% subplot(2,2,1)
% imagesc(PBIN), colorbar, set(gca, 'xtick', (1:18), 'xticklabels', Frequencies,'XTickLabelRotation',30,'fontsize', 8) 
% title('Uncorrected P-values (Binned MI)')
% ylabel('Subjects')
% 
% subplot(2,2,2) 
% imagesc(PMIX), colorbar, set(gca, 'xtick', (1:18), 'xticklabels', Frequencies,'XTickLabelRotation',30,'fontsize', 8) 
% title('Uncorrected P-values (Gauss MI)')
% ylabel('Subjects')
% 
% subplot(2,2,3)
% imagesc(PBIN<(0.05/18)), colorbar, set(gca, 'xtick', (1:18), 'xticklabels', Frequencies,'XTickLabelRotation',30,'fontsize', 8) 
% title('Corrected Significant Results (Binned MI; NBonf=18)')
% ylabel('Subjects')
% 
% subplot(2,2,4) 
% imagesc(PMIX<(0.05/18)), colorbar, set(gca, 'xtick', (1:18), 'xticklabels', Frequencies,'XTickLabelRotation',30,'fontsize', 8) 
% ylabel('Subjects')
% title('Corrected Significant Results (Gauss MI; NBonf=18)')
% 
% suptitle('Wakefulness vs. N2 vs. N3 vs. REM: Binned vs. Gauss MI')