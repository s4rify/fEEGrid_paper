function [ACC, X, Y, T, AUC] = sab_08_cross_session_classification_evening(models,marker_one, marker_two)
    %
    % sab_08_LDA_classification.m--
    %
    % Classify and visualize
    %
    % Input arguments:
    %   Trained classifiers for every single subject.
    %
    %
    % Developed in Matlab 9.3.0.948333 (R2017b) Update 9 on PCWIN64
    % at University of Oldenburg.
    % Sarah Blum (sarah.blum@uol.de), 2019-06-05 19:42
    %-------------------------------------------------------------------------
    
    PATHIN = 'data/asr_cleaned/';
    SESSIONS = {'Morning/', 'Evening/'};
    % we only want evening data to use for the session-transfer validation
    flist_evening = dir([PATHIN, SESSIONS{2},  '*_grid.set']);
    flist_morning = dir([PATHIN, SESSIONS{1},  '*_grid.set']);
    
    % loop through datasets to create the test tables from the evening feegrid data only
    for s = 1 : length(flist_evening)
        fname_evening = flist_evening(s).name;
        fname_morning = flist_morning(s).name;
        evening_session_path = [PATHIN, SESSIONS{2}];
        
        [cross_session_test_table]  = sab_create_table(fname_evening, evening_session_path, marker_one, marker_two);
        TEST_TABLES{s} = cross_session_test_table;
        
        % use the matching model for this subj but from morning
        tmp = [models{:}]; % matlab cannot index expressions
        index = find(strcmp({tmp.filename}, fname_morning));
        %assert(all(fname_evening == models{index}.filename));
        
        % models{1}.kfold_scores and models{1}.kfold_predictions contain the performance across cross
        % validations, right? so use them to compute the standard deviation across training
        
        % scores and POSTERIOR contain EXACTLY the same values
        [label, scores] = models{index}.classifier.predictFcn(TEST_TABLES{s});

        % compute accuracy and so on parameters
        [CM, GORDER] = confusionmat(TEST_TABLES{s}.Label, label);
        tp = CM(1,1);
        fn = CM(1,2);
        fp = CM(2,1);
        tn = CM(2,2);
        % https://classeval.wordpress.com/introduction/basic-evaluation-measures/
        acc = (tp+tn)/(tp + tn + fn + fp);
        ACC(s) = acc;
        
        % score contains the posterior prob that a given datapoint belongs to the class, so if we want to
        % know hos well we performed, we need to know how much was missing for a perfect score
        diff_score = scores(:,1) - scores(:,2);
        
        % Receiver Operator Characteristic
        pos_class_name = marker_one;
        [X{s},Y{s},T,AUC{s},OPTROCPT]  = perfcurve(TEST_TABLES{s}.Label, diff_score, pos_class_name);
    end
    
end