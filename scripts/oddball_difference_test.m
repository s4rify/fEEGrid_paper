function [] = oddball_difference_test(condition)
    %
    % oddball_difference_test.m--
    %
    % Input arguments:
    %       p300 audio, p300 vibro, n400: the path specification for the respective paradigm
    %
    % Other m-files required:
    %       computeCohen_d
    %
    %
    % Developed in Matlab 9.3.0.948333 (R2017b) Update 9 on PCWIN64
    % at University of Oldenburg.
    % Sarah Blum (sarah.blum@uol.de), 2019-08-06 14:09
    %-------------------------------------------------------------------------
    
    % channels: grid
    forehead_chans = [1:3, 12:14]; % [left, right]
    lateral_chans = [9:11, 20:22]; % [left, right]
    % channels: cap
    reference = [18,19]; % TP9/TP10: linked mastoids
    P3PzP4 = [20,21,22]; % parietal-central channels
    
    time_window = 270:370; %ms
    
    % file locations
    PATHIN = ['data/epoched/', condition];
    
    % boot eeglab
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
    
    flist_freq_cap = dir([PATHIN, '*cap_freq.set']);
    flist_rare_cap = dir([PATHIN, '*cap_rare.set']);
    
    flist_freq_grid = dir([PATHIN, '*grid_freq.set']);
    flist_rare_grid = dir([PATHIN, '*grid_rare.set']);
    
    for s = 1 : length(flist_freq_grid) % same length for freq and rare

        % load epoched data from this subject, recorded by cap and grid
        EEG_freq_cap = pop_loadset('filename',flist_freq_cap(s).name,'filepath', [PATHIN]);
        EEG_rare_cap = pop_loadset('filename',flist_rare_cap(s).name,'filepath', [PATHIN]);
        EEG_freq_grid = pop_loadset('filename',flist_freq_grid(s).name,'filepath', [PATHIN]);
        EEG_rare_grid = pop_loadset('filename',flist_rare_grid(s).name,'filepath', [PATHIN]);
        
        % same for everyone, I just needed the time axis to get the sample indices
        time_window_samples = [find(EEG_freq_cap.times == time_window(1)) : find(EEG_freq_cap.times == time_window(end))];
        
        % compute subject average for difference channel (same channels for all subjects)
        % this is the average ERP for this subject, recorded with cap and grid and elicited by rare or freq
        % stimulus
        diff_freq_cap = mean(mean(EEG_freq_cap.data(P3PzP4,:,:),1),3) - ...
                        mean(mean(EEG_freq_cap.data(reference,:,:),1),3);
        diff_rare_cap = mean(mean(EEG_rare_cap.data(P3PzP4,:,:),1),3) - ...
                        mean(mean(EEG_rare_cap.data(reference,:,:),1),3);
        
        diff_freq_grid = mean(mean(EEG_freq_grid.data(forehead_chans,:,:),1),3) - ...
                            mean(mean(EEG_freq_grid.data(lateral_chans,:,:),1),3);
        diff_rare_grid = mean(mean(EEG_rare_grid.data(forehead_chans,:,:),1),3) - ...
                            mean(mean(EEG_rare_grid.data(lateral_chans,:,:),1),3);
        
        % save max value of ERP from this subject
        FREQ_CAP(s) = max(diff_freq_cap(1,time_window_samples));
        RARE_CAP(s) = max(diff_rare_cap(1,time_window_samples));
        
        FREQ_GRID(s) = max(diff_freq_grid(1,time_window_samples));
        RARE_GRID(s) = max(diff_rare_grid(1,time_window_samples));
        
    end
    
    [H_c,P_c,CI_c,STATS_c] = ttest(RARE_CAP, FREQ_CAP)
    mc = mes(RARE_CAP', FREQ_CAP', 'hedgesg');
    disp(['Hedges g (cap): ', num2str(mc.hedgesg)]);
    
    [H_g,P_g,CI_g,STATS_g] = ttest(RARE_GRID, FREQ_GRID)
    mg = mes(RARE_GRID', FREQ_GRID', 'hedgesg');
    disp(['Hedges g (grid): ', num2str(mg.hedgesg)]);
    
    disp(['mean freq cap ', num2str(mean(FREQ_CAP))]);
    disp(['mean rare cap ', num2str(mean(RARE_CAP))]);
    
    disp(['mean freq grid ', num2str(mean(FREQ_GRID))]);
    disp(['mean rare grid ', num2str(mean(RARE_GRID))]);
    
    
end
