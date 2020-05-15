function [] = sab_06_assemble_GA_plot(path1, name, condition, erp, show_big_plot, LIMITS)
    %
    % sab_07_assemple_GA_plot.m--
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
    % Sarah Blum (sarah.blum@uol.de), 2019-05-23 13:42
    %-------------------------------------------------------------------------
    disp('loading variables...');
    load([path1,'ALLEEG_freq.mat']);
    load([path1,'ALLEEG_rare.mat']);
    
    % this is used for saving the figure in the end
    PARAMS.nam = name;
    
    % session info: the data sets are read-in alternatingly, so every other data set is the grid set
    PARAMS.grid_sessions = find([ALLEEG_freq.nbchan]  == 22);
    PARAMS.cap_sessions = find([ALLEEG_freq.nbchan] == 24);
    % if one index is contained in both arrays, something went wrong
    assert( ~ any(PARAMS.grid_sessions == PARAMS.cap_sessions));
    
    
    % channel for difference channels: grid
    PARAMS.forehead_chans = [1:3, 12:14]; % [left, right]
    PARAMS.lateral_chans = [9:11, 20:22]; % [left, right]
    % channels for difference channels channels: cap
    PARAMS.mastoids = [18,19]; % TP9/TP10: linked mastoids
    PARAMS.P3PzP4 = [21,20,22]; % parietal-central channels
    
    % channel info:after rerferencing: less channels
    PARAMS.grid_channels = [1:16];
    PARAMS.cap_channels = [1:22];
    
    % topos
    switch erp
        case 'P300 audio'
            PARAMS.n100 = 50:60; 
            PARAMS.p200 = 80:86;
            PARAMS.p300 = 150:180;
        case 'P300 vibro'
            PARAMS.n100 = 85:90; 
            PARAMS.p200 = 140:150;
            PARAMS.p300 = 180:200;

        case 'N400'
            PARAMS.n100 = 55:60;
            PARAMS.p200 = 105:110;
            PARAMS.p300 = 175:250;
    end
    
    % adapt for baseline 
    PARAMS.n100 = PARAMS.n100 + 100; % 100 samples = 200 ms
    PARAMS.p200 = PARAMS.p200 + 100; % 100 samples = 200 ms
    PARAMS.p300 = PARAMS.p300 + 100; % 100 samples = 200 ms

    % make adaptable
    PARAMS.erp_names = {'N100', 'P200', erp};
    
    sab_GA_head_plot(ALLEEG_freq, ALLEEG_rare, PARAMS, condition, show_big_plot, LIMITS);
    
end