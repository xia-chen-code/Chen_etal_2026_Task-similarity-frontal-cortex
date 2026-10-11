function NeuronTag = getNeuronTag(NeuralData)

% Get each neuron's SessId and CellId in NeuralData.
% NeuralData: {s sessions * c conditions} (n neurons * t trials)
% Xia Chen (2024)

NeuronTag = cell(size(NeuralData,1),1);
for iSess = 1:size(NeuralData,1)
    nUnit = size(NeuralData{iSess,1},1);
    NeuronTag{iSess} = [repmat(iSess,[nUnit, 1]) (1:nUnit)']; % [SessId CellId]
end
NeuronTag = cell2mat(NeuronTag);  % [SessId CellId]

end