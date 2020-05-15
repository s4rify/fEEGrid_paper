function [] = sab_04_asr(toolbox)
    %
    % Developed in Matlab 9.3.0.948333 (R2017b) Update 9 on PCWIN64
    % at University of Oldenburg.
    % Sarah Blum (sarah.blum@uol.de), 2019-05-09 15:09
    %-------------------------------------------------------------------------
    PATHIN = 'data/filtered/';
    PATHIN_CALIB = 'data/calibration_data/';
    SESSIONS = {'Morning/', 'Evening/'};
    PATHOUT = 'data/asr_cleaned/';
    params = {
        'flatline', 5
        'hp' , [0.25 0.85]
        'channel', 0.9
        'noisy', 4 % std dev for removing chnnels
        'burst', 3 % std dev for removing samples
        'c_window', 0.5 % how much dirt can be left in the final output
        ... processing values from here on ...
        'cutoff', 2
        'p_window', 0.3
        'stepsize', 16
        'maxdims', 1
        };
     
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
    
    % use Riemannian ASR?
    addpath(toolbox, '-begin');
    
    for sess = 1 : length(SESSIONS)
        flist = dir([PATHIN, SESSIONS{sess},  '*.set']);
        flist_c = dir([PATHIN_CALIB, SESSIONS{sess},  '*.set']);
        
        for s = 1 : length(flist)
            % load subject data, filtered only
            EEG = pop_loadset('filename',flist(s).name,'filepath', [PATHIN, SESSIONS{sess}]);
            % load matching calib data
            EEG_c = pop_loadset('filename',flist_c(s).name,'filepath', [PATHIN_CALIB, SESSIONS{sess}]);
            EEG_c = eeg_epoch2continuous(EEG_c);
            EEG = eeg_checkset(EEG);
            EEG_c = eeg_checkset(EEG_c);
            
            % store channel info for interpolation
            originalEEG = EEG.chanlocs;
            
            %% clean calib data
            flatline = params{1,2};
            hp = params{2,2};
            channel = params{3,2};
            noisy = params{4,2};
            burst = params{5,2};
            window = params{6,2};
            EEG_c = clean_rawdata(EEG_c, flatline, hp, channel, noisy, burst, window);
            EEG_c = pop_interp(EEG_c, EEG.chanlocs, 'spherical');
            
            warning off;
            tstart = tic;
            cutoff = params{7,2};
            window = params{8,2};
            stepsize = params{9,2};
            maxdims = params{10,2};
            
            % asr processing
            %EEG = clean_flatlines(EEG, flatline);
            %EEG = clean_drifts(EEG,hp);
            %EEG = pop_interp(EEG, originalEEG, 'spherical');
            EEG = clean_asr(EEG,cutoff,window,stepsize,maxdims,EEG_c,[],[],[]);
            EEG = pop_saveset(EEG, 'filename', EEG.filename(1:end-4),'filepath', [PATHOUT,SESSIONS{sess}]);
            
        end
    end

    rmpath(toolbox); 
    disp('removed ASR toolbox from path');
end
