function [] = sab_11_save_sets(marker1, marker2, PATHOUT)
%
% sab_11_save_sets.m--
%
% Input arguments: 
%
% Output arguments: 
%
% Other m-files required:   
%
% Example usage:   
%
%
% Developed in Matlab 9.3.0.948333 (R2017b) Update 9 on PCWIN64
% at University of Oldenburg.
% Sarah Blum (sarah.blum@uol.de), 2019-06-19 14:21
%-------------------------------------------------------------------------
    CORR_UNCORR = {['asr_cleaned/Evening/'], ['filtered/Evening/']};
    CLEAN = {'corrected', 'uncorrected'};
    PATH = [pwd, filesep, 'data', filesep];
    % boot eeglab
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
    
    % epoch parameters
    epoch.locthresh = 3;
    epoch.globthresh = 3;
    epoch.superpose = 0;
    epoch.reject = 1;
    epoch.vistype = 0; 

    ss = 1;
    
    for sess = 1 : length(CORR_UNCORR)
        flist = dir([PATH, CORR_UNCORR{sess},  '*.set']);
        clean = CLEAN{sess};
        for s = 1 : length(flist)
            EEG = pop_loadset('filename',flist(s).name,'filepath', [PATH, CORR_UNCORR{sess}]);
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
            EEG = eeg_checkset( EEG );
            
            % epoch, baseline removal, bad epoch rejection, store in new EEG set
            timerange = [-0.2, 0.8];
            baseline = [-200, 0];
            EEG_freq = sab_epoch(EEG, {marker1}, timerange, epoch, baseline, true);
            EEG_rare = sab_epoch(EEG, {marker2}, timerange, epoch, baseline, true);
            
            % add info to dataset
            EEG_freq.cleaned = clean;
            EEG_rare.cleaned = clean;
            
            % save everything
            ALLEEG_freq(ss) = EEG_freq;
            ALLEEG_rare(ss) = EEG_rare;
            ss = ss + 1;
            
        end % flist
        
        % save interim state
        save([PATHOUT, ['ALLEEG_freq_', clean, '.mat']], 'ALLEEG_freq');
        save([PATHOUT, ['ALLEEG_rare_', clean, '.mat']], 'ALLEEG_rare');
        ss = 1;
        clear ALLEEG_freq ALLEEG_rare
    end % corrected and uncorrected
end

