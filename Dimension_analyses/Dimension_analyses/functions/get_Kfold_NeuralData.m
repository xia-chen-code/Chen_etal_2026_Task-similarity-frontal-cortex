function [TrainData, TestData] = get_Kfold_NeuralData(NeuralData, Kfold)

% INPUT:
%       NeuralData: Neural activity, cell array:{s sessions × c conditions} (n neurons × t trials)
%            Kfold: Number of folds for cross-validation
% OUTPUT:
%   TrainData, TestData:
%       Trial-averaged, session-concatenated neural activity (conditions × units × Kfold)

TrainData = cell([size(NeuralData'),Kfold]); % --> {condition * sessions}
TestData = TrainData;

for iCond = 1:size(NeuralData,2)
    for iSess = 1:size(NeuralData,1)
        
        Data = NeuralData{iSess,iCond};
        n_trial = size(Data,2);
        indices = crossvalind('Kfold', n_trial, Kfold);  % Generate K-fold indices

        for iFold = 1:Kfold % cross-validation
            % Split data into training and test sets
            testIdx = (indices == iFold);  % Test set for current fold
            trainIdx = ~testIdx;          % Training set for current fold

            % Calculate mean activity on training set and test set
            meanTrainData = mean(Data(:, trainIdx), 2); % units * 1
            meanTestData = mean(Data(:, testIdx), 2); % % units * 1

            TrainData{iCond,iSess,iFold} = meanTrainData';
            TestData{iCond,iSess,iFold} = meanTestData';
        end
    end
end
TrainData = cell2mat(TrainData);
TestData = cell2mat(TestData);

end
