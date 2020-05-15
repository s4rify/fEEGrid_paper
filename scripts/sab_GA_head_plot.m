function [] = sab_GA_head_plot(FREQ, RARE, PARAMS,cond, show_big_plot, LIMITS)
    %
    % sab_GA_plot.m--
    % Required files:
    %    headplot
    %    pop_headplot
    %    pop_mergeset
    %    pop_reref
    %    supertitle
    %
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
    
    cap_limits = LIMITS{2};
    grid_limits = LIMITS{1};
    
    % merge the correct sets together, separated by recording method (grid, cap) and session (morning,
    % evening)
    fgrid.rare = pop_mergeset(RARE, PARAMS.grid_sessions);
    cap.rare = pop_mergeset(RARE, PARAMS.cap_sessions);
    fgrid.freq = pop_mergeset(FREQ, PARAMS.grid_sessions);
    cap.freq = pop_mergeset(FREQ, PARAMS.cap_sessions);
    
    % save time axis and sR for plots
    times = FREQ(1).times; % is the same for epoched data in FREQ and RARE
    sR = FREQ(1).srate;
    
    % compute diff channels
    % forehead vs lateral for grid
    diff_grid_rare = mean(mean(fgrid.rare.data(PARAMS.forehead_chans,:,:),1),3) - ...
        mean(mean(fgrid.rare.data(PARAMS.lateral_chans,:,:),1),3);
    diff_grid_freq = mean(mean(fgrid.freq.data(PARAMS.forehead_chans,:,:),1),3) -...
        mean(mean(fgrid.freq.data(PARAMS.lateral_chans,:,:),1),3);
    
    % parietal vs mastoids for cap
    diff_cap_rare = mean(mean(cap.rare.data(PARAMS.P3PzP4,:,:),1),3) - ...
        mean(mean(cap.rare.data(PARAMS.mastoids,:,:),1),3);
    diff_cap_freq = mean(mean(cap.freq.data(PARAMS.P3PzP4,:,:),1),3) - ...
        mean(mean(cap.freq.data(PARAMS.mastoids,:,:),1),3);
    
    % rereference data for topos as well
    fgrid.rare = pop_reref(fgrid.rare, PARAMS.lateral_chans);
    fgrid.freq = pop_reref(fgrid.freq, PARAMS.lateral_chans);
    cap.rare = pop_reref(cap.rare, PARAMS.mastoids);
    cap.freq = pop_reref(cap.freq, PARAMS.mastoids);
    
    % assemble information for the plot to combine parameters and data
    fgrid.rare.topotitle = 'rare';
    cap.rare.topotitle = 'rare';
    fgrid.freq.topotitle = 'freq';
    cap.freq.topotitle = 'freq';
    
    % compute new mesh file given the current number of channels and so on
    % this must be done only once for grid and cap, then the spline file can be used
    channel_or_component = 1;   % 1 = channel
    latencies = [100,200];      % ms in the epoch
    dimensions_subplot = [1,2]; % rows,col
    if show_big_plot
        GRID = pop_headplot(fgrid.rare, channel_or_component, latencies , 'title:', dimensions_subplot,  ...
            'setup',{'locations/spline/reduced_grid.spl', ...
            'meshfile', 'mheadnew.mat',...
            'transform' [0, 0, 0, 0, 0, -1.57, 8.7862, 8.7862, 8.7862]  }); % figured this out using the GUI
        %'plotmeshonly', 'head',...

        CAP = pop_headplot(cap.rare, channel_or_component, latencies , 'title:', dimensions_subplot,  ...
            'setup',{'locations/spline/reduced_cap.spl', ...
            'meshfile', 'mheadnew.mat'...
            'transform' [-1.4069 -5.8266 -46.9495 -0.003609 0.018499 -1.5453 9.409 10.1397 9.2901]  }); % figured this out using the GUI
        
        % assemble the info for the plot
        DATA = [fgrid.rare, cap.rare, fgrid.freq, cap.freq];
        CHAN_PARAMS = {PARAMS.grid_channels, PARAMS.cap_channels, PARAMS.grid_channels, PARAMS.cap_channels};
        TIME_PARAMS = {PARAMS.n100, PARAMS.p200, PARAMS.p300};
        SPLINES = {GRID.splinefile, CAP.splinefile};
        
        
        % open figure for the headplots only which is then saved as fig and as a rasterized image
        fig = figure('rend', 'painters', 'units', 'centimeters', 'pos', [1, 1, 19, 14], 'name', cond);
        
        %% GRID
        sp = 1;
        for d = 1 : 4 % grid rare, cap rare, grid freq, cap freq
            for p = 1 : 3 % 100 ms, 200 ms, 300 or 400 ms indices
                % get the correct time indices for this event
                param = TIME_PARAMS{p};
                % get the merged data sets, all subjects together, re-referenced data
                current_data = DATA(d);
                % get the erp names for the plot
                erp_name = PARAMS.erp_names{p};
                % average the data for the topoplot 
                topo_data = mean(mean(current_data.data(CHAN_PARAMS{d}, param, :), 3), 2);
                
                % special treatment for N400
                % all topos must be N400 topos for the N400 paradigm, no N100, P300 needed
                if p < 3 && strcmp(PARAMS.erp_names{3}, 'N400')
                    param = TIME_PARAMS{3}; % always use the third time indices window, because we are only interested in N400
                    current_data = DATA(d);
                    if d <= 2 % the 'rare' conditions are the meaningless sentences (target)
                        erp_name = 'meaningless';
                    else 
                        erp_name = 'meaningful';
                    end
                    topo_data = mean(mean(current_data.data(CHAN_PARAMS{d}, param, :), 3), 2); 
                end
                
                % last plot should be difference plot in case of N400
                if p == 3 && strcmp(PARAMS.erp_names{3}, 'N400') && (d == 1 || d == 2)
                    param = TIME_PARAMS{p};
                    current_data = DATA(d);
                    current_data_other = DATA(d+2);
                    erp_name = 'Diff N400';
                    topo_data = mean(mean(current_data.data(CHAN_PARAMS{d}, param, :), 3), 2) - ...
                        mean(mean(current_data_other.data(CHAN_PARAMS{d}, param, :), 3), 2);
                end
                
                % omg, it is happening
                subplot(4,6,sp);
                % cap heads
                if size(topo_data,1) > 16
                    sab_headplot(topo_data, SPLINES{2}, ...
                        'view', 'front',...
                        'title', [erp_name],...
                        'lighting', 'on' , ...
                        'labels', 0, ...
                        'lights', [0,1,0.5], ...
                        'maplimits', cap_limits ...
                        ...'cbar', 0 ...
                        );
                    %if sp == 4
                    %   cbar(0,3,[cap_limits(1) cap_limits(2)]);
                    %end
                else
                    % grid heads
                    sab_headplot(topo_data, SPLINES{1}, ...
                        'view', 'front',...
                        'title', [erp_name],...
                        'lighting', 'on' , ...
                        'labels', 0, ...
                        'lights', [0,1,0.5], ...
                        'maplimits', grid_limits ...
                        ...'cbar',0 ...
                        );
%                     if sp == 1
%                         cbar(0,3,[grid_limits(1) grid_limits(2)]);
%                     end
                end
                sp = sp + 1;
            end
        end
        saveas(gcf,['figures/threed_only_heads_', [PARAMS.nam] ,'.fig']);
        print(gcf, ['figures/threed_only_heads_', [PARAMS.nam] ,'.jpg'], '-djpeg', '-r600');
        
        
        % open a second figure only for the timeplot
        fig = figure('rend', 'painters', 'units', 'centimeters', 'pos', [1, 1, 19, 14], 'name', cond);
        % timeline plot grid
        subplot(4,6,[13,14,15, 19,20,21])
        hold on
        p = plot(times, diff_grid_rare, 'color', blue1);
        hold all
        plot(times, diff_grid_freq, 'color', blue2);
        xlabel('Time [ms]');
        ylabel('Amplitude [\muV]');
        set(findall(gcf,'-property','FontSize'),'FontSize',12);
        axis tight
        box on
        %legend('rare', 'freq')
        
        % plot topo areas
        hold all
        sab_draw_area(max(p.Parent.YLim), min(p.Parent.YLim), PARAMS.n100, times);
        sab_draw_area(max(p.Parent.YLim), min(p.Parent.YLim), PARAMS.p200, times);
        sab_draw_area(max(p.Parent.YLim), min(p.Parent.YLim), PARAMS.p300, times);
        
        % timeline plot cap
        subplot(4,6,[16,17,18, 22,23,24])
        pc = plot(times, diff_cap_rare, 'color', orange1);
        hold on
        plot(times, diff_cap_freq, 'color', orange2);
        xlabel('Time [ms]');
        %legend('rare', 'freq')
        % plot topo areas
        hold all
        sab_draw_area(max(pc.Parent.YLim), min(pc.Parent.YLim), PARAMS.n100, times);
        sab_draw_area(max(pc.Parent.YLim), min(pc.Parent.YLim), PARAMS.p200, times);
        sab_draw_area(max(pc.Parent.YLim), min(pc.Parent.YLim), PARAMS.p300, times);
        set(findall(gcf,'-property','FontSize'),'FontSize',12);
        set(gcf, 'Color', [1,1,1]);
        axis tight
        box on
        
        saveas(gcf,['figures/threedplot_only_lines_', [PARAMS.nam] ,'.fig']);        
    end

end



function sab_draw_area(maxval, minval, pos, times)
    a = area(times(pos), repmat(maxval,length(pos),1));
    a.FaceAlpha = 0.3;
    a.EdgeAlpha = 0;
    a.FaceColor = [192,192,192]/255;
    hold all
    b = area(times(pos), repmat(minval,length(pos),1));
    b.FaceAlpha = 0.3;
    b.EdgeAlpha = 0;
    b.FaceColor = [192,192,192]/255;
end



