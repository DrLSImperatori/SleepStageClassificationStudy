function Acc=obtainAcc_84(Vals, Labs)
    TTest=array2table(Vals);
    TClass=table(Labs);   
    TTest=[TTest, TClass];
    
    idxTrn=1:2*size(TTest,1)/3;
    idxTest=size(TTest,1)*2/3+1:size(TTest,1);
    
    T1 = TTest(idxTrn,:);
    T2 = TTest(idxTest,:);
    Mdl = fitcdiscr(T1(:,1:(size(T1,2)-1)),T1(:,size(T1,2)), 'DiscrimType', 'linear'); %, 'DiscrimType', 'quadratic'
    [label,~,~] = predict(Mdl,T2(:,1:(size(T2,2)-1)));
    Labels=[table2cell(T2(:,size(T2,2))),label];
    CM=confusionmat(Labels(:,1),Labels(:,2));
    %CMM=confusionmatStats(CM);
    Acc=sum(diag(CM))/sum(CM(:));%mean(CMM.accuracy); %sum(diag(CM))/sum(CM(:))
end
