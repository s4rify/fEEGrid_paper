function [] = sab_10_cross_val_plot(models, titlestring)
%
% sab_10_cross_val_plot.m--
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
% Sarah Blum (sarah.blum@uol.de), 2019-07-30 16:51
%-------------------------------------------------------------------------
    tmp = [models{:}]; % matlab cannot index expressions
    idx_grid1 = find(contains({tmp.filename}, '_morning_grid'));
    idx_grid2 = find(contains({tmp.filename}, '_evening_grid'));
    idx_cap = find(contains({tmp.filename}, '_cap'));
    
    % retrieve the matching models for the data sets
    all_grid1 = [models{idx_grid1}];
    all_grid2 = [models{idx_grid2}];
    all_cap = [models{idx_cap}];
    
    % barwitherr(errors, [AUC{:}]);
    % standard error of accuracies across kfold validation :  std( data ) / sqrt( length( data ))
    for s = 1 : size(all_grid1,2) % same n for all sessions
        se_grid1(s) = std([all_grid1(s).kfold_accuracies]) / sqrt([length(all_grid1(s).kfold_accuracies)]);
        se_grid2(s) = std([all_grid2(s).kfold_accuracies]) / sqrt([length(all_grid2(s).kfold_accuracies)]);
        se_cap(s)   = std([all_cap(s).kfold_accuracies])   / sqrt([length(all_cap(s).kfold_accuracies)]);
    end
    
    MODELS = {all_grid1, all_grid2, all_cap};
    SE = {se_grid1, se_grid2, se_cap};
    TITLES = {'fEEGrid morning', 'fEEGrid afternoon', 'Cap'};
    
    figure('rend', 'painters', 'units', 'centimeter', ...
        'pos', [10,10,25,12],'name', ['Cross-Validation Acc.: ', titlestring]);
    supertitle([titlestring, 'Classification Accuracy per session, STD across kfolds']);
    
    for sp = 1 : 3
        % grid morning
        subplot(1,3,sp)
        barwitherr(SE{sp}, [MODELS{sp}.acc]);
        axis square
        axis tight
        ylim([0,1]);
        title([TITLES{sp}, ',mean=', num2str(mean([MODELS{sp}.acc]),2)]);
        xlabel('Participant (n)');
        ylabel('Accuracy')
    end
    
    % add chance level 

    
    set(findall(gcf,'-property','FontSize'),'FontSize',12);
    set(gcf, 'Color', 'white')
    
end