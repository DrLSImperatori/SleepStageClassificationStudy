function Acc=obtainAcc(Vals, Labs)
    TTest=array2table(Vals);
    TClass=table(Labs);   
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
    if length(unique(Labs))==2
        Mdl = fitcsvm(T1(:,1:(size(T1,2)-1)),T1(:,size(T1,2))); %, 'DiscrimType', 'quadratic'
    else 
        Mdl = fitcecoc(T1(:,1:(size(T1,2)-1)),T1(:,size(T1,2))); %, 'DiscrimType', 'quadratic'
    end
    [label,~,~] = predict(Mdl,T2(:,1:(size(T2,2)-1)));
    Labels=[table2cell(T2(:,size(T2,2))),label];
    CM=confusionmat(Labels(:,1),Labels(:,2));
    %CMM=confusionmatStats(CM);
    Accuracy(dir)=sum(diag(CM))/sum(CM(:));%mean(CMM.accuracy); %sum(diag(CM))/sum(CM(:));
    end
    Acc=mean(Accuracy);
end
