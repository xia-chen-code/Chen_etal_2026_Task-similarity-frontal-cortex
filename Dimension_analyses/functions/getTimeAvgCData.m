function NeuralData = getTimeAvgCData(PSTHs, Trials, Units, TimeA, CellFilter, TrialsThrC, TimeDim, UnifySess)
% INPUT: 
%     TimeDim: [start end] time window for averaging PSTHs
%   UnifySess: = 1: Match the number of trials across all sessions for each trial type
%              = 0: Retain all trials from each session.

% OUTPUT:
%   NeuralData: single-session time-averaged neural data (different structure based on UnifySess).

% Xia Chen (2024)

CellId = func_LiteCellFilter(Units,CellFilter);
timeidx =  TimeA.time>=TimeDim(1) & TimeA.time<TimeDim(2);
TrialsId = cellfun(@(x) intersect(Trials.(x), Trials.StableTrials), {'TLC','TRC','ALC','ARC'}, 'UniformOutput', false);

if UnifySess == 1 % all sessions have the same number of trials
    TrialsId = cellfun(@(x) sort(randsample(x,TrialsThrC)),TrialsId, 'UniformOutput', false);
    PSTHset = cellfun(@(x) mean(PSTHs(CellId,timeidx,x),2),TrialsId, 'UniformOutput', false); 
    % Generate NeuralData: matrix with dimensions:  n neurons × c conditions × t trials
    NeuralData = cell2mat(PSTHset); % Concatenate sessions
else
    PSTHset = cellfun(@(x) squeeze(mean(PSTHs(CellId,timeidx,x),2)),TrialsId, 'UniformOutput', false); 
    % Generate NeuralData: cell array (1 × c conditions).
    % Each cell contains a matrix with dimensions: n neurons × t trials.
    NeuralData = PSTHset; 
end