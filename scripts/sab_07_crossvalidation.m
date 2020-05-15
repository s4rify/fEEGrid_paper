function [MODEL, N_ONE, N_TWO] = sab_07_crossvalidation(marker_one, marker_two)
    %
    %
    %
    % Developed in Matlab 9.3.0.948333 (R2017b) Update 9 on PCWIN64
    % at University of Oldenburg.
    % Sarah Blum (sarah.blum@uol.de), 2019-06-05 11:12
    %-------------------------------------------------------------------------
    
    PATHIN = 'data/asr_cleaned/';
    SESSIONS = {'Morning/', 'Evening/'};
    
    % we need one model for every subject morning and evening and grid and cap: 60 models
    m = 1;
    
    % loop through datasets
    for s = 1 : length(SESSIONS)
        flist = dir([PATHIN, SESSIONS{s},  '*.set']);
        
        for j = 1 : length(flist)
            fname = flist(j).name;
            session_path = [PATHIN, SESSIONS{s}];
            
            % if we use k-fold we do not need a test table, we then just submit everything to the function and
            % let the function do the splitting during the k-fold
            [cross_valid_table, n_one, n_two]  = sab_create_table(fname, session_path, marker_one, marker_two);
            
            % extract information which is otherwise hardcorded in the generated code of the classification learner app
            predictor_names = cross_valid_table.Properties.VariableNames;
            class_names = [marker_one; marker_two];
            
            % create classification model for the given subject
            [classifier, accuracy, validationPredictions, validationScores, kfold_accuracies, kfold_auc, AUC] = ...
                trainClassifier(cross_valid_table, predictor_names, class_names);        
            
            % assemble information
            MODEL{m}.type = fname(end-7:end-4);
            MODEL{m}.session = SESSIONS{s}(1:end-1);
            MODEL{m}.filename = fname;
            MODEL{m}.classifier = classifier;
            % these are the performance scores for the validated model
            MODEL{m}.acc = accuracy;
            MODEL{m}.kfold_predictions = validationPredictions;
            MODEL{m}.kfold_scores = validationScores;
            MODEL{m}.AUC = AUC;
            % these perfomances are the ones for every split in the cross validation
            MODEL{m}.kfold_accuracies = kfold_accuracies;
            MODEL{m}.kfold_auc = kfold_auc;
            m = m + 1;
            
            N_ONE(m) = n_one;
            N_TWO(m) = n_two;
        end
    end
    
end

