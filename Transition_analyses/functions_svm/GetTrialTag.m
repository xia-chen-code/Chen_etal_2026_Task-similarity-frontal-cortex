% trial tag: 0,no-response; 1,correct; 2,error
function TrialTags = GetTrialTag(TrialsId, Trials)

Correct = [Trials.TLC  Trials.ALC Trials.TRC  Trials.ARC];
Error = [Trials.TLE  Trials.ALE Trials.TRE  Trials.ARE];
NoResponse = [Trials.TLNr  Trials.ALNr Trials.TRNr  Trials.ARNr];
TrialTags = nan(1,length(TrialsId));

for i = 1:length(TrialsId)
    itrial = TrialsId(i);
    if ismember(itrial,Correct)
        TrialTags(i)=1;
    elseif ismember(itrial,Error)
        TrialTags(i)=2;
    elseif ismember(itrial,NoResponse)
        TrialTags(i)=0;
    end
end

