function channmatrix=transforming_sequence_into_matrix(wPLI, channum)
channmatrix=zeros(channum, channum);
cpdidx=0;
for i=1:(channum-1)
    for j=2:(channum)
        if i<j
           cpdidx=cpdidx+1;
           channmatrix(i,j)=wPLI(cpdidx);
           end
        end
end
%H=mirror_matrix_along_diagonal(channmatrix);
end