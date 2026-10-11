function [StableLeftBefore, StableLeftAfter, StableRightBefore, StableRightAfter] = ...
    func_GetTrialsTransition(Trials, ExcludeOpto,ExcludeBadTrialsV,varargin)
% Aligned left and right trials to transition
% Input:
% Trials: label and id of trials
% ExcludeOpto: exclude optogenetic trials or not

% considering BadTrialsV: start,end, very long bad trials except transition

% set parameters
p = inputParser;
p.addParameter('ExcludeNoResp' , 0 , @(x) isnumeric(x) );
p.addParameter('ExcludePreLick' , 0 , @(x) isnumeric(x) );
p.parse(varargin{:});
ExcludeNoResp = p.Results.ExcludeNoResp;
ExcludePreLick = p.Results.ExcludePreLick;

%% get trials
TransitionPoint = Trials.TransitionPoint;
if length(TransitionPoint)>1 % more than one transition point
    if ismember(Trials.TransitionPoint(1),Trials.BadTrialsV)|| Trials.TransitionPoint(1)<10 % abnomral beginning, use the second sess-type
        disp('First transition is abnormal, use the second transtion!')
        if length(TransitionPoint)>2
            TrialsInclude = TransitionPoint(1):TransitionPoint(3)-1;
        else 
            TrialsInclude = TransitionPoint(1):Trials.Length;
        end
        TransitPointV = TransitionPoint(2);
    else  % use the first transition
        TrialsInclude = 1:TransitionPoint(2)-1;
        TransitPointV = TransitionPoint(1);
    end
else % only one transition point
    TrialsInclude = 1:Trials.Length;
    TransitPointV = TransitionPoint;
end
if ExcludeBadTrialsV==1
    TrialsInclude = intersect(TrialsInclude, setdiff(1:Trials.Length,Trials.BadTrialsV));
end
    
if ExcludeOpto==1 % only exclude opto trials
    NormalLeftAll = [Trials.TLall Trials.ALall];
    NormalRightAll = [Trials.TRall Trials.ARall];
else
    NormalLeftAll = [Trials.TLall Trials.TLall_OpL Trials.TLall_OpR Trials.ALall Trials.ALall_OpL Trials.ALall_OpR];
    NormalRightAll = [Trials.TRall Trials.TRall_OpL Trials.TRall_OpR  Trials.ARall Trials.ARall_OpL Trials.ARall_OpR];
end

if ExcludeNoResp==1 % delete no-response trials if exist
    FieldNm = fieldnames(Trials);
    NoRespFileds = find(cellfun(@(x) ~isempty(x),strfind(FieldNm ,'Nr'))); % find all the no response trials
    NoResp = cell2mat(arrayfun(@(x) Trials.(FieldNm{x}),NoRespFileds','UniformOutput',false));

    NormalLeftAll = setdiff(NormalLeftAll,NoResp);
    NormalRightAll = setdiff(NormalRightAll,NoResp);
end

if ExcludePreLick==1 % delete pre-licking trials if exist
    PreLicks = Trials.LickingAnalysis.PreLickingTrials;
    NormalLeftAll = setdiff(NormalLeftAll,PreLicks);
    NormalRightAll = setdiff(NormalRightAll,PreLicks);
end

NormalLeftAll = intersect(NormalLeftAll,TrialsInclude);
NormalRightAll = intersect(NormalRightAll,TrialsInclude);

%% Get trials aligned to 1st transition point: Before+After(including transition)
% Left trials
StableLeftBefore = NormalLeftAll(NormalLeftAll<TransitPointV);
StableLeftAfter = NormalLeftAll(NormalLeftAll>=TransitPointV);
% Right trials
StableRightBefore = NormalRightAll(NormalRightAll<TransitPointV);
StableRightAfter = NormalRightAll(NormalRightAll>=TransitPointV);

