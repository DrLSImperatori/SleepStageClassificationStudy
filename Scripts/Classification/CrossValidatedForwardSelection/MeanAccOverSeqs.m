function [MeanAcc, StdAcc]=MeanAccOverSeqs(testplot, output, sIndex)
%sum(testplot>prctile(testplot, 90))
% csum=cumsum(testplot, 'forward');
% prctchange=csum/csum(end);
% thrval=prctchange((prctchange>=0.5));
% testplot(1:find(prctchange==thrval(1)));
AccList=output(:,end);
% MeanAcc=mean(AccList(sIndex(1:find(prctchange==thrval(1)))));
% StdAcc=std(AccList(sIndex(1:find(prctchange==thrval(1)))),0,1);

idx=find(testplot>prctile(testplot, 90));
MeanAcc=mean(AccList(sIndex(1:idx(end))));
StdAcc=std(AccList(sIndex(1:idx(end))),0,1);

end