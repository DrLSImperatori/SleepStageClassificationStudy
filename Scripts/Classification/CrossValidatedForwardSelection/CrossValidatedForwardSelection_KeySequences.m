close all
% addpath(genpath('D:\MATLAB\fullfig\'))

filepath='/Users/laura.imperatori/Desktop/ClassificationFileCollectionForGitHub/';

TestList={'POW', 'wPLI', 'wSMI', 'POW+wPLI', 'POW+wSMI', 'wPLI+wSMI', 'POW+wPLI+wSMI'};
% Frequencies={'Delta', 'Theta', 'Alpha', 'Sigma', 'Beta', 'Gamma','Delta1', 'Theta1', 'Alpha1', 'Sigma1', 'Beta1', 'Gamma1','Delta2', 'Theta2', 'Alpha2', 'Sigma2', 'Beta2', 'Gamma2' }
String={'Top 20: Dataset 1 to Dataset 2' , 'Top 20: Dataset 2 to Dataset 1', 'Top 20: Mean Occurrence'}
Comparison={'ALL', 'CUC', 'WREM'}
Nboot=2000;

% fullfig;
ValColl=zeros(3, 20);
LabColl=cell(3,20);
FeatColl=cell(3,20)
for cond=1:3
for comp=7
    if comp<=3
      Frequencies={'Delta', 'Theta', 'Alpha', 'Sigma', 'Beta', 'Gamma','Delta1', 'Theta1', 'Alpha1', 'Sigma1', 'Beta1', 'Gamma1','Delta2', 'Theta2', 'Alpha2', 'Sigma2', 'Beta2', 'Gamma2' }
    elseif comp==4
      Frequencies={'DeltaPow', 'ThetaPow', 'AlphaPow', 'SigmaPow', 'BetaPow', 'GammaPow','DeltawPLI', 'ThetawPLI', 'AlphawPLI', 'SigmawPLI', 'BetawPLI', 'GammawPLI' }
    elseif comp==5
      Frequencies={'DeltaPow', 'ThetaPow', 'AlphaPow', 'SigmaPow', 'BetaPow', 'GammaPow','DeltawSMI', 'ThetawSMI', 'AlphawSMI', 'SigmawSMI', 'BetawSMI', 'GammawSMI'}
    elseif comp==6
      Frequencies={'DeltawPLI', 'ThetawPLI', 'AlphawPLI', 'SigmawPLI', 'BetawPLI', 'GammawPLI','DeltawSMI', 'ThetawSMI', 'AlphawSMI', 'SigmawSMI', 'BetawSMI', 'GammawSMI'}
    elseif comp==7
      Frequencies={'DeltaPow', 'ThetaPow', 'AlphaPow', 'SigmaPow', 'BetaPow', 'GammaPow', 'DeltawPLI', 'ThetawPLI', 'AlphawPLI', 'SigmawPLI', 'BetawPLI', 'GammawPLI','DeltawSMI', 'ThetawSMI', 'AlphawSMI', 'SigmawSMI', 'BetawSMI', 'GammawSMI'}
    end
        
    for dir=1:3
        
        
        if dir<3
%            subplot(1,3,dir) 
load([filepath '/Data/CrossValidatedForwardSelection/' Comparison{cond} '_' TestList{comp} '_DIR' num2str(dir) '.mat'], 'SEQ', 'AccDist')

SEQ=sort(SEQ,2);
SEQ(isnan(SEQ))=0;
[Mu,ia,ic] = unique(SEQ, 'rows', 'sorted'); %stable % Unique Values By Row, Retaining Original Order
h = accumarray(ic, 1); % Count Occurrences
maph = h(ic); % Map Occurrences To ?ic? Values

Result = [SEQ, maph];
Counter=unique(Result, 'rows', 'sorted');

output = [Mu, accumarray(ic, AccDist,[],@mean)];

if dir==1
    output1=output; Counter1=Counter;
elseif dir==2
    output2=output; Counter2=Counter;
end
        else
            subplot(1,3,cond)
    bothacc=cat(1,output1,output2);
    BothAcc=bothacc(:, end);
    bothacc(:,end)=[];

    [Mu,ia,ic] = unique(bothacc, 'rows', 'sorted'); %stable % Unique Values By Row, Retaining Original Order
    output = [Mu, accumarray(ic, BothAcc,[],@mean)];
    
    bothocc=cat(1,Counter1,Counter2);
    BothOcc=bothocc(:, end);
    bothocc(:,end)=[];

    [Mu,ia,ic] = unique(bothocc, 'rows', 'sorted'); %stable % Unique Values By Row, Retaining Original Order
    Counter = [Mu, accumarray(ic, BothOcc,[],@mean)];    



outchar={}
outcharA={}
outcharB={}

for r=1:size(output,1)
    row=output(r,:);
    row(row==0) = [];
    %outchar{r}=mat2str(row,2);
    outchar{r}=strcat(strcat(Frequencies{row(1:end-1)}), ' - Acc:', num2str(round(row(end),2)));
    outcharA{r}=strcat(Frequencies{row(1:end-1)});
    outcharB{r}=strcat('Acc:', num2str(round(row(end),2)));
end

test=Counter(:,end)
[sN, sIndex] = sort(test, 'descend')

test=test(sIndex);
outchar=outchar(sIndex);outcharA=outcharA(sIndex);
outcharB=outcharB(sIndex);

log=zeros(size(Counter,1),1);
[~, idx]=max(test);
log(idx)=1;

testplot=test %(test>1);
% % testplot(end+1)=Nboot-length(testplot(end))
% outchar=outchar(1:length(testplot));
% % outchar{end+1}='Others'
% log=log(1:length(testplot))
% if dir<3
% p=pie(testplot,log)
% colormap(flipud(parula))
% pText = findobj(p,'Type','text');
% percentValues = get(pText,'String'); 
% combinedtxt = strcat(outchar.',' - Occ:',percentValues); 
% 
% for r=1:size(testplot,1)
%     if r<=size(testplot,1)-round(19*size(testplot,1)/20)
%         pText(r).String = combinedtxt(r);
%     else
%         pText(r).String = '';
%     end
% end
% else
maxval=max(testplot(1:20)/Nboot);
b=bar(1:20,testplot(1:20)/Nboot), set(gca, 'xtick', 1:20, 'xlim', [0,21],  'ylim', [0,1.5*maxval],  'xticklabels', (outcharA(1:20)), 'XTickLabelRotation', 90, 'fontsize', 8, 'fontname', 'Arial')

% Convert y-axis values to percentage values by multiplication
a=[cellstr(num2str(get(gca,'ytick')'*100))];
% Create a vector of '%' signs
pct = char(ones(size(a,1),1)*'%');
% Append the '%' signs after the percentage values
new_yticks = [char(a),pct];
% 'Reflect the changes on the plot
set(gca,'yticklabel',new_yticks, 'fontname', 'Arial')
axis square
text(1:20,zeros(20,1)+testplot(1:20)/Nboot+0.1*maxval,outcharB(1:20),'vert','middle','horiz','left', 'fontname', 'Arial');
H=findobj(gca,'Type','text');
set(H,'Rotation',90); 
box off
title([Comparison{cond}, ' - ',TestList{comp}], 'FontSize', 16', 'FontWeight', 'Bold')
% 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;
% end
% title({String{dir}, ''}, 'fontsize', 16, 'fontname', 'Arial')
        end

    end
    
    ValColl(cond, :)=testplot(1:20);
    LabColl(cond,:)=outcharB(1:20).';
    FeatColl(cond, :)=outcharA(1:20).';
 % - Build title axes and title.
% axes( 'Position', [0, 0.95, 1, 0.05] ) ;
% set( gca, 'Color', 'None', 'XColor', 'White', 'YColor', 'White' ) ;
% set(gca, 'title', [Comparison{cond}, ' - ',TestList{comp}], 'FontSize', 16', 'FontWeight', 'Bold', ...
% 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;
% addpath(genpath('D:\MATLAB\cbrewer\'))

 
end
end


save([filepath 'Data/84_All_Plot.mat'], 'ValColl', 'LabColl', 'FeatColl')
