addpath(genpath('/Users/laura.imperatori/Desktop/ClassificationFileCollectionForGitHub/'))

addpath(genpath('/Users/laura.imperatori/Documents/MATLAB/cbrewer/'))

addpath('/Users/laura.imperatori/Documents/MATLAB/eeglab2019_1/')
eeglab

load('/Users/laura.imperatori/Desktop/ClassificationFileCollectionForGitHub/Data/Topoplot/EGI_256_chanlocs.mat')
load(['/Users/laura.imperatori/Desktop/ClassificationFileCollectionForGitHub/Data/Topoplot/TOPOPLOT_Values.mat'], 'Permutation')

%% Plot
close all; chanlocs=EEG.chanlocs;
FreqList={'Delta', 'Theta', 'Alpha', 'Sigma', 'Beta', 'Gamma', 'Broadband'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Type={'Power' ,'wPLI', 'wSMI'}
SList={'N2' 'N3' 'REM'}
Type2={'-relPOW', '-wPLI', '-wSMI'}

for conn=1:3
fullfig;
count=0;
for test=1:3
set(0, 'defaultTextInterpreter', 'none'); %set(gca, 'FontName', 'Arial'); set(gca, 'DefaultAxesFontSize')
for freq=1:6
    count=count+1;
    subplot(3,6,count)
    vals=Permutation(conn,test,freq, 1, :);
    psig=find(Permutation(conn,test,freq, 2, :)==1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    topoplot(vals, chanlocs, 'emarker2', {psig','o','w', 2, 1}, 'conv','on', 'maplimits', [-5 5], 'whitebk', 'on', 'plotrad', 0.6); 
    cmap = flipud(cbrewer('div','RdYlBu',256, 'pchip')); colormap(cmap);
    title({[FreqList{freq} Type2{conn}]}, 'FontName', 'NewCenturySchoolBook', 'FontWeight', 'bold', 'FontSize', 24, 'VerticalAlignment', 'baseline')
end
        
end

hp4 = get(subplot(3,6,18),'Position')
colorbar('Position',     [0.933333333333334 0.137137137137137 0.0184523809523806 0.782782782782783], 'FontSize',24);

export_fig(['/Users/laura.imperatori/Desktop/ClassificationFileCollectionForGitHub/Figures/TOPOPLOT_Diff_' Type{conn}], ...
['-r' num2str(150)], '-a2', '-nocrop', '-transparent'); 
end

