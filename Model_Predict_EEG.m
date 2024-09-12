function [val_Pai , status] = Model_Predict_EEG(signal,threshold_EEG)
    global EEG_Model 
    global Sampling_Frequency

%     [C, H, gs] = calc_lz_complexity(signal,'exhaustive',1);
signal = signal';
    Complexity = 1;
    cfg                     = [];
    cfg.Fs                  = Sampling_Frequency;
    cfg.phase_freqs         = [2:2:30];
    cfg.amp_freqs           = [50:2:100];
    cfg.method              = 'plv';
    cfg.filt_order          = 2;
    %     cfg.surr_method         = 'swap_blocks';
    cfg.surr_N              = 200;
    cfg.amp_bandw_method    = 'number';
    cfg.amp_bandw           = 40;

    [MI_raw]                = PACmeg(cfg,signal);
    MI_raw_matrix           = MI_raw;

    [SIG1,sigDEN] = func_denoisem(signal);
    [power_line,f]=pwelch(sigDEN,4000,256,1000,Sampling_Frequency);
    power_line=10*log(power_line);

    chan1_loc=find(f<=4&f>=2);
    chan2_loc=find(f<=8&f>=4);
    chan3_loc=find(f<=16&f>=8);
    chan4_loc=find(f<=30&f>=16);
    chan5_loc=find(f<=50&f>=30);
    chan6_loc=find(f<=100&f>=50);

    power_delta = mean(power_line(chan1_loc));

    power_theta = mean(power_line(chan2_loc));

    power_alpha = mean(power_line(chan3_loc));

    power_beta = mean(power_line(chan4_loc));

    power_low_gamma = mean(power_line(chan5_loc));

    power_high_gamma = mean(power_line(chan6_loc));

    Power_raw_matrix = [power_delta;power_theta;power_alpha;power_beta;power_low_gamma;power_high_gamma];

    for j = 1:size(MI_raw_matrix,1)
        MI_matrix(j,1)=mean(MI_raw_matrix(j,:));
    end

    feature_matrix=[MI_matrix;Power_raw_matrix;Complexity];

    val_Pai = sim(EEG_Model,feature_matrix);
    
    if val_Pai >= threshold_EEG
        status = 1;
    else 
        status = 0;
    end
end