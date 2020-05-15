function [] = sab_10_group_plot(ACC, titlestring, X, Y, T)
    %
    % sab_10_group_plot.m--
    %
    %
    %
    % Developed in Matlab 9.3.0.948333 (R2017b) Update 9 on PCWIN64
    % at University of Oldenburg.
    % Sarah Blum (sarah.blum@uol.de), 2019-06-18 10:17
    %-------------------------------------------------------------------------
    
    % average per recording hardware. for every subject, we have three entries in AUC, first one for
    % grid morning, second one for grid evening and third one cap. So, every third entry needs to be
    % averaged in order to get the average classifier performance for this hardware given this task.
    COLORS = {[30,144,255]/255, [0,0,205]/255, [255,140,0]/255};
    
    % resample (interpolate) entries in X,Y, average them, then plot only three lines: grid morning, grid evening,
    % cap containing averaged values for all subjects
    
    % get max entry value: max bias shifts in ROC curve
    max_val = max(max(cellfun('size',X,1)), max(cellfun('size',Y,1)));
    xq = 1: max_val; % time vector, the regular values for which we need a new value in every array
    
    for i = 1: length(X)
        a = X{i};
        x = 1 : numel(a);
        xp = linspace(x(1), x(end), max_val); %// Specify output points
        new_x(i,:) = interp1(x, a, xp);
        
        b = Y{i}; % too short vector here which needs to be interpolated
        y = 1 : numel(b); % regular points (for what?) 
        yp = linspace(y(1), y(end), max_val); % Specify output points at which we need new values
        new_y(i,:) = interp1(y, b, yp); % magic
    end
    
        
    figure('rend', 'painters', 'units', 'centimeter', ...
        'pos', [10,10,20,15],'name', ['Session transfer: ', titlestring]);
    
    % bars
    subplot(1,2,1)
    %bar([AUC{:}])
    bar([ACC]);
    axis square
    axis tight
    ylim([0,1]);
    xlabel('Subjects')
    ylabel('Accuracy')
    title([titlestring, 'Single Subject Acc'])
    % add error bars to bars
    
    
    % ROC curve
    subplot(1,2,2);
    plot(mean(new_x,1), mean(new_y,1));
    axis square
    axis tight
    ylim([0,1]);
    xlim([0,1]);
    title('ROC curve')
    xlabel('False positive rate')
    ylabel('True positive rate')
    
    set(findall(gcf,'-property','FontSize'),'FontSize',12);
    saveas(gcf,['figures/ROC_average_session_transfer', titlestring ,'.fig']);
    
