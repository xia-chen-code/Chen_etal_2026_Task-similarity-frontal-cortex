function TrialLabels = TrialTagToLabel(TrialTags, LRlabel)
% change TrialTags to TrialLabels
% TrialTags: 0,no-response; 1,correct; 2,error
% TrialLabels: -1 lick left, 1 lick right
TrialLabels = TrialTags;
switch LRlabel
    case -1 % left trials
        TrialLabels(TrialTags==1)=-1; % correct-->lick left
        TrialLabels(TrialTags==2)=1; % error -->lick right
    case 1
        TrialLabels(TrialTags==2)=-1; % error-->lick left
end