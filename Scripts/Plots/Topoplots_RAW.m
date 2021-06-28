clear all; close all; clc;

addpath('/home/laura.imperatori/matlab/Toolboxes/cbrewer/')
addpath(genpath('/home/laura.imperatori/matlab/BBCB_Project/BBCB_Summary/Functions/'))
addpath(genpath('/home/laura.imperatori/matlab/BBCB_Project/BBCB/'));

addpath('/Users/laura.imperatori/Documents/MATLAB/eeglab2019_1/')
eeglab

load('/Users/laura.imperatori/Desktop/ClassificationFileCollectionForGitHub/Data/BStrap_Joint.mat', 'AllPOWER257', ...
    'AllMedwPLI257', 'AllMedwSMI257', 'AllwPLI257', 'AllwSMI257')

%% Topoplots
POW=squeeze(mean(mean(AllPOWER257,2),1));

wPLI=squeeze(mean(mean(AllwPLI257, 2),1));

wSMI=squeeze(mean(mean(AllwSMI257, 2),1));


Stages={'Wakefulness'  'N2' 'N3' 'REM'}
Freqs={'Delta-', 'Theta-', 'Alpha-', 'Sigma-', 'Beta-', 'Gamma-'}


load('/Users/laura.imperatori/Desktop/ClassificationFileCollectionForGitHub/Data/Topoplot/EGI_256_chanlocs.mat');

% INPUT:
%   - ctype: type of color table 'seq' (sequential), 'div' (diverging), 'qual' (qualitative)
%   - cname: name of colortable. It changes depending on ctype.
%   - ncol:  number of color in the table. It changes according to ctype and
%            cname
%   - interp_method: interpolation method (see interp1.m). Default is "cubic" )

count=0;
fullfig;
for stage=[4,2,3,1]
    for freq=1:6
        mat=(POW(freq,:,:));
        minmat=min(mat(:));
        maxmat=max(mat(:));
        count=count+1;
        subplot(4,6,count)
        topoplot(squeeze(POW(freq,:,stage)), EEG.chanlocs, 'maplimits', [minmat maxmat], 'plotrad', 0.6);
        cmap = (cbrewer('seq','YlOrRd',256, 'pchip')); colormap(cmap);
        title([Freqs(freq) ' relPower'], 'FontSize', 14); colorbar;
    end
end
export_fig(['/Users/laura.imperatori/Desktop/ClassificationFileCollectionForGitHub/Figures/Topoplots/TOPOPLOT_POW'], ...
['-r' num2str(150)], '-a2', '-nocrop', '-transparent'); 


count=0;
fullfig;
for stage=[4,2,3,1]
    for freq=1:6
        mat=(wPLI(freq,:,1,:));
        minmat=min(mat(:));
        maxmat=max(mat(:));
        count=count+1;
        subplot(4,6,count)
        topoplot(squeeze(wPLI(freq,:,1,stage)), EEG.chanlocs, 'maplimits', [minmat maxmat], 'plotrad', 0.6);
        cmap = (cbrewer('seq','YlOrRd',256, 'pchip')); colormap(cmap);
        title([Freqs(freq) ' wPLI'], 'FontSize', 14); colorbar;
    end
end
export_fig(['/Users/laura.imperatori/Desktop/ClassificationFileCollectionForGitHub/Figures/Topoplots/TOPOPLOT_wPLI'], ...
['-r' num2str(150)], '-a2', '-nocrop', '-transparent'); 


count=0;
fullfig;
for stage=[4,2,3,1]
    for freq=1:6
        mat=(wSMI(freq,:,1,:));
        minmat=min(mat(:));
        maxmat=max(mat(:));
        count=count+1;
        subplot(4,6,count)
        topoplot(squeeze(wSMI(freq,:,1,stage)), EEG.chanlocs, 'maplimits', [minmat maxmat], 'plotrad', 0.6);
        cmap = (cbrewer('seq','YlOrRd',256, 'pchip')); colormap(cmap);
        title([Freqs(freq) ' wSMI'], 'FontSize', 14); colorbar;
    end
end
export_fig(['/Users/laura.imperatori/Desktop/ClassificationFileCollectionForGitHub/Figures/Topoplots/TOPOPLOT_wSMI'], ...
['-r' num2str(150)], '-a2', '-nocrop', '-transparent'); 