function H=mirror_matrix_along_diagonal(A)
H=A+A'-diag([diag(A)]);
%H(H==0)=NaN;
end