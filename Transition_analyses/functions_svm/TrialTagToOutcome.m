function TrialLabels = TrialTagToOutcome(TrialTags)
% change TrialTags to TrialLabels
% TrialTags: 0,no-response; 1,correct; 2,error
% TrialLabels: -1 error, 1 correct
TrialLabels = TrialTags;
TrialLabels(TrialTags==2)=-1; % error
TrialLabels(TrialTags==0)=-1; % no-response also has no reward
end
