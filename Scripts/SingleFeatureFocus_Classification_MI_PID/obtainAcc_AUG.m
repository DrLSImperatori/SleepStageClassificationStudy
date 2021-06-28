function Acc=obtainAcc_AUG(ValsA, ValsB, Labs, seg)
    Vals=ValsA;
    TTestA=array2table(Vals);
    Vals=ValsB;
    TTestB=array2table(Vals);
    TClass=table(Labs);   
    Accuracy=NaN(2,1);
    for dir=1:2
        if dir==1           
            T1 = TTestA;
            T2 = TTestB(1:seg:end, :);
        elseif dir==2
            T1 = TTestB;
            T2 = TTestA(1:seg:end, :);
        end
           T1=[T1, TClass];
           T2=[T2, TClass(1:seg:end, :)];
    Mdl = fitcdiscr(T1(:,1:(size(T1,2)-1)),T1(:,size(T1,2)), 'DiscrimType', 'linear'); %, 'DiscrimType', 'quadratic'
    [label,~,~] = predict(Mdl,T2(:,1:(size(T2,2)-1)));
    Labels=[table2cell(T2(:,size(T2,2))),label];
    CM=confusionmat(Labels(:,1),Labels(:,2));
    %CMM=confusionmatStats(CM);
    Accuracy(dir)=sum(diag(CM))/sum(CM(:));%mean(CMM.accuracy); %sum(diag(CM))/sum(CM(:));
    end
    Acc=mean(Accuracy);
end
