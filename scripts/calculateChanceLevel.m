% calculate chance level using the inverse of the binomial cumulative
% distribution function.
% Alpha is the significance level, e.g. 0.001

% taken from Combrisson(2015), "Exceeding Chance Level by Chance"
function [chanceLevel] = calculateChanceLevel(numTrials, classes, alpha)

chanceLevel = binoinv(1-alpha, numTrials, 1/classes)*100/numTrials;

end