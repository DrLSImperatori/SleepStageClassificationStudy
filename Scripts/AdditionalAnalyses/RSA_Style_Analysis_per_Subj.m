clear all; close all; clc;
addpath('/analyse/Project0234/laura/Marmosets/')
addpath('/home/laurai/matlab/Marmosets/')
addpath(genpath('/home/laurai/matlab/QTWriter/'))
addpath(genpath('/home/laurai/matlab/fullfig/'))
addpath(genpath('/home/laurai/matlab/Features/cbrewer/'))
addpath(genpath('/home/laurai/matlab/BBCB/PlottingScripts/'))


Comparison={'WN2N3REM', 'CUC', 'WREM'}
Nf=18;
nPerm=10000;
Res=NaN(7,3);
p=NaN(3,3);
for comp=1:3

NewMapRED=NaN(Nf,Nf,24);
NewMapUniX=NaN(Nf,Nf,24);
NewMapUniY=NaN(Nf,Nf,24);
NewMapSYN=NaN(Nf,Nf,24);
maxVal=NaN(24,1);
for s=1:24    

    load(['/home/laurai/matlab/Features/PVals/PID_' Comparison{comp} '_241119_Subj' num2str(s) '.mat'])
    %%%%
    maxVal(s)=max(abs(PID(:)));
    maxval=maxVal(s);
    freqidx=0;
    for fi=1:Nf
      for fj=1:Nf
          if fi<fj 
                freqidx=freqidx+1;
                NewMapRED(fi,fj,s)=PID(freqidx,1)./sum(PID(freqidx,:),2);
                NewMapUniX(fi,fj,s)=PID(freqidx,2)./sum(PID(freqidx,:),2);
                NewMapUniY(fi,fj,s)=PID(freqidx,3)./sum(PID(freqidx,:),2);
                NewMapSYN(fi,fj,s)=PID(freqidx,4)./sum(PID(freqidx,:),2);
                
                                
                NewMapRED(fj,fi,s)=NewMapRED(fi,fj,s);
                NewMapUniY(fj,fi,s)=NewMapUniX(fi,fj,s);    
                NewMapUniX(fj,fi,s)=NewMapUniY(fi,fj,s); 
                NewMapSYN(fj,fi,s)=NewMapSYN(fi,fj,s);
          end
      end
    end
end    
    
    MeanRED=(NewMapRED);
    
    idx1=1:6;
    idx2=7:12;
    idx3=13:18;
    
    VALs=MeanRED(idx1, idx1,:);
    POWRed=nanmean(reshape(VALs, [36, 1, 24]),1);
    POWRed=POWRed(:);
    VALs=MeanRED(idx2, idx2,:);
    wPLIRed=nanmean(reshape(VALs, [36, 1, 24]),1);
    wPLIRed=wPLIRed(:);
    VALs=MeanRED(idx3, idx3,:);
    wSMIRed=nanmean(reshape(VALs, [36, 1, 24]),1);
    wSMIRed=wSMIRed(:);
    VALs=MeanRED(idx1, idx2,:);
    POWwPLIRed=nanmean(reshape(VALs, [36, 1, 24]),1);
    POWwPLIRed=POWwPLIRed(:);
    VALs=MeanRED(idx1, idx3,:);
    POWwSMIRed=nanmean(reshape(VALs, [36, 1, 24]),1);
    POWwSMIRed=POWwSMIRed(:);
    VALs=MeanRED(idx2, idx3,:);
    wPLIwSMIRed=nanmean(reshape(VALs, [36, 1, 24]),1);
    wPLIwSMIRed=wPLIwSMIRed(:);
    
    
    
    %% Permutation Test
    p(1, comp)=permtestcomplete(POWRed,wPLIRed, 'Paired', 'both', nPerm);
    p(2, comp)=permtestcomplete(POWRed,wSMIRed, 'Paired', 'both', nPerm);
    p(3, comp)=permtestcomplete(wPLIRed,wSMIRed, 'Paired', 'both', nPerm);
    p(4, comp)=permtestcomplete(POWwPLIRed,POWwSMIRed, 'Paired', 'both', nPerm);
    p(5, comp)=permtestcomplete(POWwPLIRed,wPLIwSMIRed, 'Paired', 'both', nPerm);
    p(6, comp)=permtestcomplete(POWwSMIRed,wPLIwSMIRed, 'Paired', 'both', nPerm);

    psr(1, comp)=signrank(POWRed,wPLIRed, 'tail', 'both');
    psr(2, comp)=signrank(POWRed,wSMIRed, 'tail', 'both');
    psr(3, comp)=signrank(wPLIRed,wSMIRed, 'tail', 'both');

    
%     AllRed=nanmean(MeanRED(:));
%     
%     Res(:,comp)=[POWRed, wPLIRed, wSMIRed, POWwPLIRed, POWwSMIRed, wPLIwSMIRed, AllRed];
end

%     Pairs={'Within-POW', 'Within-wPLI', 'Within-wSMI', 'POW-wPLI', 'POW-wSMI', 'wPLI-wSMI', 'All'}
%     fullfig
%     bar(Res), legend(Comparison)
%     set(gca, 'xticklabel', Pairs)
%     title(['Average Redundancy across Features'])
%     export_fig(['/home/laurai/matlab/Features/RelPow/RSAStyle_DECPID'],...
%      ['-r' num2str(150)], '-a2', '-nocrop', '-transparent');

