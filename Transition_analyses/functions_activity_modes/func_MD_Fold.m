function MD = func_MD_Fold(timewin, PSTHset, TrainId, TimeA, normalizeDire)
% get modality mode for single session

timeidx =  TimeA.time>=timewin(1) & TimeA.time<timewin(2);
% get averaged psth for compute direction, average over trial then over time
TrainPSTHforDire = arrayfun(@(x) mean(mean(PSTHset{x}(:,timeidx,TrainId{x}),3),2), 1:8, 'UniformOutput', false);

% modality mode 
MD = mean(cell2mat(TrainPSTHforDire(1:4)),2) - mean(cell2mat(TrainPSTHforDire(5:6)),2); % units x 1

% transpose to row vector
if normalizeDire == 1
    MD  = normalize(MD','norm',2);
else
    MD = MD';
end