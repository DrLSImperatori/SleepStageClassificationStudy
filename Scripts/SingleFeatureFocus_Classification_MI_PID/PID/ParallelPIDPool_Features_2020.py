#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Feb 27 11:44:02 2019

@author: laurai
"""
import numpy as np
from multiprocessing import Process, Value, Array, Pool 
import dit
from dit.pid import PID_CCS
import scipy as sp
import scipy.io

def ComputePID(ri):
    pid = np.zeros((4,))
    P = allP[:,:,:,ri]
    d=dit.Distribution(*zip(*np.ndenumerate(P)))
    x = PID_CCS(d, [[0],[1]], [2])
    pid[0] = x.get_partial(((0,), (1,)))
    pid[1] = x.get_partial(((0,),))
    pid[2] = x.get_partial(((1,),))
    pid[3] = x.get_partial(((0,1),)) 
    return pid

Comparison=['WN2N3REM', 'CUC', 'WREM']

if __name__ == '__main__':
    for comp in  [0]:
        print(Comparison[comp])
        for s in [23]:
            for boot in range(2000):
                dat = sp.io.loadmat('/home/laurai/matlab/Features/PVals2020/PVALs_' + Comparison[comp] + '_210120_Subj'  + str(s+1) + '_'  + str(boot+1) + '.mat')               
    
                allP = np.squeeze(dat['PColl'])
                Nrep = allP.shape[-1]
                filename=str(s+1)+'_'+ str(boot+1)
        
                p = Pool(16);
                res = p.map(ComputePID, range(Nrep))
                allpid = np.stack( res, axis=0 )
                p.close()
                dat2 = {'PID': allpid}
                sp.io.savemat('/home/laurai/matlab/Features/PVals2020/PID_' + Comparison[comp] + '_210120_Subj'  + filename + '.mat', dat2)            

                print( 'Subject' + str(s+1) + ' BootStrap'  + str(boot+1) + ' : Done')    
                
