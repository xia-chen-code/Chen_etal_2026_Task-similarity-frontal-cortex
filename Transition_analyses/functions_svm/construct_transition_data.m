function [PSTHsL, PSTHsR, TrialLb_Left, TrialLb_Right, LeftVTags, RightVTags] = construct_transition_data (PSTHs, ProjTime, TimeA, Trials, ExcludeOpto, ExcludeBadTrialsV, Offset,varargin)
% Aligned left and right trials to transition
% Output:
% PSTHsL, PSTHsR: aligned psth:  (SelectedTrials x Units x time)

% Input:
% PSTHs: units x time x trials (original data)
% Trials: label and id of trials
% ExcludeOpto: exclude optogenetic trials or not
% ExcludeBadTrialsV: exclude BadTrialsV or not

% set parameters
p = inputParser;
p.addParameter('ExcludeNoResp' , 0 , @(x) isnumeric(x) );
p.addParameter('ExcludePreLick' , 0 , @(x) isnumeric(x) );
p.parse(varargin{:});
ExcludeNoResp = p.Results.ExcludeNoResp;
ExcludePreLick = p.Results.ExcludePreLick;

[StableLeftBefore, StableLeftAfter, StableRightBefore, StableRightAfter] = ...
    func_GetTrialsTransition(Trials, ExcludeOpto, ExcludeBadTrialsV,'ExcludeNoResp',ExcludeNoResp,'ExcludePreLick',ExcludePreLick);
% length of left and right trials before/after are not necessarily matched is this script

% Trial Label aligned to transition
TrialLb_Left = -numel(StableLeftBefore):numel(StableLeftAfter)-1;
TrialLb_Right = -numel(StableRightBefore):numel(StableRightAfter)-1;

% for single trial projection, average psth in the ProjTime
timeid = TimeA.time>=ProjTime(1) & TimeA.time<ProjTime(2);

PSTHsL = PSTHs(:, timeid, [StableLeftBefore StableLeftAfter]);
PSTHsR = PSTHs(:, timeid, [StableRightBefore StableRightAfter]);

if Offset == 1 % subtract baseline (presample), the offset is trial-by-trial
    time_offset = [-1.5 -0.1];
    timeid_offset = TimeA.time>=time_offset(1) & TimeA.time<time_offset(2);
    ntime = numel(find(timeid));
    PSTHsL = PSTHsL- repmat(mean(PSTHs(:, timeid_offset, [StableLeftBefore StableLeftAfter]),2),[1,ntime,1]);
    PSTHsR = PSTHsR - repmat(mean(PSTHs(:, timeid_offset, [StableRightBefore StableRightAfter]),2),[1,ntime,1]);
end

PSTHsL = permute(PSTHsL,[3 1 2]);
PSTHsR = permute(PSTHsR,[3 1 2]);

% trial tag
% remember the correct/error/no-response tag of these trials
LeftVTags = GetTrialTag([StableLeftBefore StableLeftAfter], Trials);
RightVTags = GetTrialTag([StableRightBefore StableRightAfter], Trials);
