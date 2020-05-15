function [] = sab_12_impedance_plot(impedances_morning, impedances_evening)
    %
    % sab_12_impedance_plot.m--
    %
    %
    %
    % Developed in Matlab 9.3.0.948333 (R2017b) Update 9 on PCWIN64
    % at University of Oldenburg.
    % Sarah Blum (sarah.blum@uol.de), 2019-07-09 15:49
    %-------------------------------------------------------------------------

    % we want the channels in the correct order: beginning at left lateral, over central channels to
    % right lateral channels
    channel_order = [11:-1:1, 12:1:22];
    num_channels = length(channel_order);

    % add one row with mean value
    mean_morning = mean(impedances_morning,1, 'omitnan');
    mean_evening = mean(impedances_evening,1, 'omitnan');
    
    % some additional information for the paper
    disp(['mean frontal channels morning: ', num2str(mean(mean(impedances_morning(:,[1,2,12,13]), 'omitnan')))]);
    disp(['mean frontal channels evening: ', num2str(mean(mean(impedances_evening(:,[1,2,12,13]), 'omitnan')))]);
    disp(['mean lateral channels morning: ', num2str(mean(mean(impedances_morning(:,[10,11,21,22]), 'omitnan')))]);
    disp(['mean lateral channels evening: ', num2str(mean(mean(impedances_evening(:,[10,11,21,22]), 'omitnan')))]);
    
    
    % this should be outside this function but for now, let's quickly compute the t-test here
    % frontal morning vs lateral morning
    mean_morning_frontal = mean(impedances_morning(:,[1,2,12,13]),  1, 'omitnan');
    mean_morning_lateral = mean(impedances_morning(:,[10,11,21,22]),1, 'omitnan');
    [h,p,ci,stats] = ttest(mean_morning_frontal, mean_morning_lateral);
    mes(mean_morning_frontal', mean_morning_lateral', 'hedgesg')
    
    
    % frontal morning vs lateral evening
    mean_evening_frontal = mean(impedances_evening(:,[1,2,12,13]),  1, 'omitnan');
    mean_evening_lateral = mean(impedances_evening(:,[10,11,21,22]),1, 'omitnan');
    [h,p,ci,stats] = ttest(mean_evening_frontal, mean_evening_lateral);
    mes(mean_evening_frontal', mean_evening_lateral', 'hedgesg')
    
    % add average as an additonal 'channel' to the last row
    %impedances_evening(end+1, :)  = repmat(nan, 1, num_channels);
    %impedances_morning(end+1, :)  = repmat(nan, 1, num_channels);
    
    impedances_evening(end+1, :) = mean_evening;
    impedances_morning(end+1, :) = mean_morning;
    impedances_evening(end+1, :) = mean_evening;
    impedances_morning(end+1, :) = mean_morning;
    
    f = figure('rend', 'painters',  'Units', 'centimeters', 'pos', [1,1,16,18]);
    h1 = subplot(1,2,1);
    % plot image without NaN values
    im = imagesc(impedances_morning(:,channel_order), 'AlphaData', ~isnan(impedances_morning));
    % change x-axis values to new channel labels
    oldTicks = im.Parent.XTick;
    %newTicks = {['\leftarrow',' left'], '        central', '', ['right ', '\rightarrow']};
    newTicks = {['left'], '        center', '', ['right ']};
    set(gca,'TickLabelInterpreter', 'tex');
    set(gca,'XTickLabel', newTicks);
    % change ylabels to add mean in last entry
    oldTicks_y = im.Parent.YTick;
    oldTicks_y = string(oldTicks_y);
    oldTicks_y(end) = 'avg';
    set(gca, 'YTickLabel',oldTicks_y);
    % add some information
    title('Morning');
    xlabel('Channels');
    ylabel('Participants');
    caxis([0,80])
    % Get the current axis size to later fix the resizing from the stupid colorbar
    originalSize1 = get(gca, 'Position');
    
    h2 = subplot(1,2,2);
    % plot values and omit NaNs
    im2 = imagesc(impedances_evening(:, channel_order),'AlphaData', ~isnan(impedances_evening));
    % change x-axis values to new channel labels
    oldTicks = im2.Parent.XTick;
    %newTicks = {['\leftarrow',' left'], '        central', '', ['right ', '\rightarrow']};
    newTicks = {['left'], '        center', '', ['right ']};
    set(gca,'TickLabelInterpreter', 'tex');
    set(gca,'XTickLabel', newTicks);
    % change ylabels to add mean in last entry
    oldTicks_y = im.Parent.YTick;
    oldTicks_y = string(oldTicks_y);
    oldTicks_y(end) = 'avg';
    set(gca, 'YTickLabel',oldTicks_y);
    title('Evening')
    xlabel('Channels');
    caxis([0,80])
    originalSize2 = get(gca, 'Position');
    cb = colorbar;
    
    % resize images because of colorbar
    set(h1, 'Position', originalSize1);
    set(h2, 'Position', originalSize2);
    
    % white background
    set(gcf, 'Color', [1,1,1])
    set(findall(gcf,'-property','FontSize'),'FontSize',12);
    
    % this figure was just copy-pasted into the word document, no post processing or export
end


