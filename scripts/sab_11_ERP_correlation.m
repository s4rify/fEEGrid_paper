function [] = sab_11_ERP_correlation(path1, titlestring)
    %
    % sab_11_ERP_correlation.m--
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
    % Sarah Blum (sarah.blum@uol.de), 2019-06-19 13:06
    %-------------------------------------------------------------------------
    
    blue1 = [0,0,139]/255;
    blue2 = [30,144,255]/255;
    orange1 = [255,69,0]/255;
    orange2 = [255,165,0]/255;
    
    % channel for difference channels: grid
    PARAMS.forehead_chans = [1:3, 12:14]; % [left, right]
    PARAMS.lateral_chans = [9:11, 20:22]; % [left, right]
    % channels for difference channels channels: cap
    PARAMS.mastoids = [18,19]; % TP9/TP10: linked mastoids
    PARAMS.P3PzP4 = [21,20,22]; % parietal-central channels
    
    
    disp('loading variables...');
    rare_uncorr = load([path1,'ALLEEG_rare_uncorrected.mat']);
    rare_corr = load([path1,'ALLEEG_rare_corrected.mat']);
    
    % every second set is cap/grid
    grid_indices = [2:2: size(rare_uncorr.ALLEEG_rare,2)];
    cap_indices =  [1:2: size(rare_uncorr.ALLEEG_rare,2)];
    
    grid_rare_uncorr = pop_mergeset( rare_uncorr.ALLEEG_rare(grid_indices), 1:length(grid_indices));
    grid_rare_corr =   pop_mergeset( rare_corr.ALLEEG_rare(grid_indices),   1:length(grid_indices));
    cap_rare_uncorr = pop_mergeset( rare_uncorr.ALLEEG_rare(cap_indices),  1:length(cap_indices));
    cap_rare_corr =   pop_mergeset( rare_corr.ALLEEG_rare(cap_indices),   1:length(cap_indices));
    
    % compute diff channels
    % forehead vs lateral for grid
    diff_grid_rare_uncorr = mean(mean(grid_rare_uncorr.data(PARAMS.forehead_chans,:,:),1),3) - ...
        mean(mean(grid_rare_uncorr.data(PARAMS.lateral_chans,:,:),1),3);
    diff_grid_rare_corr = mean(mean(grid_rare_corr.data(PARAMS.forehead_chans,:,:),1),3) - ...
        mean(mean(grid_rare_corr.data(PARAMS.lateral_chans,:,:),1),3);
    
    % parietal vs mastoids for cap
    diff_cap_rare_uncorr = mean(mean(cap_rare_uncorr.data(PARAMS.P3PzP4,:,:),1),3) - ...
        mean(mean(cap_rare_uncorr.data(PARAMS.mastoids,:,:),1),3);
    diff_cap_rare_corr = mean(mean(cap_rare_corr.data(PARAMS.P3PzP4,:,:),1),3) - ...
        mean(mean(cap_rare_corr.data(PARAMS.mastoids,:,:),1),3);
    
    times = grid_rare_corr.times;
    
    % compute correlation
    r1 = corr(diff_grid_rare_corr',diff_grid_rare_uncorr', 'type', 'Spearman');
    r2 = corr(diff_cap_rare_corr', diff_cap_rare_uncorr',  'type', 'Spearman');
    r3 = corr(diff_cap_rare_corr', diff_grid_rare_corr',   'type', 'Spearman');
    
    % for the paper, we need correlation between uncorr cap and uncorr grid
    r_un = corr(diff_cap_rare_uncorr', diff_grid_rare_uncorr', 'type', 'Spearman');
    disp(['uncorrected cap vs uncorrected grid: R^2 = ', num2str(r_un*r_un)]);
    
    p = compare_correlation_coefficients(r1,r2,length(diff_grid_rare_corr),length(diff_cap_rare_corr));
    
    ymin = min([diff_grid_rare_corr, diff_grid_rare_uncorr, diff_cap_rare_corr, diff_cap_rare_uncorr]) - 0.5;
    ymax = max([diff_grid_rare_corr, diff_grid_rare_uncorr, diff_cap_rare_corr, diff_cap_rare_uncorr]) + 1;
    
    
    figure('rend', 'painters', 'units', 'centimeter', 'pos', [10,10,18,15], 'name', titlestring);
    supertitle([titlestring, ': uncorrected and corrected ERPs']);
    
    % GRID: correlation corrected and uncorrected
    subplot(1,4,1)
    hold on
    plot(times, diff_grid_rare_corr, 'Color', blue1);
    plot(times, diff_grid_rare_uncorr, ':', 'Color', blue2);
    xlabel('Time [ms]');
    ylabel('Amplitude [\muV]');
    ylim([ymin,ymax]);
    xlim([-200,800]);
    axis square
    legend('corrected', 'uncorrected', 'Location', 'SouthOutside');
    title([{[' R^2 = ', num2str(r1*r1, 2)]}]);
    
    % CAP: correlation corrected and uncorrected
    subplot(1,4,2)
    hold on
    plot(times, diff_cap_rare_corr, 'Color', orange1);
    plot(times, diff_cap_rare_uncorr, ':','Color', orange2);
    xlabel('Time [ms]');
    ylabel('Amplitude [\muV]');
    ylim([ymin,ymax]);
    xlim([-200,800]);
    set(gcf, 'Color', [1,1,1]);
    axis square
    legend('corrected', 'uncorrected', 'Location', 'SouthOutside');
    title([{[' R^2 = ', num2str(r2*r2, 2)]}]);
    
    
    % GRID AND CAP: correlation corrected 
    subplot(1,4,3)
    hold on
    plot(times, diff_cap_rare_corr, 'Color', orange1);
    plot(times, diff_grid_rare_corr, 'Color', blue1);
    xlabel('Time [ms]');
    ylabel('Amplitude [\muV]');
    ylim([ymin,ymax]);
    xlim([-200,800]);
    set(gcf, 'Color', [1,1,1]);
    axis square
    legend('corrected', 'corrected', 'Location', 'SouthOutside');
    title([{[' R^2 = ', num2str(r3*r3, 2)]}]);
    
    % GRID AND CAP: correlation corrected 
    subplot(1,4,4)
    title('uncorrected')
    hold on
    plot(times, diff_cap_rare_uncorr, ':', 'Color', orange2);
    plot(times, diff_grid_rare_uncorr, ':', 'Color', blue2);
    xlabel('Time [ms]');
    ylabel('Amplitude [\muV]');
    ylim([ymin,ymax]);
    xlim([-200,800]);
    set(gcf, 'Color', [1,1,1]);
    axis square
    legend('uncorrected', 'uncorrected', 'Location', 'SouthOutside');
    title([{[' R^2 = ', num2str(r_un*r_un, 2)]}]);
    
    set(findall(gcf,'-property','FontSize'),'FontSize',12);
    set(findall(gcf,'-property','FontName'),'FontName', 'Sans serif');
    % save this figure
    %saveas(gcf,['figures/correlation_', titlestring ,'.fig']);
    
end

function p = compare_correlation_coefficients(r1,r2,n1,n2)
    t_r1 = 0.5*log((1+r1)/(1-r1));
    t_r2 = 0.5*log((1+r2)/(1-r2));
    z = (t_r1-t_r2)/sqrt(1/(n1-3)+1/(n2-3));
    p = (1-normcdf(abs(z),0,1))*2;
end