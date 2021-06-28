%% Model Comparison

Comp={'ALL', 'CUC', 'WREM'};
TestList={'POW', 'wPLI', 'wSMI', 'POW+wPLI', 'POW+wSMI', 'wPLI+wSMI', 'POW+wPLI+wSMI'};
Nboot=2000;
Nperm=2000;
Bool=zeros(3,7,7);
PVAL=NaN(3,7,7);
IntervalColl=NaN(3,7,7,2);


filepath='/Users/laura.imperatori/Desktop/ClassificationFileCollectionForGitHub/';


for comp=1:3

    for moda=1:7
        Struct1=load([filepath 'Data/ClassificationAccuracies/' Comp{comp} '_BStrap_OneIteration_REV2000_v2_' num2str(moda) '.mat']);
        idx=find(diff(mean(Struct1.Dist,2))<=0,1);%001 Struct1.LDAAccuracy
        idx(idx==0) = 1;
        
        idxmed=find(diff(median(Struct1.Dist,2))<=0,1);
        idx=min([idx, idxmed]);
        TrueA=Struct1.Dist(idx, :);
        
        for modb=1:7
            if moda > modb
                Struct2=load([filepath 'Data/ClassificationAccuracies/' Comp{comp} '_BStrap_OneIteration_REV2000_v2_' num2str(modb) '.mat']);               
                idx=find(diff(mean(Struct2.Dist,2))<=0,1);
                idx(idx==0) = 1;
                
                idxmed=find(diff(median(Struct1.Dist,2))<=0,1);
                idx=min([idx, idxmed]);
                
                TrueB=Struct2.Dist(idx, :);

                TrueDiff=TrueA-TrueB;
                
                Interval=[prctile(TrueDiff, 2.5), prctile(TrueDiff, 97.5)];
                
                IntervalColl(comp, moda, modb, :)=Interval;
          
                MeanTrueDiff=mean(TrueDiff);

                if MeanTrueDiff>0
                    PVAL(comp,moda,modb)= 2*(1+sum(TrueDiff<=0))/(1+Nboot); % Alternative (no difference): palm_pareto(0, -TrueDiff', false, 0.05, false)*2;
                elseif MeanTrueDiff<0
                    PVAL(comp,moda,modb)= 2*(1+sum(TrueDiff>=0))/(1+Nboot); % Alternative (no difference): palm_pareto(0, TrueDiff', false, 0.05, false)*2; 
                elseif MeanTrueDiff==0
                    PVAL(comp,moda,modb)=1;
                end
                if PVAL(comp,moda,modb)==0
                    PVAL(comp,moda,modb)=2/Nboot;
                end
                
                if (sign(Interval(1)) == sign(Interval(2))) && (abs(Interval(1))>0) && (abs(Interval(2))>0)
                    Bool(comp, moda, modb)=1;
                end
                
            end
        end
    end 
end
% 
Bool=Bool+0.01;
for comp=1:3
    test=(squeeze(PVAL(comp,:,:)));
    test(test>1)=1;
    [seta,setb]=find(isnan(test)==0)
    test(isnan(test)) = [];
    [h,p, ci, padj]=fdr_bh(test);
    length(find(padj<0.05))
    co1=[TestList(seta).', TestList(setb).'];
    co2a=[test', padj', h'];
    
    H_Crit=tril(squeeze(Bool(comp, :,:)));
    for i=1:7; H_Crit(i,i)=0; end
    H_Crit=H_Crit(H_Crit>0);
    H_Crit=H_Crit-0.01;
    
    intvala=squeeze(IntervalColl(comp, :, :, 1));
    intvala=intvala(tril(squeeze(PVAL(comp,:,:)))>0);
    
    intvalb=squeeze(IntervalColl(comp, :, :, 2));
    intvalb=intvalb(tril(squeeze(PVAL(comp,:,:)))>0);
    
    co2b=[intvala, intvalb, H_Crit];

    
    tab=[table(co1),table(co2a), table(co2b)]
    writetable(tab, [filepath 'Data/Stats/' Comp{comp} '.csv'])
end
% 
save([filepath 'Data/Stats/ModelSelection.mat'], 'IntervalColl', 'Bool', 'PVAL')