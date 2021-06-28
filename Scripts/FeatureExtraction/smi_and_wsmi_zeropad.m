function [sym, count, smi, wsmi] = smi_and_wsmi_zeropad(data, cfg)
    
    chan_sel  = cfg.chan_sel;
    data_sel  = cfg.data_sel;
    taus   = cfg.taus;
    kernel = cfg.kernel;
    lowfreq = cfg.lowfreq;
    ntrials=size(data,3);
    over_trials = cfg.over_trials;
    fs=cfg.sf;
%%% autocomplete the weights matrix if not provided    
    if ~isfield(cfg, 'weights')
        nsymbols = factorial(kernel);
        wts = 1- (eye(nsymbols) | fliplr(eye(nsymbols)));
    else
        wts = cfg.weights;
    end
    paddat=zeros([length(chan_sel), length(data_sel)+(fs*2), ntrials]);
    for tr=1:ntrials
    paddat(:,:,tr)=ft_preproc_padding(data(:,:,tr), 'mirror', fs);
    end
    %%% filtering and processing
    for tau=1:size(taus,2)
%         tic
        filter_freq = cfg.sf/cfg.kernel/taus(tau);
%         disp(['Filtering @ ' num2str(filter_freq) ' Hz'])
        fdata=zeros(size(data));
        if lowfreq==0.5
                for trial=1:ntrials
                    tmp_data = ft_preproc_lowpassfilter(squeeze(paddat(:,:,trial)),cfg.sf,filter_freq );
                    fdata(:,:,trial)=ft_preproc_padding(tmp_data, 'remove', fs);
                end
        else
                for trial=1:ntrials
                    tmp_data = ft_preproc_bandpassfilter(squeeze(paddat(:,:,trial)),cfg.sf,[lowfreq, filter_freq]);
                    fdata(:,:,trial)=ft_preproc_padding(tmp_data, 'remove', fs);
                end
        end
%         disp(['Filtering done'])
        [sym{tau}, count{tau}, smi{tau}, wsmi{tau}] = smi_and_wsmi_mex(fdata(chan_sel, data_sel, :), taus(tau), kernel, wts, over_trials);
%         toc
    end

end

