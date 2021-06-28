function Acc=obtainAcc_permshuff(Vals, ShuffLabs)
    TTest=array2table(Vals);
    TClass=table(ShuffLabs);  
    TTest=[TTest, TClass];
    Accuracy=NaN(2,1);
    for dir=1:2
        if dir==1
            idxTrn=1:size(TTest,1)/2;
            idxTest=size(TTest,1)/2+1:size(TTest,1);
        elseif dir==2
            idxTest=1:size(TTest,1)/2;
            idxTrn=size(TTest,1)/2+1:size(TTest,1);
        end
    T1 = TTest(idxTrn,:);
    T2 = TTest(idxTest,:);
    Mdl = fitcdiscr(T1(:,1:(size(T1,2)-1)),T1(:,size(T1,2)), 'DiscrimType', 'linear'); %, 'DiscrimType', 'quadratic'
    [label,~,~] = predict(Mdl,T2(:,1:(size(T2,2)-1)));
    Labels=[table2cell(T2(:,size(T2,2))),label];
    CM=confusionmat(Labels(:,1),Labels(:,2));
    %CMM=confusionmatStats(CM);
    Accuracy(dir)=sum(diag(CM))/sum(CM(:));%mean(CMM.accuracy); %sum(diag(CM))/sum(CM(:));
    end
    Acc=mean(Accuracy);
end
