clear all; close all; clc;
addpath('/Users/laura.imperatori/Desktop/PhD/Matlab/export_fig/')
addpath('/Users/laura.imperatori/Desktop/PhD/Matlab/raacampbell-shadedErrorBar-2200e5a/')
set(0,'defaultAxesFontName', 'Verdana')
set(0,'defaultTextFontName', 'Verdana')
Comp={'All', 'CUC', 'WREM'}
B=[25,50,50]
Desc={'Wakefulness vs. N2- vs. N3- vs. REM-Sleep'; 'Wakefulness and REM-Sleep vs. N2- and N3-Sleep'; 'Wakefulness vs. REM-Sleep'}
ColorTest={'#367bac', '#369050', '#c93029'}
MedColors={'#800080', '#663333', '#FFA500'}


filepath='/Users/laura.imperatori/Desktop/ClassificationFileCollectionForGitHub/';

for test=1:3   

load([filepath 'Data/ClassificationAccuracies/' Comp{test} '_BStrap_OneIteration_7.mat'], 'IncFeat', 'LDAAccuracy', 'CICount', 'Dist')

NFeat=18;

% test=NaN(size(Dist));
% 
% for feat=1:18
% for nboot=1:size(Dist,2)
%     temp=sum(squeeze(PermAllBStrap(feat, nboot,:))>=Dist(feat,nboot))./size(PermAllBStrap,3);
%     if temp==0
%         test(feat, nboot)=1./size(PermAllBStrap,3);
%     else
%         test(feat, nboot)=temp;
% 	end
% end
% end
% 
% pagg=zeros(18,1);
% 
% for feat=1:18
% 	pagg(feat)=pfast(squeeze(test(feat, :)).');
% end
% 
% PermAllBStrap=median(PermAllBStrap, 3);
% PermAllBStrap=prctile(PermAllBStrap, 97.5, 3);
% PermAllBStrap=reshape(PermAllBStrap, [size(PermAllBStrap,1), size(PermAllBStrap,2)*size(PermAllBStrap,3)]);

 
%  figure;
%  for count=1:18
%      [h,p(count)]=kstest2(Dist(count, :), PermAllBStrap(count, :));
%      [psign(count)]=signrank(Dist(count, :), PermAllBStrap(count, :));
%      subplot(3,6,count)
%      histogram(Dist(count, :), 100)
%      hold on
%      histogram(PermAllBStrap(count, :), 100)     
%      hold off
%  end 

alpha=0.5
fig = figure('units','centimeters','Position',[0 0 80 20])%fullfig;
left_color = hex2rgb(ColorTest{test}); %[0 0 0];
right_color = [0 0 0]+alpha-0.1; %[0 .5 .5];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

axs = gca;
axs.FontSize = 20;

%yyaxis left

% plot(100*LDAAccuracy, 'g', 'LineWidth', 5)
% hold on
% 
% str = '#90ee90';
% color = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;
% 
% plot(100*CICount(:,1), ':', 'Color', color, 'LineWidth', 5)
% hold on
% str = '#006400';
% color = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;

% plot(100*CICount(:,2), ':', 'Color', color, 'LineWidth', 5)
% hold on
errbar=100*[CICount(:,2)-LDAAccuracy.', LDAAccuracy.'-CICount(:,1)];
s=shadedErrorBar(1:18, 100*LDAAccuracy, errbar, 'lineprops', {'color', ColorTest{test}},'transparent',false,'patchSaturation',0.075)
set(s.edge,'LineWidth',5,'LineStyle',':')
s.mainLine.LineWidth = 5;
% s.patch.FaceColor = [0.5,0.25,0.25];
% plot(100*mean(PermAllBStrap,2), 'r-', 'LineWidth', 5)
% 
% hold on
% 
% str = '#ffcccb';
% color = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;
% plot(100*prctile(PermAllBStrap, 2.5,2), ':', 'Color', color, 'LineWidth', 5)
% 
% hold on
% 
% str = '#E9967A';
% color = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;
% plot(100*prctile(PermAllBStrap, 97.5,2), ':', 'LineWidth', 5, 'Color', color)

% 

hold on

plot(1:NFeat, 100*median(Dist,2), ':', 'LineWidth', 5, 'Color', MedColors{test} ) %[224,224,224]/256
% 

axs.YAxis(1).TickLabelFormat = '%g%%';

ylabel('Accuracy', 'color', left_color) %- Absolute Value

set(axs, 'YLim', [B(test), 100])
% yyaxis right
% axs.YAxis(2).TickLabelFormat = '%g%%';     


% hold on
% 
% 
% percent_change=(diff(LDAAccuracy)./LDAAccuracy(1:end-1));
% plot(2:NFeat,100*percent_change, '-', 'LineWidth', 5, 'Color', [0,0,0]+alpha-0.1)
% 
% pc_ci1=(diff(CICount(:,1))./CICount(1:end-1,1));
% pc_ci2=(diff(CICount(:,2))./CICount(1:end-1,2));
% 
% errbar=100*[pc_ci2-percent_change.', percent_change.'-pc_ci1];
% s=shadedErrorBar(2:18, 100*percent_change, errbar, 'lineprops', {'color', ColorTest{test}},'transparent',false,'patchSaturation',0.075)
% set(s.edge,'LineWidth',5,'LineStyle',':')
% s.mainLine.LineWidth = 5;

% hold on 
% percent_change=(diff(CICount(:,1))./CICount(1:end-1,1));
% plot(100*2:NFeat,percent_change, 'LineWidth', 5, 'LineStyle', '-')


% hold on
% varperm=mean(PermAllBStrap,2).';
% percent_change2=zeros(NFeat-1,1);
% for i=2:NFeat
%     percent_change2(i-1)=((varperm(i)-LDAAccuracy(i-1))/(LDAAccuracy(i-1)));
% end
% plot(2:NFeat,100*percent_change2, 'LineWidth', 5, 'LineStyle', ':')
% 
% hold on
% varperm=prctile(PermAllBStrap,97.5, 2).';
% percent_change2=zeros(NFeat-1,1);
% for i=2:NFeat
%     percent_change2(i-1)=((varperm(i)-LDAAccuracy(i-1))/(LDAAccuracy(i-1)));
% end
% plot(100*2:NFeat,percent_change2, 'LineWidth', 5, 'LineStyle', ':')


% ylabel('Accuracy - Relative Difference', 'color', right_color)


% vec=(p<0.05/18);
% vec=find((vec)~=1);
% idx=(vec(1))-1;
% idx=find(percent_change>0);
% idx=idx(end)+1;

idx=find(diff(mean(Dist,2))<=0,1);%001 Struct1.LDAAccuracy
idx(idx==0) = 1;

idxmed=find(diff(median(Dist,2))<=0,1);
idx=min([idx, idxmed]);


plot([idx, idx],get(axs,'YLim'), 'LineWidth', 5,'LineStyle', '-.', 'Color', [0 0 0]+alpha)


% leg=legend('True Accuracy (Mean across BStraps)', '2.5% True Accuracy (BStrap Dist.)', '97.5% True Accuracy (BStrap Dist.)', ...
%     'Null Accuracy (Mean across BStraps)', '2.5% Null Accuracy (BStrap Dist.)', '97.5% Null Accuracy (BStrap Dist.)', ...
%     'True Relative Difference', 'Null Relative Difference',...
%     'Cut-Off')

leg=legend('Mean Accuracy with 95% CIs', ...
    'Median Accuracy', ...
    'Cut-Off', 'Location', 'SouthEast') %'Relative Difference', ...

% if test==3    
%     leg=legend('Mean Accuracy with 95% CIs', ...
%         'Relative Difference', ...
%         'Cut-Off', 'Location', 'SouthWest')
% end
% set(leg,...
%     'Position',[0.585416666666667 0.374374374374374 0.296428571428571 0.296296296296296]);
%  '2.5% True Accuracy (BStrap Dist.)', '97.5% True Accuracy (BStrap Dist.)',

Frequencies={'Delta-POW' 'Theta-POW' 'Alpha-POW' 'Sigma-POW' 'Beta-POW' 'Gamma-POW' 'Delta-wPLI' 'Theta-wPLI' 'Alpha-wPLI' 'Sigma-wPLI' 'Beta-wPLI' 'Gamma-wPLI' 'Delta-wSMI' 'Theta-wSMI' 'Alpha-wSMI' 'Sigma-wSMI' 'Beta-wSMI' 'Gamma-wSMI'}

set(gca,'xtick', 1:NFeat), set(gca, 'xticklabel', ({Frequencies{IncFeat}}))
set(gca, 'xticklabelrotation', 20)
set(gca, 'Xlim', [1 18])
% idx=0;
% plot(get(axs,'XLim'), [idx, idx],'LineWidth', 5,'LineStyle', '-.', 'Color', [0 0 0]+alpha,'HandleVisibility','off')
% [255 153 153]/255

title({['Classification Accuracy for ' Desc{test} ':']; 'Forward Selection'}, 'fontsize', 28)
export_fig([filepath 'Figures/BestModelSelSeq/' Comp{test} '_One_Iteration'],...
     ['-r' num2str(150)], '-a2', '-nocrop', '-transparent');
 

end