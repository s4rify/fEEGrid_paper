function [trainedClassifier, validationAccuracy, validationPredictions, validationScores, kfold_accuracies, kfold_auc, AUC] = ...
        trainClassifier(trainingData, predictor_names, class_names)
    % [trainedClassifier, validationAccuracy] = trainClassifier(trainingData)
    % returns a trained classifier and its accuracy. This code recreates the
    % classification model trained in Classification Learner app. Use the
    % generated code to automate training the same model with new data, or to
    % learn how to programmatically train models.
    %
    %  Input:
    %      trainingData: a table containing the same predictor and response
    %       columns as imported into the app.
    %
    %  Output:
    %      trainedClassifier: a struct containing the trained classifier. The
    %       struct contains various fields with information about the trained
    %       classifier.
    %
    %      trainedClassifier.predictFcn: a function to make predictions on new
    %       data.
    %
    %      validationAccuracy: a double containing the accuracy in percent. In
    %       the app, the History list displays this overall accuracy score for
    %       each model.
    %
    % Use the code to train the model with new data. To retrain your
    % classifier, call the function from the command line with your original
    % data or new data as the input argument trainingData.
    %
    % For example, to retrain a classifier trained with the original data set
    % T, enter:
    %   [trainedClassifier, validationAccuracy] = trainClassifier(T)
    %
    % To make predictions with the returned 'trainedClassifier' on new data T2,
    % use
    %   yfit = trainedClassifier.predictFcn(T2)
    %
    % T2 must be a table containing at least the same predictor columns as used
    % during training. For details, enter:
    %   trainedClassifier.HowToPredict
    
    % Auto-generated by MATLAB on 31-Jul-2019 14:13:20
    
    
    % Extract predictors and response
    % This code processes the data into the right shape for training the
    % model.
    inputTable = trainingData;
    %predictorNames = {'ch1w1', 'ch1w2', 'ch1w3', 'ch1w4', 'ch1w5', 'ch1w6', 'ch1w7', 'ch1w8', 'ch1w9', 'ch1w10', 'ch1w11', 'ch1w12', 'ch1w13', 'ch1w14', 'ch1w15', 'ch2w1', 'ch2w2', 'ch2w3', 'ch2w4', 'ch2w5', 'ch2w6', 'ch2w7', 'ch2w8', 'ch2w9', 'ch2w10', 'ch2w11', 'ch2w12', 'ch2w13', 'ch2w14', 'ch2w15', 'ch3w1', 'ch3w2', 'ch3w3', 'ch3w4', 'ch3w5', 'ch3w6', 'ch3w7', 'ch3w8', 'ch3w9', 'ch3w10', 'ch3w11', 'ch3w12', 'ch3w13', 'ch3w14', 'ch3w15', 'ch4w1', 'ch4w2', 'ch4w3', 'ch4w4', 'ch4w5', 'ch4w6', 'ch4w7', 'ch4w8', 'ch4w9', 'ch4w10', 'ch4w11', 'ch4w12', 'ch4w13', 'ch4w14', 'ch4w15', 'ch5w1', 'ch5w2', 'ch5w3', 'ch5w4', 'ch5w5', 'ch5w6', 'ch5w7', 'ch5w8', 'ch5w9', 'ch5w10', 'ch5w11', 'ch5w12', 'ch5w13', 'ch5w14', 'ch5w15', 'ch6w1', 'ch6w2', 'ch6w3', 'ch6w4', 'ch6w5', 'ch6w6', 'ch6w7', 'ch6w8', 'ch6w9', 'ch6w10', 'ch6w11', 'ch6w12', 'ch6w13', 'ch6w14', 'ch6w15', 'ch7w1', 'ch7w2', 'ch7w3', 'ch7w4', 'ch7w5', 'ch7w6', 'ch7w7', 'ch7w8', 'ch7w9', 'ch7w10', 'ch7w11', 'ch7w12', 'ch7w13', 'ch7w14', 'ch7w15', 'ch8w1', 'ch8w2', 'ch8w3', 'ch8w4', 'ch8w5', 'ch8w6', 'ch8w7', 'ch8w8', 'ch8w9', 'ch8w10', 'ch8w11', 'ch8w12', 'ch8w13', 'ch8w14', 'ch8w15', 'ch9w1', 'ch9w2', 'ch9w3', 'ch9w4', 'ch9w5', 'ch9w6', 'ch9w7', 'ch9w8', 'ch9w9', 'ch9w10', 'ch9w11', 'ch9w12', 'ch9w13', 'ch9w14', 'ch9w15', 'ch10w1', 'ch10w2', 'ch10w3', 'ch10w4', 'ch10w5', 'ch10w6', 'ch10w7', 'ch10w8', 'ch10w9', 'ch10w10', 'ch10w11', 'ch10w12', 'ch10w13', 'ch10w14', 'ch10w15', 'ch11w1', 'ch11w2', 'ch11w3', 'ch11w4', 'ch11w5', 'ch11w6', 'ch11w7', 'ch11w8', 'ch11w9', 'ch11w10', 'ch11w11', 'ch11w12', 'ch11w13', 'ch11w14', 'ch11w15', 'ch12w1', 'ch12w2', 'ch12w3', 'ch12w4', 'ch12w5', 'ch12w6', 'ch12w7', 'ch12w8', 'ch12w9', 'ch12w10', 'ch12w11', 'ch12w12', 'ch12w13', 'ch12w14', 'ch12w15', 'ch13w1', 'ch13w2', 'ch13w3', 'ch13w4', 'ch13w5', 'ch13w6', 'ch13w7', 'ch13w8', 'ch13w9', 'ch13w10', 'ch13w11', 'ch13w12', 'ch13w13', 'ch13w14', 'ch13w15', 'ch14w1', 'ch14w2', 'ch14w3', 'ch14w4', 'ch14w5', 'ch14w6', 'ch14w7', 'ch14w8', 'ch14w9', 'ch14w10', 'ch14w11', 'ch14w12', 'ch14w13', 'ch14w14', 'ch14w15', 'ch15w1', 'ch15w2', 'ch15w3', 'ch15w4', 'ch15w5', 'ch15w6', 'ch15w7', 'ch15w8', 'ch15w9', 'ch15w10', 'ch15w11', 'ch15w12', 'ch15w13', 'ch15w14', 'ch15w15', 'ch16w1', 'ch16w2', 'ch16w3', 'ch16w4', 'ch16w5', 'ch16w6', 'ch16w7', 'ch16w8', 'ch16w9', 'ch16w10', 'ch16w11', 'ch16w12', 'ch16w13', 'ch16w14', 'ch16w15', 'ch17w1', 'ch17w2', 'ch17w3', 'ch17w4', 'ch17w5', 'ch17w6', 'ch17w7', 'ch17w8', 'ch17w9', 'ch17w10', 'ch17w11', 'ch17w12', 'ch17w13', 'ch17w14', 'ch17w15', 'ch18w1', 'ch18w2', 'ch18w3', 'ch18w4', 'ch18w5', 'ch18w6', 'ch18w7', 'ch18w8', 'ch18w9', 'ch18w10', 'ch18w11', 'ch18w12', 'ch18w13', 'ch18w14', 'ch18w15', 'ch19w1', 'ch19w2', 'ch19w3', 'ch19w4', 'ch19w5', 'ch19w6', 'ch19w7', 'ch19w8', 'ch19w9', 'ch19w10', 'ch19w11', 'ch19w12', 'ch19w13', 'ch19w14', 'ch19w15', 'ch20w1', 'ch20w2', 'ch20w3', 'ch20w4', 'ch20w5', 'ch20w6', 'ch20w7', 'ch20w8', 'ch20w9', 'ch20w10', 'ch20w11', 'ch20w12', 'ch20w13', 'ch20w14', 'ch20w15', 'ch21w1', 'ch21w2', 'ch21w3', 'ch21w4', 'ch21w5', 'ch21w6', 'ch21w7', 'ch21w8', 'ch21w9', 'ch21w10', 'ch21w11', 'ch21w12', 'ch21w13', 'ch21w14', 'ch21w15', 'ch22w1', 'ch22w2', 'ch22w3', 'ch22w4', 'ch22w5', 'ch22w6', 'ch22w7', 'ch22w8', 'ch22w9', 'ch22w10', 'ch22w11', 'ch22w12', 'ch22w13', 'ch22w14', 'ch22w15'};
    predictorNames = predictor_names;
    predictors = inputTable(:, predictorNames);
    response = inputTable.Label;
    %isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
    isCategoricalPredictor = repmat(false, 1, length(predictorNames));
    
    % Apply a PCA to the predictor matrix.
    % Run PCA on numeric predictors only. Categorical predictors are passed through PCA untouched.
    isCategoricalPredictorBeforePCA = isCategoricalPredictor;
    numericPredictors = predictors(:, ~isCategoricalPredictor);
    numericPredictors = table2array(varfun(@double, numericPredictors));
    % 'inf' values have to be treated as missing data for PCA.
    numericPredictors(isinf(numericPredictors)) = NaN;
    [pcaCoefficients, pcaScores, ~, ~, explained, pcaCenters] = pca(...
        numericPredictors);
    % Keep enough components to explain the desired amount of variance.
    explainedVarianceToKeepAsFraction = 99/100;
    numComponentsToKeep = find(cumsum(explained)/sum(explained) >= explainedVarianceToKeepAsFraction, 1);
    pcaCoefficients = pcaCoefficients(:,1:numComponentsToKeep);
    predictors = [array2table(pcaScores(:,1:numComponentsToKeep)), predictors(:, isCategoricalPredictor)];
    isCategoricalPredictor = [false(1,numComponentsToKeep), true(1,sum(isCategoricalPredictor))];
    
    % Train a classifier
    % This code specifies all the classifier options and trains the classifier.
    classificationDiscriminant = fitcdiscr(...
        predictors, ...
        response, ...
        'DiscrimType', 'linear', ...
        'Gamma', 0, ...
        'FillCoeffs', 'off', ...
        'ClassNames', [class_names(1,:); class_names(2,:)]);
    
    % Create the result struct with predict function
    predictorExtractionFcn = @(t) t(:, predictorNames);
    pcaTransformationFcn = @(x) [ array2table((table2array(varfun(@double, x(:, ~isCategoricalPredictorBeforePCA))) - pcaCenters) * pcaCoefficients), x(:,isCategoricalPredictorBeforePCA) ];
    discriminantPredictFcn = @(x) predict(classificationDiscriminant, x);
    trainedClassifier.predictFcn = @(x) discriminantPredictFcn(pcaTransformationFcn(predictorExtractionFcn(x)));
    
    % Add additional fields to the result struct
    %trainedClassifier.RequiredVariables = {'ch1w1', 'ch1w2', 'ch1w3', 'ch1w4', 'ch1w5', 'ch1w6', 'ch1w7', 'ch1w8', 'ch1w9', 'ch1w10', 'ch1w11', 'ch1w12', 'ch1w13', 'ch1w14', 'ch1w15', 'ch2w1', 'ch2w2', 'ch2w3', 'ch2w4', 'ch2w5', 'ch2w6', 'ch2w7', 'ch2w8', 'ch2w9', 'ch2w10', 'ch2w11', 'ch2w12', 'ch2w13', 'ch2w14', 'ch2w15', 'ch3w1', 'ch3w2', 'ch3w3', 'ch3w4', 'ch3w5', 'ch3w6', 'ch3w7', 'ch3w8', 'ch3w9', 'ch3w10', 'ch3w11', 'ch3w12', 'ch3w13', 'ch3w14', 'ch3w15', 'ch4w1', 'ch4w2', 'ch4w3', 'ch4w4', 'ch4w5', 'ch4w6', 'ch4w7', 'ch4w8', 'ch4w9', 'ch4w10', 'ch4w11', 'ch4w12', 'ch4w13', 'ch4w14', 'ch4w15', 'ch5w1', 'ch5w2', 'ch5w3', 'ch5w4', 'ch5w5', 'ch5w6', 'ch5w7', 'ch5w8', 'ch5w9', 'ch5w10', 'ch5w11', 'ch5w12', 'ch5w13', 'ch5w14', 'ch5w15', 'ch6w1', 'ch6w2', 'ch6w3', 'ch6w4', 'ch6w5', 'ch6w6', 'ch6w7', 'ch6w8', 'ch6w9', 'ch6w10', 'ch6w11', 'ch6w12', 'ch6w13', 'ch6w14', 'ch6w15', 'ch7w1', 'ch7w2', 'ch7w3', 'ch7w4', 'ch7w5', 'ch7w6', 'ch7w7', 'ch7w8', 'ch7w9', 'ch7w10', 'ch7w11', 'ch7w12', 'ch7w13', 'ch7w14', 'ch7w15', 'ch8w1', 'ch8w2', 'ch8w3', 'ch8w4', 'ch8w5', 'ch8w6', 'ch8w7', 'ch8w8', 'ch8w9', 'ch8w10', 'ch8w11', 'ch8w12', 'ch8w13', 'ch8w14', 'ch8w15', 'ch9w1', 'ch9w2', 'ch9w3', 'ch9w4', 'ch9w5', 'ch9w6', 'ch9w7', 'ch9w8', 'ch9w9', 'ch9w10', 'ch9w11', 'ch9w12', 'ch9w13', 'ch9w14', 'ch9w15', 'ch10w1', 'ch10w2', 'ch10w3', 'ch10w4', 'ch10w5', 'ch10w6', 'ch10w7', 'ch10w8', 'ch10w9', 'ch10w10', 'ch10w11', 'ch10w12', 'ch10w13', 'ch10w14', 'ch10w15', 'ch11w1', 'ch11w2', 'ch11w3', 'ch11w4', 'ch11w5', 'ch11w6', 'ch11w7', 'ch11w8', 'ch11w9', 'ch11w10', 'ch11w11', 'ch11w12', 'ch11w13', 'ch11w14', 'ch11w15', 'ch12w1', 'ch12w2', 'ch12w3', 'ch12w4', 'ch12w5', 'ch12w6', 'ch12w7', 'ch12w8', 'ch12w9', 'ch12w10', 'ch12w11', 'ch12w12', 'ch12w13', 'ch12w14', 'ch12w15', 'ch13w1', 'ch13w2', 'ch13w3', 'ch13w4', 'ch13w5', 'ch13w6', 'ch13w7', 'ch13w8', 'ch13w9', 'ch13w10', 'ch13w11', 'ch13w12', 'ch13w13', 'ch13w14', 'ch13w15', 'ch14w1', 'ch14w2', 'ch14w3', 'ch14w4', 'ch14w5', 'ch14w6', 'ch14w7', 'ch14w8', 'ch14w9', 'ch14w10', 'ch14w11', 'ch14w12', 'ch14w13', 'ch14w14', 'ch14w15', 'ch15w1', 'ch15w2', 'ch15w3', 'ch15w4', 'ch15w5', 'ch15w6', 'ch15w7', 'ch15w8', 'ch15w9', 'ch15w10', 'ch15w11', 'ch15w12', 'ch15w13', 'ch15w14', 'ch15w15', 'ch16w1', 'ch16w2', 'ch16w3', 'ch16w4', 'ch16w5', 'ch16w6', 'ch16w7', 'ch16w8', 'ch16w9', 'ch16w10', 'ch16w11', 'ch16w12', 'ch16w13', 'ch16w14', 'ch16w15', 'ch17w1', 'ch17w2', 'ch17w3', 'ch17w4', 'ch17w5', 'ch17w6', 'ch17w7', 'ch17w8', 'ch17w9', 'ch17w10', 'ch17w11', 'ch17w12', 'ch17w13', 'ch17w14', 'ch17w15', 'ch18w1', 'ch18w2', 'ch18w3', 'ch18w4', 'ch18w5', 'ch18w6', 'ch18w7', 'ch18w8', 'ch18w9', 'ch18w10', 'ch18w11', 'ch18w12', 'ch18w13', 'ch18w14', 'ch18w15', 'ch19w1', 'ch19w2', 'ch19w3', 'ch19w4', 'ch19w5', 'ch19w6', 'ch19w7', 'ch19w8', 'ch19w9', 'ch19w10', 'ch19w11', 'ch19w12', 'ch19w13', 'ch19w14', 'ch19w15', 'ch20w1', 'ch20w2', 'ch20w3', 'ch20w4', 'ch20w5', 'ch20w6', 'ch20w7', 'ch20w8', 'ch20w9', 'ch20w10', 'ch20w11', 'ch20w12', 'ch20w13', 'ch20w14', 'ch20w15', 'ch21w1', 'ch21w2', 'ch21w3', 'ch21w4', 'ch21w5', 'ch21w6', 'ch21w7', 'ch21w8', 'ch21w9', 'ch21w10', 'ch21w11', 'ch21w12', 'ch21w13', 'ch21w14', 'ch21w15', 'ch22w1', 'ch22w2', 'ch22w3', 'ch22w4', 'ch22w5', 'ch22w6', 'ch22w7', 'ch22w8', 'ch22w9', 'ch22w10', 'ch22w11', 'ch22w12', 'ch22w13', 'ch22w14', 'ch22w15'};
    trainedClassifier.RequiredVariables = predictor_names;
    trainedClassifier.PCACenters = pcaCenters;
    trainedClassifier.PCACoefficients = pcaCoefficients;
    trainedClassifier.ClassificationDiscriminant = classificationDiscriminant;
    trainedClassifier.About = 'This struct is a trained model exported from Classification Learner R2017b.';
    trainedClassifier.HowToPredict = sprintf('To make predictions on a new table, T, use: \n  yfit = c.predictFcn(T) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nThe table, T, must contain the variables returned by: \n  c.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype) must match the original training data. \nAdditional variables are ignored. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appclassification_exportmodeltoworkspace'')">How to predict using an exported model</a>.');
    
    % Extract predictors and response
    % This code processes the data into the right shape for training the
    % model.
    inputTable = trainingData;
    %predictorNames = {'ch1w1', 'ch1w2', 'ch1w3', 'ch1w4', 'ch1w5', 'ch1w6', 'ch1w7', 'ch1w8', 'ch1w9', 'ch1w10', 'ch1w11', 'ch1w12', 'ch1w13', 'ch1w14', 'ch1w15', 'ch2w1', 'ch2w2', 'ch2w3', 'ch2w4', 'ch2w5', 'ch2w6', 'ch2w7', 'ch2w8', 'ch2w9', 'ch2w10', 'ch2w11', 'ch2w12', 'ch2w13', 'ch2w14', 'ch2w15', 'ch3w1', 'ch3w2', 'ch3w3', 'ch3w4', 'ch3w5', 'ch3w6', 'ch3w7', 'ch3w8', 'ch3w9', 'ch3w10', 'ch3w11', 'ch3w12', 'ch3w13', 'ch3w14', 'ch3w15', 'ch4w1', 'ch4w2', 'ch4w3', 'ch4w4', 'ch4w5', 'ch4w6', 'ch4w7', 'ch4w8', 'ch4w9', 'ch4w10', 'ch4w11', 'ch4w12', 'ch4w13', 'ch4w14', 'ch4w15', 'ch5w1', 'ch5w2', 'ch5w3', 'ch5w4', 'ch5w5', 'ch5w6', 'ch5w7', 'ch5w8', 'ch5w9', 'ch5w10', 'ch5w11', 'ch5w12', 'ch5w13', 'ch5w14', 'ch5w15', 'ch6w1', 'ch6w2', 'ch6w3', 'ch6w4', 'ch6w5', 'ch6w6', 'ch6w7', 'ch6w8', 'ch6w9', 'ch6w10', 'ch6w11', 'ch6w12', 'ch6w13', 'ch6w14', 'ch6w15', 'ch7w1', 'ch7w2', 'ch7w3', 'ch7w4', 'ch7w5', 'ch7w6', 'ch7w7', 'ch7w8', 'ch7w9', 'ch7w10', 'ch7w11', 'ch7w12', 'ch7w13', 'ch7w14', 'ch7w15', 'ch8w1', 'ch8w2', 'ch8w3', 'ch8w4', 'ch8w5', 'ch8w6', 'ch8w7', 'ch8w8', 'ch8w9', 'ch8w10', 'ch8w11', 'ch8w12', 'ch8w13', 'ch8w14', 'ch8w15', 'ch9w1', 'ch9w2', 'ch9w3', 'ch9w4', 'ch9w5', 'ch9w6', 'ch9w7', 'ch9w8', 'ch9w9', 'ch9w10', 'ch9w11', 'ch9w12', 'ch9w13', 'ch9w14', 'ch9w15', 'ch10w1', 'ch10w2', 'ch10w3', 'ch10w4', 'ch10w5', 'ch10w6', 'ch10w7', 'ch10w8', 'ch10w9', 'ch10w10', 'ch10w11', 'ch10w12', 'ch10w13', 'ch10w14', 'ch10w15', 'ch11w1', 'ch11w2', 'ch11w3', 'ch11w4', 'ch11w5', 'ch11w6', 'ch11w7', 'ch11w8', 'ch11w9', 'ch11w10', 'ch11w11', 'ch11w12', 'ch11w13', 'ch11w14', 'ch11w15', 'ch12w1', 'ch12w2', 'ch12w3', 'ch12w4', 'ch12w5', 'ch12w6', 'ch12w7', 'ch12w8', 'ch12w9', 'ch12w10', 'ch12w11', 'ch12w12', 'ch12w13', 'ch12w14', 'ch12w15', 'ch13w1', 'ch13w2', 'ch13w3', 'ch13w4', 'ch13w5', 'ch13w6', 'ch13w7', 'ch13w8', 'ch13w9', 'ch13w10', 'ch13w11', 'ch13w12', 'ch13w13', 'ch13w14', 'ch13w15', 'ch14w1', 'ch14w2', 'ch14w3', 'ch14w4', 'ch14w5', 'ch14w6', 'ch14w7', 'ch14w8', 'ch14w9', 'ch14w10', 'ch14w11', 'ch14w12', 'ch14w13', 'ch14w14', 'ch14w15', 'ch15w1', 'ch15w2', 'ch15w3', 'ch15w4', 'ch15w5', 'ch15w6', 'ch15w7', 'ch15w8', 'ch15w9', 'ch15w10', 'ch15w11', 'ch15w12', 'ch15w13', 'ch15w14', 'ch15w15', 'ch16w1', 'ch16w2', 'ch16w3', 'ch16w4', 'ch16w5', 'ch16w6', 'ch16w7', 'ch16w8', 'ch16w9', 'ch16w10', 'ch16w11', 'ch16w12', 'ch16w13', 'ch16w14', 'ch16w15', 'ch17w1', 'ch17w2', 'ch17w3', 'ch17w4', 'ch17w5', 'ch17w6', 'ch17w7', 'ch17w8', 'ch17w9', 'ch17w10', 'ch17w11', 'ch17w12', 'ch17w13', 'ch17w14', 'ch17w15', 'ch18w1', 'ch18w2', 'ch18w3', 'ch18w4', 'ch18w5', 'ch18w6', 'ch18w7', 'ch18w8', 'ch18w9', 'ch18w10', 'ch18w11', 'ch18w12', 'ch18w13', 'ch18w14', 'ch18w15', 'ch19w1', 'ch19w2', 'ch19w3', 'ch19w4', 'ch19w5', 'ch19w6', 'ch19w7', 'ch19w8', 'ch19w9', 'ch19w10', 'ch19w11', 'ch19w12', 'ch19w13', 'ch19w14', 'ch19w15', 'ch20w1', 'ch20w2', 'ch20w3', 'ch20w4', 'ch20w5', 'ch20w6', 'ch20w7', 'ch20w8', 'ch20w9', 'ch20w10', 'ch20w11', 'ch20w12', 'ch20w13', 'ch20w14', 'ch20w15', 'ch21w1', 'ch21w2', 'ch21w3', 'ch21w4', 'ch21w5', 'ch21w6', 'ch21w7', 'ch21w8', 'ch21w9', 'ch21w10', 'ch21w11', 'ch21w12', 'ch21w13', 'ch21w14', 'ch21w15', 'ch22w1', 'ch22w2', 'ch22w3', 'ch22w4', 'ch22w5', 'ch22w6', 'ch22w7', 'ch22w8', 'ch22w9', 'ch22w10', 'ch22w11', 'ch22w12', 'ch22w13', 'ch22w14', 'ch22w15'};
    predictorNames = predictor_names;
    predictors = inputTable(:, predictorNames);
    response = inputTable.Label;
    %isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
    isCategoricalPredictor = repmat(false, 1, length(predictorNames));
    
    % Perform cross-validation
    KFolds = 10;
    cvp = cvpartition(response, 'KFold', KFolds);
    % Initialize the predictions to the proper sizes
    validationPredictions = response;
    numObservations = size(predictors, 1);
    numClasses = 2;
    validationScores = NaN(numObservations, numClasses);
    for fold = 1:KFolds
        trainingPredictors = predictors(cvp.training(fold), :);
        trainingResponse = response(cvp.training(fold), :);
        foldIsCategoricalPredictor = isCategoricalPredictor;
        
        % Apply a PCA to the predictor matrix.
        % Run PCA on numeric predictors only. Categorical predictors are passed through PCA untouched.
        isCategoricalPredictorBeforePCA = foldIsCategoricalPredictor;
        numericPredictors = trainingPredictors(:, ~foldIsCategoricalPredictor);
        numericPredictors = table2array(varfun(@double, numericPredictors));
        % 'inf' values have to be treated as missing data for PCA.
        numericPredictors(isinf(numericPredictors)) = NaN;
        [pcaCoefficients, pcaScores, ~, ~, explained, pcaCenters] = pca(numericPredictors);
        % Keep enough components to explain the desired amount of variance.
        explainedVarianceToKeepAsFraction = 99/100;
        numComponentsToKeep = find(cumsum(explained)/sum(explained) >= explainedVarianceToKeepAsFraction, 1);
        pcaCoefficients = pcaCoefficients(:,1:numComponentsToKeep);
        trainingPredictors = [array2table(pcaScores(:,1:numComponentsToKeep)), trainingPredictors(:, foldIsCategoricalPredictor)];
        foldIsCategoricalPredictor = [false(1,numComponentsToKeep), true(1,sum(foldIsCategoricalPredictor))];
        
        % Train a classifier
        % This code specifies all the classifier options and trains the classifier.
        classificationDiscriminant = fitcdiscr(...
            trainingPredictors, ...
            trainingResponse, ...
            'DiscrimType', 'linear', ...
            'Gamma', 0, ...
            'FillCoeffs', 'off', ...
            'ClassNames', [class_names(1,:); class_names(2,:)]);
        
        % Create the result struct with predict function
        pcaTransformationFcn = @(x) [ array2table((table2array(varfun(@double, x(:, ~isCategoricalPredictorBeforePCA))) - pcaCenters) * pcaCoefficients), x(:,isCategoricalPredictorBeforePCA) ];
        discriminantPredictFcn = @(x) predict(classificationDiscriminant, x);
        validationPredictFcn = @(x) discriminantPredictFcn(pcaTransformationFcn(x));
        
        % Add additional fields to the result struct
        
        % Compute validation predictions
        validationPredictors = predictors(cvp.test(fold), :);
        [foldPredictions, foldScores] = validationPredictFcn(validationPredictors);
        
        % Store predictions in the original order
        validationPredictions(cvp.test(fold), :) = foldPredictions;
        validationScores(cvp.test(fold), :) = foldScores;
       
        %% compute performance for every iteration
        % check which predictions match the responses 
        correctPredictions = all(foldPredictions == response(cvp.test(fold),:), 2); 
        % and compute accuracy 
        validationAccuracy = sum(correctPredictions)/length(correctPredictions);
        kfold_accuracies(fold) = validationAccuracy;
        
        % also compute AUC
        diff_score = foldScores(:,1) - foldScores(:,2);
        [~,~,~,kfold_auc(fold),~]  = perfcurve(response(cvp.test(fold),:), diff_score, class_names(1,:));
    end
    
    % Compute validation accuracy
    % TP + TN
    correctPredictions = all(validationPredictions == response, 2);
    isMissing = all(isspace(response), 2);
    correctPredictions = correctPredictions(~isMissing, :);
    % (TP + TN) / (TP+TN+FP+FN) (--> all)
    validationAccuracy = sum(correctPredictions)/length(response); %/length(correctPredictions): this was sensitivity, not accuracy
    disp(['all = ', num2str(mean(kfold_accuracies)), ' validationAcc = ', num2str(validationAccuracy)]);
    
    % get overall AUC in addition to accuracy
    diff_score = validationScores(:,1) - validationScores(:,2);
    [~,~,~,AUC,~]  = perfcurve(response, diff_score, class_names(1,:));