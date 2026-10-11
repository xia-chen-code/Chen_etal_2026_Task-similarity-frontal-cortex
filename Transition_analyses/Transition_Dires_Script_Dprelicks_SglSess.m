%% Get directions, test set, transition matrix for each session  
% do not normalize, in order to pool session to get a set of whole-directions (pooling session) for transition analysis later.
% This script exclude pre-licking trials, as the PTSHtime of these trials does not match the task epochs.
TaskTag = 'TAs';
Folder = 'X:\PSTH\SglSess_LeftALM\';
% Folder = 'X:\PSTH\SglSess_RightALM\';

SaveFolder = [Folder 'transition\' TaskTag '_dires_DeletePreLicksNoResp\'];
PSTHFolder = [Folder TaskTag '\'];
Files = dir([PSTHFolder '*mat']);

UnitsThr = 5; % if units number in either areas <= UnitsThr (Threshold), escape this session
TrialsThrC = 8;
TrialsThrE = 6; 
TriN = 6; % min number for test set, sometimes also for train set
ProbTrain = 0.5;

CellFilter.MetricsFRthr = 0.1; % >= 1spikes/s
CellFilter.DepthRange =  [-Inf 1200];%[1200 +inf];
CellFilter.MetricsDur = [0.3 0.9];

normalizeDire = 0; % normalize the direction or not
nBoot = 20; % randsampling 

% For projections of single trials aligned to transition
time_proj = [-1 3];
ExcludeOpto = 1; % exclude optogenetic trials!
ExcludeNoResp = 1;
ExcludeBadTrialsV = 0; % exclude bad trials, but not transition trials
Offset = 0;

%%
h=waitbar(0,'Get direction and transition trials for each session');
for iSess = 1:numel(Files)
    waitbar(iSess/numel(Files));
    disp(['===== Load session' num2str(iSess) ' =====']);
    tic
    % Load simulatenously recorded data.mat
    load([PSTHFolder Files(iSess).name]);

    % re-catch first session type: 1,whisker,2,auditory
    FirSessType = ReCatchFirSessType(Trials);
    if SessInfo.FirSessType ~= FirSessType
        disp('re-catch session type for this session')
        SessInfo.FirSessType = FirSessType;
    end

    % accumulate animal and session label
    SessTag = [SessInfo.Ani SessInfo.Sess SessInfo.FirTransitType SessInfo.FirSessType];

    if SessInfo.FirTransitType==0; continue; end % escape session that are not suitable for transition analysis.

    CellId = func_LiteCellFilter(Units,CellFilter);
    % check units number
    if numel(CellId)<UnitsThr
        disp('Not enough cells'); continue
    end

    % check trial number
    continueTag = func_check_Ntrial(Trials,TrialsThrC,{'TLC','TRC','ALC','ARC'});
    continueTagE = func_check_Ntrial(Trials,TrialsThrE,{'TLE','TRE','ALE','ARE'});
    if continueTag == 1 || continueTagE ==1
        disp('Not enough trials'); continue
    end

    [DireTac, DireAud, MD, PSTHset_test] = ...
    func_Dire_randsample(PSTHs(CellId,:,:), Trials, TimeA, nBoot, TaskTag, normalizeDire, ProbTrain, TriN);

    % construct data (transition trials) for projection % (Trials x Units x time)
    [PSTHsL, PSTHsR, xL, xR, LeftVTags, RightVTags] = ...
        construct_transition_data_Dprelick (PSTHs(CellId,:,:), time_proj, TimeA, Trials, ExcludeOpto, ExcludeBadTrialsV, Offset, 'ExcludeNoResp', ExcludeNoResp);
    toc
    clear PSTHs

    SaveFile = [SaveFolder 'Ani' num2str(SessInfo.Ani) '_Sess' num2str(SessInfo.Sess) '_FirSessType' num2str(SessInfo.FirSessType) '.mat'];
    save(SaveFile,'SessTag', 'TimeA', 'time_proj', 'normalizeDire','CellId', ...
    'DireTac', 'DireAud', 'MD', 'PSTHset_test', ...
    'PSTHsL', 'PSTHsR', 'xL', 'xR', 'LeftVTags', 'RightVTags','ExcludeBadTrialsV')

end
close(h)
