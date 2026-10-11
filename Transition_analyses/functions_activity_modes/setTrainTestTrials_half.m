function [TrainId,TestId] = setTrainTestTrials_half(TrialId, ProbTrain, TriN, getExactId)
% TrialsId: Trial id for one trial type
% Prob: probability of trials in training set
% TriN: only if NumTri<2*TriN, Test set should have the identical trial length across sessions (TriN)

NumTri = numel(TrialId);
if getExactId==0 % in this case, TrainId and TestId are Id in TrialId, not exact id
    TrialId = 1:NumTri;
end

if NumTri>=TriN/ProbTrain
    TrainId = randsample(TrialId,floor(NumTri*ProbTrain));
    TestId = setdiff(TrialId,TrainId);
%     TestId = randsample(remainder,TriN);
else
    TrainId = randsample(TrialId,TriN,true);
    remainder = setdiff(TrialId,unique(TrainId));
    if numel(remainder)>TriN
        TestId = randsample(remainder,TriN);
    else
        TestId = [remainder randsample(TrialId,TriN-numel(remainder),true)];
    end
end