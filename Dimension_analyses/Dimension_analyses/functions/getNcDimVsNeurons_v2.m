function CStarArray = getNcDimVsNeurons_v2(NeuralData, numNeuronsList, Kfold, Repeats)
    % Compute Nc and dimensionality as the number of neurons changes
    % Updates in v2: 
    % - DO NOT concatenate NeuralData across sessions.
    % - Use more trials for training set and test set.

    % Updates in v3:
    % - Matching proportions of neuron types.

    % INPUT:
    %       NeuralData: Neural activity, cell array:{s sessions × c conditions} (n neurons × t trials)
    %   numNeuronsList: List of neuron counts to evaluate (e.g., 50 to N neurons)
    %            Kfold: Number of folds for cross-validation
    %          Repeats: Number of repeats for sampling neurons

    % Xia Chen (2024)

    NeuronTag = getNeuronTag(NeuralData);

    N = size(NeuronTag,1);  % Get number of neurons
    c = size(NeuralData,2); % conditions
     
    CStarArray = nan(Repeats,length(numNeuronsList));  % Store c_star for each neuron count

    h=waitbar(0,'Calculate Dimensionality');
    for iN = 1:length(numNeuronsList)
        waitbar(iN/length(numNeuronsList));
        numNeurons = numNeuronsList(iN);  % Current neuron count

        for iR = 1:Repeats
            % Subsample neurons randomly
            sampledId = NeuronTag(randperm(N, numNeurons), :);
            sessId = unique(sampledId(:,1));
            sampledNeuralData = cell(numel(sessId),c);
            for i = 1:c
                sampledNeuralData(:,i) = arrayfun(@(x) NeuralData{x,i}(sampledId(sampledId(:,1)==x,2),:), sessId, 'UniformOutput', false);
            end

            % Compute dimensionality and Nc using cross-validation for the current neuron subset
            CStarArray(iR, iN) = computeDimCStar_v2(sampledNeuralData, Kfold, 0.25);

        end

    end
    close(h)
end