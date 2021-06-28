#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 27 19:59:00 2020

@author: laura.imperatori
"""

import seaborn as sns
import pandas as pd
import numpy as np
import scipy.io as sio
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import os

Names=['relPOW', 'wPLI', 'wSMI', 'relPOW+wPLI', 'relPOW+wSMI', 'wPLI+wSMI', 'relPOW+wPLI+wSMI']*2000

filepath='/Users/laura.imperatori/Desktop/ClassificationFileCollectionForGitHub/Data/ClassificationAccuracies/Summarised/'
filepath_figures='/Users/laura.imperatori/Desktop/ClassificationFileCollectionForGitHub/Figures/BarCharts/'

os.mkdir(filepath_figures)



mat_fname = (filepath + 'ALL_All.mat')
mat_contents = sio.loadmat(mat_fname)
data=np.array(mat_contents['LDADist'])*100
data2=data.flatten('F')


NFeat=np.array(mat_contents['NFeatperModel'])

#data2 =np.array(mat_contents['Cut'])

# percentage label along axis

fig, ax = plt.subplots(figsize=(15,9))
pdarr=pd.DataFrame({'Tested Feature Sets': Names, 'Accuracy': data2}, index=range(1,14001))
barp = sns.boxplot(y= 'Accuracy', x = 'Tested Feature Sets', data = pdarr, whis=[2.5, 97.5], palette=("Blues_d"), showfliers = False, showmeans=True, meanprops={"marker":"o","markerfacecolor":"white", "markeredgecolor":"white", "markersize":8})



loc, labels = plt.xticks()
barp.set_xticklabels(labels, rotation=30)
barp.set_xlabel("Tested Feature Sets",fontsize=30)
barp.set_ylabel("Accuracy",fontsize=30)
barp.tick_params(labelsize=20)

barp.set_title("LDA Accuracy for Tested Feature Sets: \n  Wakefulness vs. N2- vs. N3- vs. REM-Sleep", fontdict={'fontsize': 30, 'fontweight': 'bold'})


fmt='%.0f%%'
yticks=mtick.FormatStrFormatter(fmt)
ax.yaxis.set_major_formatter(yticks)

pc=str('%')

# Add it to the plot
#pos = range(7)
#for tick,label in zip(pos,barp.get_xticklabels()):
#    barp.text(pos[tick], np.median(data,1)[tick] + 1, str(round(np.mean(data,1)[tick],2))+pc, horizontalalignment='center', color='w', weight='bold')
#    barp.text(pos[tick], np.median(data,1)[tick] - 1.5, 'NFeat=' + str(NFeat.flatten()[tick]), horizontalalignment='center', color='w', weight='bold')
#  
# Add it to the plot
pos = range(7)
for tick,label in zip(pos,barp.get_xticklabels()):
#    barp.text(pos[tick], np.mean(data,1)[tick] + 0.5, str(round(np.mean(data,1)[tick],2))+pc+' ('+ str(NFeat.flatten()[tick])+'F)', horizontalalignment='center', color='w', weight='bold', fontsize=14)
#    barp.text(pos[tick], np.mean(data,1)[tick] - 1.3, 'NFeat=' + str(NFeat.flatten()[tick]), horizontalalignment='center', color='w', weight='bold', fontsize=16)
    barp.text(pos[tick], np.mean(data,1)[tick] + 1, str(round(np.mean(data,1)[tick],2))+pc, horizontalalignment='center', color='w', weight='bold', fontsize=16)
    barp.text(pos[tick], np.mean(data,1)[tick] - 1.8, str(NFeat.flatten()[tick])+'F', horizontalalignment='center', color='w', weight='bold', fontsize=14)
   


plt.savefig(filepath_figures + 'LDAALL2000.png', bbox_inches='tight')
#

###############################################################################

mat_fname = (filepath + 'CUC_All.mat')
mat_contents = sio.loadmat(mat_fname)
data=np.array(mat_contents['LDADist'])*100
data2=data.flatten('F')


NFeat=np.array(mat_contents['NFeatperModel'])

#data2 =np.array(mat_contents['Cut'])

# percentage label along axis

fig, ax = plt.subplots(figsize=(15,9))
pdarr=pd.DataFrame({'Tested Feature Sets': Names, 'Accuracy': data2}, index=range(1,14001))
barp = sns.boxplot(y= 'Accuracy', x = 'Tested Feature Sets', data = pdarr, whis=[2.5, 97.5], palette=("Greens_d"), showfliers = False, showmeans=True, meanprops={"marker":"o","markerfacecolor":"white", "markeredgecolor":"white", "markersize":8})



loc, labels = plt.xticks()
barp.set_xticklabels(labels, rotation=30)
barp.set_xlabel("Tested Feature Sets",fontsize=30)
barp.set_ylabel("Accuracy",fontsize=30)
barp.tick_params(labelsize=20)

barp.set_title("LDA Accuracy for Tested Feature Sets: \n  Wakefulness and REM-Sleep vs. N2- and N3-Sleep", fontdict={'fontsize': 30, 'fontweight': 'bold'})


fmt='%.0f%%'
yticks=mtick.FormatStrFormatter(fmt)
ax.yaxis.set_major_formatter(yticks)

pc=str('%')

# Add it to the plot
#pos = range(7)
#for tick,label in zip(pos,barp.get_xticklabels()):
#    barp.text(pos[tick], np.median(data,1)[tick] + 1, str(round(np.mean(data,1)[tick],2))+pc, horizontalalignment='center', color='w', weight='bold')
#    barp.text(pos[tick], np.median(data,1)[tick] - 1.5, 'NFeat=' + str(NFeat.flatten()[tick]), horizontalalignment='center', color='w', weight='bold')
#  

# Add it to the plot
pos = range(7)
for tick,label in zip(pos,barp.get_xticklabels()):
#    barp.text(pos[tick], np.mean(data,1)[tick] + 0.5, str(round(np.mean(data,1)[tick],2))+pc+' ('+ str(NFeat.flatten()[tick])+'F)', horizontalalignment='center', color='w', weight='bold', fontsize=14)
#    barp.text(pos[tick], np.mean(data,1)[tick] - 1.3, 'NFeat=' + str(NFeat.flatten()[tick]), horizontalalignment='center', color='w', weight='bold', fontsize=16)
    barp.text(pos[tick], np.mean(data,1)[tick] + 0.8, str(round(np.mean(data,1)[tick],2))+pc, horizontalalignment='center', color='w', weight='bold', fontsize=16)
    barp.text(pos[tick], np.mean(data,1)[tick] - 1.3, str(NFeat.flatten()[tick])+'F', horizontalalignment='center', color='w', weight='bold', fontsize=14)
   

plt.savefig(filepath_figures + 'LDACUC2000.png', bbox_inches='tight')

###############################################################################

mat_fname = (filepath + 'WREM_All.mat')
mat_contents = sio.loadmat(mat_fname)
data=np.array(mat_contents['LDADist'])*100
data2=data.flatten('F')


NFeat=np.array(mat_contents['NFeatperModel'])

#data2 =np.array(mat_contents['Cut'])

# percentage label along axis

fig, ax = plt.subplots(figsize=(15,9))
pdarr=pd.DataFrame({'Tested Feature Sets': Names, 'Accuracy': data2}, index=range(1,14001))
barp = sns.boxplot(y= 'Accuracy', x = 'Tested Feature Sets', data = pdarr, whis=[2.5, 97.5], palette=("Reds_d"), showfliers = False, showmeans=True, meanprops={"marker":"o","markerfacecolor":"white", "markeredgecolor":"white", "markersize":8})



loc, labels = plt.xticks()
barp.set_xticklabels(labels, rotation=30)
barp.set_xlabel("Tested Feature Sets",fontsize=30)
barp.set_ylabel("Accuracy",fontsize=30)
barp.tick_params(labelsize=20)

barp.set_title("LDA Accuracy for Tested Feature Sets: \n  Wakefulness vs. REM-Sleep", fontdict={'fontsize': 30, 'fontweight': 'bold'})


fmt='%.0f%%'
yticks=mtick.FormatStrFormatter(fmt)
ax.yaxis.set_major_formatter(yticks)

pc=str('%')

# Add it to the plot
pos = range(7)
for tick,label in zip(pos,barp.get_xticklabels()):
#    barp.text(pos[tick], np.mean(data,1)[tick] + 0.5, str(round(np.mean(data,1)[tick],2))+pc+' ('+ str(NFeat.flatten()[tick])+'F)', horizontalalignment='center', color='w', weight='bold', fontsize=14)
#    barp.text(pos[tick], np.mean(data,1)[tick] - 1.3, 'NFeat=' + str(NFeat.flatten()[tick]), horizontalalignment='center', color='w', weight='bold', fontsize=16)
    barp.text(pos[tick], np.mean(data,1)[tick] + 0.7, str(round(np.mean(data,1)[tick],2))+pc, horizontalalignment='center', color='w', weight='bold', fontsize=16)
    barp.text(pos[tick], np.mean(data,1)[tick] - 1.3, str(NFeat.flatten()[tick])+'F', horizontalalignment='center', color='w', weight='bold', fontsize=14)
    

plt.savefig(filepath_figures + 'LDAWREM2000.png', bbox_inches='tight')