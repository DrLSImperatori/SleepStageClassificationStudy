function PSD=computePSD_2019(dataref)    
%     Average=nanmean(data,1);
%     dataref=(data-repmat(Average,[size(data,1),1]));
%     clear Average;

    PSD=[];
    fs=500;
    eplength=2*fs;
    fft=[];
    for ep=1:floor((size(dataref,2)/(eplength)))
        endep=ep*eplength;
         startep=endep-(eplength-1);

         for ch=1:size(dataref,1)
                [fft(ch,:,ep) freq]=pwelch(dataref(ch,startep:endep),[],[],eplength,fs);
         end; clear ch;
    end; clear ep;
    PSD=fft(:,1:find(freq==45),:); clear fft;
end
