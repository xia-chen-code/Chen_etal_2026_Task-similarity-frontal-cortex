function FirSessType = ReCatchFirSessType(Trials)

% re-catch first session type: 1,whisker,2,auditory
% if the first transition is in Trials.BadTrialsV, catch the second transition
% BadTrialsV: start,end, very long bad trials except transition
if ismember(Trials.TransitionPoint(1),Trials.BadTrialsV)|| Trials.TransitionPoint(1)<10 % abnomral beginning, use the second sess-type
    checkid=Trials.TransitionPoint(2)-1;
else
    checkid=Trials.TransitionPoint(1)-1;
end
if isfield(Trials,'TacTrials')
    TacTrials = Trials.TacTrials;
    AudTrials = Trials.AudTrials;
else
    TacTrials = [Trials.TLall Trials.TRall Trials.TLall_OpL Trials.TRall_OpL Trials.TLall_OpR Trials.TRall_OpR];
    AudTrials = [Trials.ALall Trials.ARall Trials.ALall_OpL Trials.ARall_OpL Trials.ALall_OpR Trials.ARall_OpR];
end

if ismember(checkid,TacTrials) && ~ismember(checkid,AudTrials)
    FirSessType = 1;
elseif ismember(checkid,AudTrials) && ~ismember(checkid,TacTrials)
    FirSessType = 2;
else
    warning('check Trials!')
end