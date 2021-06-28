function wPLImatrix=compute_wPLI_LI(EEG_data,chanlocs, tr, freqrange, srate, trialsep)

labels=1:trialsep*size(EEG_data,2):(trialsep*size(EEG_data,2)*tr);
data.sampleinfo=[labels; labels+(size(EEG_data,2)-1)]';

for i=1:1:tr  
    data.time{i}=(1/srate:1/srate:((1/srate)*size(EEG_data,2)));
    data.trial{i}=EEG_data(:,:,i);
end
    data.label= chanlocs';    % cell-array containing strings, Nchan*1
    
    cfg1           = [];
    cfg1.method    = 'mtmfft';
    cfg1.output    = 'powandcsd';
    cfg1.taper=      'hanning';
    cfg1.foilim = freqrange; 
    cfg1.keeptrials = 'yes';
        
    cfg1.pad ='nextpow2';
    freq          = ft_freqanalysis(cfg1, data);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   [wpli, ~, ~] = ft_connectivity_wpli(freq.crsspctrm, 'dojack', 0,'feedback', 'none', 'debiased', 0);
   wPLI=mean(abs(wpli),2); %taking the mean across frequency bins of interest
   wPLImatrix=transforming_sequence_into_matrix(abs(wPLI),length(chanlocs)); % If you want the adjacency matrix instead of the list.
   
end
