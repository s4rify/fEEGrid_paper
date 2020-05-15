function [] = sab_GA_plot(FREQ, RARE, PARAMS, cond)
    %
    % sab_GA_plot.m--
    %
    % Input arguments:
    % FREQ and RARE, two ALLEEG structures that contain cap and grid data from the morning session (only
    % grid) and the evening session (grid and cap), divided by frequent and rare events. Participants
    % performed the same experiment in the morning and in the evening.
    % Both structures contain 40 entries (20 participants, 2 sessions):
    %   RARE(1:20): morning session (only grid: 22 channels)
    %   RARE(21:40): evening session (grid and cap: 46 channels (1:22 grid, 23:46 cap))
    %   and same for FREQ.
    %
    %
    %
    % Developed in Matlab 9.3.0.948333 (R2017b) Update 9 on PCWIN64
    % at University of Oldenburg.
    % Sarah Blum (sarah.blum@uol.de), 2019-05-17 14:51
    %-------------------------------------------------------------------------
    % plot colors
    blue1 = [0,0,139]/255;
    blue2 = [30,144,255]/255;
    orange1 = [255,69,0]/255;
    orange2 = [255,165,0]/255;
    
    
    % merge the correct sets together, separated by recording method (grid, cap) and session (morning,
    % evening)
    grid.rare = pop_mergeset(RARE, PARAMS.grid_sessions);
    cap.rare = pop_mergeset(RARE, PARAMS.cap_sessions);
    grid.freq = pop_mergeset(FREQ, PARAMS.grid_sessions);
    cap.freq = pop_mergeset(FREQ, PARAMS.cap_sessions);
    
    % save time axis for plotting
    times = FREQ(1).times; % is the same for all epoched data
    
    % compute diff channels
    % forehead vs lateral for grid
    diff_grid_rare = mean(mean(grid.rare.data(PARAMS.forehead_chans,:,:),1),3) - ...
        mean(mean(grid.rare.data(PARAMS.lateral_chans,:,:),1),3);
    diff_grid_freq = mean(mean(grid.freq.data(PARAMS.forehead_chans,:,:),1),3) -...
        mean(mean(grid.freq.data(PARAMS.lateral_chans,:,:),1),3);
    
    % parietal vs mastoids for cap
    diff_cap_rare = mean(mean(cap.rare.data(PARAMS.P3PzP4,:,:),1),3) - ...
        mean(mean(cap.rare.data(PARAMS.mastoids,:,:),1),3);
    diff_cap_freq = mean(mean(cap.freq.data(PARAMS.P3PzP4,:,:),1),3) - ...
        mean(mean(cap.freq.data(PARAMS.mastoids,:,:),1),3);
   
    %% add 2d channel information for topo, the 3d coordinates are not well distributed in the 2d case
    %cap.rare = pop_chanedit(cap.rare, 'load',{[pwd,'/locations/mobile24.elp'] 'filetype' 'autodetect'});
    %cap.rare = pop_chanedit(cap.rare, 'load',{[pwd,'/locations/mobile24.elp'] 'filetype' 'autodetect'});
    
    % rereference data for topos as well
    grid.rare = pop_reref(grid.rare, PARAMS.lateral_chans);
    grid.freq = pop_reref(grid.freq, PARAMS.lateral_chans);
    cap.rare = pop_reref(cap.rare, PARAMS.mastoids);
    cap.freq = pop_reref(cap.freq, PARAMS.mastoids);

    % assemble information for the plot to combine parameters and data
    grid.rare.topotitle = 'rare';
    cap.rare.topotitle = 'rare';
    grid.freq.topotitle = 'freq';
    cap.freq.topotitle = 'freq';

    fig = figure('rend', 'painters', 'pos', [100, 100, 1280, 800]);

   
    % the radii are too small for the topo, let's spread the electrodes a little bit better    
    for n=1:length(cap.rare.chanlocs)
      cap.rare.chanlocs(1,n).radius = cap.rare.chanlocs(1,n).radius* 1.69; % 0.7893
      cap.freq.chanlocs(1,n).radius = cap.freq.chanlocs(1,n).radius* 1.69; % 0.7893
    end

    DATA = [grid.rare, cap.rare, grid.freq, cap.freq];
    CHAN_PARAMS = {PARAMS.grid_channels, PARAMS.cap_channels, PARAMS.grid_channels, PARAMS.cap_channels};
    TIME_PARAMS = {PARAMS.n100, PARAMS.p200, PARAMS.p300};
        
    %% GRID
    sp = 1;
    for d = 1 : 4
        for p = 1 : 3
            param = TIME_PARAMS{p};
            current_data = DATA(d);
            erp_name = PARAMS.erp_names{p};
            topo_data = mean(mean(current_data.data(CHAN_PARAMS{d}, param, :), 3), 2);

            subplot(4,6,sp);
            h = topoplot(topo_data, current_data.chanlocs, 'plotrad', 0.7);
            title(h.Parent, [current_data.topotitle, erp_name]);

            sp = sp + 1;
        end
    end

    % timeline plot
    ntrials_rare = round(size(cap.rare.data,3)/20); %subjects
    ntrials_freq = round(size(cap.freq.data,3)/20); %subjects
    subplot(4,6,[16,17,18, 22,23,24])
    plot(times, diff_cap_rare, 'color', blue1);
    hold on
    plot(times,  diff_cap_freq, 'color', blue2);
    title(['[P3 P4 Pz] - [linked mastoids] ' newline...
         'ntrials rare: ', num2str(ntrials_rare), ', ntrials freq: ', num2str(ntrials_freq), ' per subject']);
    legend('rare cap', 'frequent cap');
    xlabel('CAP DATA');

    % timeline plot
    ntrials_rare = round(size(grid.rare.data,3)/20); %subjects
    ntrials_freq = round(size(grid.freq.data,3)/20); %subjects
    subplot(4,6,[13,14,15, 19,20,21])
    plot(times, diff_grid_rare, 'color', orange1);
    hold on
    plot(times, diff_grid_freq, 'color', orange2);
    title(['[averaged forehead channels] - [averaged lower lateral channels] ' newline, ...
            'ntrials rare: ', num2str(ntrials_rare), ', ntrials freq: ', num2str(ntrials_freq), ' per subject']);
    legend('rare grid', 'frequent grid');
    xlabel('GRID DATA');
    
    supertitle(['Response on frequent (standard) and rare (deviant) events, ' cond]);
    saveas(gcf,['figures/twodplot_', [PARAMS.nam] ,'.jpg']);