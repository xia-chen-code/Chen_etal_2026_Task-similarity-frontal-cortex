function [DireTac, DireAud, MD, PSTHset_test] = ...
    func_Dire_randsample(PSTHs, Trials, TimeA, nBoot, TaskTag, normalizeDire, ProbTrain, TriN)
% variant of 'func_Dire_Areas_cvpartition', only for single brain area analysis
% Using randsample to set traing set and test set
% get all the activity directions: selective, non-selective ramping
% For single session, single brain area recording

%% get training set and test set
BalanceTrial = 0;
TrialType = {'TLC','TRC','TLE','TRE','ALC','ARC','ALE','ARE'};
nType = numel(TrialType);
[TrialsId, ~] = fun_GetTrialPool(Trials, TrialType, BalanceTrial);
PSTHset = cellfun(@(x) PSTHs(:,:,x),TrialsId, 'UniformOutput', false); % each cell is one trial type

%% Get direction: each direction is one row vector
DireTac = struct; 
DireAud = struct; 
MD = nan(nBoot, size(PSTHs,1));
PSTHset_test = cell(1,nBoot);

for iBoot = 1:nBoot
    rng(iBoot);
    [TrainId,TestId] = cellfun(@(x) setTrainTestTrials_half(x, ProbTrain, TriN, 0), TrialsId, 'UniformOutput',false);

    % === ID: sitmulus intensity direction === strong - weak
    [DireTac.ID(iBoot,:), DireAud.ID(iBoot,:)] = func_MeanDiffDire_Fold('ID', [0 1], PSTHset, TrainId, TimeA, TaskTag, normalizeDire);

    % === CD: choice direction /or/ AD: action direction === CR,EL - CL,ER
    [DireTac.CD(iBoot,:), DireAud.CD(iBoot,:)] = func_MeanDiffDire_Fold('CD', [1 2], PSTHset, TrainId, TimeA, TaskTag, normalizeDire);

    [DireTac.AD(iBoot,:), DireAud.AD(iBoot,:)] = func_MeanDiffDire_Fold('AD', [2 2.3], PSTHset, TrainId, TimeA, TaskTag, normalizeDire);

    % === OD: outcome direction === correct - error
    [DireTac.OD(iBoot,:), DireAud.OD(iBoot,:)] = func_MeanDiffDire_Fold('OD', [2 3], PSTHset, TrainId, TimeA, TaskTag, normalizeDire);

    % Ramping mode
    [DireTac.RM(iBoot,:), DireAud.RM(iBoot,:)] = func_NSDire_Fold([-0.5 0], [1.5 2], PSTHset, TrainId, TimeA, normalizeDire);

    % Go mode
    [DireTac.GM(iBoot,:), DireAud.GM(iBoot,:)] = func_NSDire_Fold([1.9 2], [2 2.1], PSTHset, TrainId, TimeA, normalizeDire);
    
    % Modality mode 
    MD(iBoot,:) = func_MD_Fold([-1 -0.2], PSTHset, TrainId, TimeA, normalizeDire);
    
    % PSTHs of test set {iFold} {Trial type} (units x time x trials) 
    PSTHset_test{iBoot} = arrayfun(@(x) PSTHset{x}(:,:,TestId{x}),1:nType,'UniformOutput', false);
end

    