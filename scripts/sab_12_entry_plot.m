function [] = sab_12_entry_plot()
    %
    % sab_12_entry_plot.m--
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
    % Sarah Blum (sarah.blum@uol.de), 2019-06-26 11:42
    %-------------------------------------------------------------------------
    
    % plot colors
    % blue is grid
    blue1 = [0,0,139]/255;
    blue2 = [30,144,255]/255;
    % orange is cap
    orange1 = [255,69,0]/255;
    orange2 = [255,165,0]/255;
    
    % fontsize
    fsize = 12;
    ylims = [-250, 200];
    
    % load same subject, same session, grid and cap data
    [ALLEEG, EEG ,CURRENTSET ,ALLCOM] = eeglab;
    EEG = pop_loadset('filename',{'sab_e_0005_evening_cap.set' 'sab_e_0005_evening_grid.set'}, ...
        'filepath',[pwd, '\data\\filtered\\Evening\\']);
    [ALLEEG, EEG ,CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'study',0);
    
    % xaxis 
    interval = 1000:2000;
    times = ALLEEG(1).times(interval);
    
    cap_filtered = ALLEEG(1);
    grid_filtered = ALLEEG(2);
    CHANNEL = [1,10];
    
    % filtered data 
    fig = figure('rend', 'painters', 'unit', 'centimeters', 'pos', [10, 10, 12, 10]);
    supertitle('Filtered-only data');
    subplot(2,1,1)
    hold all
    plot(ALLEEG(1).times(interval), grid_filtered.data(CHANNEL(1), interval), 'Color', blue1);
    plot(ALLEEG(1).times(interval), grid_filtered.data(CHANNEL(2), interval), 'Color', blue2);
    ylim(ylims);
    title('grid');
    legend('grid frontal', 'grid lateral');
    fig.CurrentAxes.FontSize = fsize;
    fig.CurrentAxes.XTickLabel = {};
    
    % plot same interval on lateral channels
    subplot(2,1,2)
    hold all
    plot(ALLEEG(1).times(interval), cap_filtered.data(CHANNEL(1), interval), 'Color', orange1)
    plot(ALLEEG(1).times(interval), cap_filtered.data(CHANNEL(2), interval), 'Color', orange2)
    ylim(ylims);
    title('cap');
    legend('cap frontal', 'cap lateral');
    fig.Color = [1,1,1];
    fig.CurrentAxes.FontSize = fsize;
    fig.CurrentAxes.XTickLabel = {};
    
    
    %% corrected data
    % load same subject, same session, grid and cap data
    [ALLEEG, EEG ,CURRENTSET ,ALLCOM] = eeglab;
    EEG = pop_loadset('filename',{'sab_e_0005_evening_cap.set' 'sab_e_0005_evening_grid.set'}, ...
        'filepath',[pwd, '\data\\asr_cleaned\\Evening\\']);
    [ALLEEG, EEG ,CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'study',0);
    
    cap_corrected = ALLEEG(1);
    grid_corrected = ALLEEG(2);
    CHANNEL = [1,10];
    
    fig = figure('rend', 'painters', 'unit', 'centimeters', 'pos', [10, 10, 12, 10]);
    supertitle('corrected data');
    subplot(2,1,1)
    hold all
    plot(times, grid_corrected.data(CHANNEL(1), interval), 'Color', blue1);
    plot(times, grid_corrected.data(CHANNEL(2), interval), 'Color', blue2);
    ylim(ylims);
    title('grid');
    legend('grid frontal', 'grid lateral');
    fig.CurrentAxes.FontSize = fsize;
    fig.CurrentAxes.XTickLabel = {};
    
    % plot same interval on lateral channels
    subplot(2,1,2)
    hold all
    plot(times, cap_corrected.data(CHANNEL(1), interval), 'Color', orange1)
    plot(times, cap_corrected.data(CHANNEL(2), interval), 'Color', orange2)
    ylim(ylims);
    title('cap');
    legend('cap frontal', 'cap lateral');
    fig.Color = [1,1,1];
    fig.CurrentAxes.FontSize = fsize;
    fig.CurrentAxes.XTickLabel = {};
    
    
    fig.Color = [1,1,1];
    fig.CurrentAxes.FontSize = fsize;
    fig.CurrentAxes.XTickLabel = {};
    