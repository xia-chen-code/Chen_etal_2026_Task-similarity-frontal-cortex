function CStarArray = getNcDimVsNeurons_v3(NeuralData, UnitId_inLMX, numNeuronsList, Kfold, Repeats, varargin)
    % Compute Nc and dimensionality as the number of neurons changes
    % Updates in v2: 
    % - DO NOT concatenate NeuralData across sessions.
    % - Use more trials for training set and test set.

    % Updates in v3:
    % - Matching proportions of neuron types.
    % - Added an optional input argument, lmx_prop_Adjusted. If provided, the proportions are matched to this specified array.

    % INPUT:
    %       NeuralData: Neural activity, cell array:{s sessions × c conditions} (n neurons × t trials)
    %   numNeuronsList: List of neuron counts to evaluate (e.g., 50 to N neurons)
    %            Kfold: Number of folds for cross-validation
    %          Repeats: Number of repeats for sampling neurons
    %     UnitId_inLMX: {NonLinMixed, Pure, LinMixed, NonS}

    % Xia Chen (2024)

    p = inputParser;
    p.addParameter('lmx_prop_Adjusted' , [] , @(x) isnumeric(x) );
    p.parse(varargin{:});
    lmx_prop = p.Results.lmx_prop_Adjusted;

    NeuronTag_LMX = cellfun(@(x) GetLMX_NeuronTag(x),UnitId_inLMX','UniformOutput',false);

    % Calculate proportions of each type of neurons
    lmxN_array = cellfun(@(x) size(x,1),NeuronTag_LMX);
    if isempty(lmx_prop) % use the original population size and proportions
        N = sum(lmxN_array);  % Get number of neurons
        lmx_prop = lmxN_array/N;
    end

    TypeN = numel(lmxN_array); % number of types of units
    c = size(NeuralData,2); % conditions

    CStarArray = nan(Repeats,length(numNeuronsList));  % Store c_star for each neuron count

    h=waitbar(0,'Calculate Dimensionality');
    for iN = 1:length(numNeuronsList)
        waitbar(iN/length(numNeuronsList));
        numNeurons = numNeuronsList(iN);  % Current neuron count
        sampleN_array = round(numNeurons*lmx_prop);
        if sum(sampleN_array)~=numNeurons
            sampleN_array(end) = numNeurons-sum(sampleN_array(1:end-1));
        end
        
        for iR = 1:Repeats
            rng(iR);
            % Subsample neurons randomly
            sampledId_LMX = arrayfun(@(x) randsampling_selfcheck(lmxN_array(x),sampleN_array(x)),1:TypeN, 'UniformOutput', false);
            sampledTag_LMX = arrayfun(@(x) NeuronTag_LMX{x}(sampledId_LMX{x},:),1:TypeN, 'UniformOutput', false);
            sampledTag_LMX = cell2mat(sampledTag_LMX');

            sessId = unique(sampledTag_LMX(:,1));
            sampledNeuralData = cell(numel(sessId),c);
            for i = 1:c
                sampledNeuralData(:,i) = arrayfun(@(x) NeuralData{x,i}(sampledTag_LMX(sampledTag_LMX(:,1)==x,2),:), sessId, 'UniformOutput', false);
            end

            % Compute dimensionality and Nc using cross-validation for the current neuron subset
            CStarArray(iR, iN) = computeDimCStar_v2(sampledNeuralData, Kfold, 0.25);

        end

    end
    close(h)

    function sampleId = randsampling_selfcheck(popu_size, sample_size)
        if popu_size >= sample_size
            sampleId = randsample(popu_size, sample_size);
        else % typically not happened
            sampleId = [1:popu_size randsample(sample_size-popu_size, sample_size)];
        end
    end
end