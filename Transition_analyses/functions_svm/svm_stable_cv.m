function [svmTac,svmAud,xL,xR,LeftVTags,RightVTags,svmCross] = svm_stable_cv(Decoder, time_svm, PSTHs, Trials, TimeA, SampleN)
% train svm with stable transtion-after trials
% i.e. Tac to Aud transition, trained with Aud trials, v.v.

% variant of svm_stable.m, cross-validate to train and test the decoder
%% get stable trials and psth
BalanceTrial = 0;
[TacTrialId, TacNtrial] = fun_GetTrialPool(Trials, {'TLC', 'TRC', 'TLE', 'TRE'}, BalanceTrial);
[AudTrialId, AudNtrial] = fun_GetTrialPool(Trials, {'ALC', 'ARC', 'ALE', 'ARE'}, BalanceTrial);

% get PSTH of stable trials
timeid_svm = find(TimeA.time>=time_svm(1) & TimeA.time<time_svm(2));

% catenate trial types to get the 'Predictor Data'      {TrialType,1} trials*units (observations*variables)
TacX = cellfun(@(x) squeeze(mean(PSTHs(:,timeid_svm,x),2))', TacTrialId', 'UniformOutput', false);  
AudX = cellfun(@(x) squeeze(mean(PSTHs(:,timeid_svm,x),2))', AudTrialId', 'UniformOutput', false);
% get 'Response data' : LC, RC, LE, RE
switch Decoder
    case 'sensory'
        Label = [-1 1 -1 1];
    case {'choice' , 'action'}
        Label = [-1 1 1 -1];
    case 'outcome'
        Label = [1 1 -1 -1];
end
TacY = arrayfun(@(x) repmat(Label(x),TacNtrial(x),1), (1:4)', 'UniformOutput', false); 
AudY = arrayfun(@(x) repmat(Label(x),AudNtrial(x),1), (1:4)', 'UniformOutput', false); 

%% get new data for prediction
ExcludeOpto = 1;
ExcludeBadTrialsV = 0;
ExcludeNoResp = 1;
ExcludePreLick = 1; 
Offset = 0;
% PSTHsL, PSTHsR: trials * units * time
[PSTHsL, PSTHsR, xL, xR, LeftVTags, RightVTags] = ...
    construct_transition_data (PSTHs, time_svm, TimeA, Trials, ExcludeOpto, ExcludeBadTrialsV, Offset,'ExcludeNoResp',ExcludeNoResp,'ExcludePreLick',ExcludePreLick);

XnewL = mean(PSTHsL,3);
XnewR = mean(PSTHsR,3);
clear PSTHsL PSTHsR
switch Decoder
    case 'sensory'
        LeftVLabels = -1*ones(1,numel(xL));
        RightVLabels = ones(1,numel(xR));
    case {'choice' , 'action'}
        LeftVLabels = TrialTagToLabel(LeftVTags, -1); % choice direction label 
        RightVLabels = TrialTagToLabel(RightVTags, 1);
    case 'outcome'
        LeftVLabels = TrialTagToOutcome(LeftVTags);
        RightVLabels = TrialTagToOutcome(RightVTags);
end


%% cross-validation
nFolds = 100;
% partition trials into k folds for each trial type (cross-validation)
% cvTac = arrayfun(@(x) cvpartition(x,'KFold',nFolds),TacNtrial,'UniformOutput',false);
% cvAud = arrayfun(@(x) cvpartition(x,'KFold',nFolds),AudNtrial,'UniformOutput',false);

TriN = 6;
for iFold = 1:nFolds
    rng(iFold);
    
    TacTrainId = arrayfun(@(x) randperm(x,TriN),TacNtrial,'UniformOutput',false);
    TacTestId = arrayfun(@(x) setdiff(1:TacNtrial(x),TacTrainId{x}), 1:4,'UniformOutput',false);
    AudTrainId = arrayfun(@(x) randperm(x,TriN),AudNtrial,'UniformOutput',false);
    AudTestId = arrayfun(@(x) setdiff(1:AudNtrial(x),AudTrainId{x}), 1:4,'UniformOutput',false);
    
    % training set
    TacXTrain = arrayfun(@(x) TacX{x}(TacTrainId{x},:), (1:4)','UniformOutput',false);
    TacYTrain = arrayfun(@(x) TacY{x}(TacTrainId{x},:), (1:4)','UniformOutput',false);
    AudXTrain = arrayfun(@(x) AudX{x}(AudTrainId{x},:), (1:4)','UniformOutput',false);
    AudYTrain = arrayfun(@(x) AudY{x}(AudTrainId{x},:), (1:4)','UniformOutput',false);
    % test set
    TacXTest = arrayfun(@(x) TacX{x}(TacTestId{x},:), (1:4)','UniformOutput',false);
    TacYTest = arrayfun(@(x) TacY{x}(TacTestId{x},:), (1:4)','UniformOutput',false);
    AudXTest = arrayfun(@(x) AudX{x}(AudTestId{x},:), (1:4)','UniformOutput',false);
    AudYTest = arrayfun(@(x) AudY{x}(AudTestId{x},:), (1:4)','UniformOutput',false);

%     % training set
%     TacXTrain = arrayfun(@(x) TacX{x}(training(cvTac{x},iFold),:), (1:4)', 'UniformOutput', false);
%     TacYTrain = arrayfun(@(x) TacY{x}(training(cvTac{x},iFold),:), (1:4)', 'UniformOutput', false);
%     AudXTrain = arrayfun(@(x) AudX{x}(training(cvAud{x},iFold),:), (1:4)', 'UniformOutput', false);
%     AudYTrain = arrayfun(@(x) AudY{x}(training(cvAud{x},iFold),:), (1:4)', 'UniformOutput', false);
%     % test set
%     TacXTest = arrayfun(@(x) TacX{x}(test(cvTac{x},iFold),:), (1:4)', 'UniformOutput', false);
%     TacYTest = arrayfun(@(x) TacY{x}(test(cvTac{x},iFold),:), (1:4)', 'UniformOutput', false);
%     AudXTest = arrayfun(@(x) AudX{x}(test(cvAud{x},iFold),:), (1:4)', 'UniformOutput', false);
%     AudYTest = arrayfun(@(x) AudY{x}(test(cvAud{x},iFold),:), (1:4)', 'UniformOutput', false);

    %% training svm model
    MdlTac = fitcsvm(cell2mat(TacXTrain),cell2mat(TacYTrain),'ClassNames', [-1 1],'Standardize',true);
%     MdlTac = fitcecoc(cell2mat(TacXTrain),cell2mat(TacYTrain));
    cvMdlTac = crossval(MdlTac);
    classLossTac = kfoldLoss(cvMdlTac);
    TacYTest_pred = cellfun(@(x) predict(MdlTac,x),TacXTest,'UniformOutput', false);

    MdlAud = fitcsvm(cell2mat(AudXTrain),cell2mat(AudYTrain),'ClassNames', [-1 1],'Standardize',true);
%     MdlAud = fitcecoc(cell2mat(AudXTrain),cell2mat(AudYTrain));
    cvMdlAud = crossval(MdlAud);
    classLossAud = kfoldLoss(cvMdlAud);
    AudYTest_pred = cellfun(@(x) predict(MdlAud,x),AudXTest,'UniformOutput', false);

    %% Decoding accuracy of test set
    % cross decode accuracy. LC,RC,LE,RE decode separately
    AcyTac_Self_Types = arrayfun(@(x) sum(TacYTest_pred{x}==TacYTest{x})/numel(TacYTest{x}), (1:4)');
    AcyAud_Self_Types = arrayfun(@(x) sum(AudYTest_pred{x}==AudYTest{x})/numel(AudYTest{x}), (1:4)');
    % decode all
    AcyTac_Self = sum(cell2mat(TacYTest_pred)==cell2mat(TacYTest))/numel(cell2mat(TacYTest));
    AcyAud_Self = sum(cell2mat(AudYTest_pred)==cell2mat(AudYTest))/numel(cell2mat(AudYTest));

    %% cross-task decoding
    PredAud_byTac = cellfun(@(x) predict(MdlTac,x),AudXTest,'UniformOutput', false); % predict Aud trials using Tac model
    PredTac_byAud = cellfun(@(x) predict(MdlAud,x),TacXTest,'UniformOutput', false); % predict Tac trials using Aud model
    % cross decode accuracy. LC,RC,LE,RE decode separately
    AcyAud_byTac_Types = arrayfun(@(x) sum(PredAud_byTac{x}==AudYTest{x})/numel(AudYTest{x}), (1:4)');
    AcyTac_byAud_Types = arrayfun(@(x) sum(PredTac_byAud{x}==TacYTest{x})/numel(TacYTest{x}), (1:4)');
    % decode all
    AcyAud_byTac = sum(cell2mat(PredAud_byTac)==cell2mat(AudYTest))/numel(cell2mat(AudYTest));
    AcyTac_byAud = sum(cell2mat(PredTac_byAud)==cell2mat(TacYTest))/numel(cell2mat(TacYTest));

    %% predict choice of transition trials, get transition trial decoding accuracy
    % 'new' is for transition trials
    YnewL_Tac = predict(MdlTac,XnewL);
    YnewR_Tac = predict(MdlTac,XnewR);
    [AcyL_Tac, xAcyL] = func_win_accuracy(xL, LeftVLabels, YnewL_Tac', SampleN);
    [AcyR_Tac, xAcyR] = func_win_accuracy(xR, RightVLabels, YnewR_Tac', SampleN);

    YnewL_Aud = predict(MdlAud,XnewL);
    YnewR_Aud = predict(MdlAud,XnewR);
    [AcyL_Aud, ~] = func_win_accuracy(xL, LeftVLabels, YnewL_Aud', SampleN);
    [AcyR_Aud, ~] = func_win_accuracy(xR, RightVLabels, YnewR_Aud', SampleN);

    %% save output
    svmTac.Mdl{iFold} = MdlTac;
    svmTac.classLoss{iFold} = classLossTac;
    svmTac.AcyTac_Self_Types{iFold} = AcyTac_Self_Types;
    svmTac.AcyTac_Self{iFold} = AcyTac_Self;
    svmTac.PredL{iFold} = YnewL_Tac;
    svmTac.PredR{iFold} = YnewR_Tac;
    svmTac.AcyL{iFold} = AcyL_Tac;
    svmTac.AcyR{iFold} = AcyR_Tac;
    svmTac.xAcyL{iFold} = xAcyL;
    svmTac.xAcyR{iFold} = xAcyR;

    svmAud.Mdl{iFold} = MdlAud;
    svmAud.classLoss{iFold} = classLossAud;
    svmAud.PredL{iFold} = YnewL_Aud;
    svmAud.PredR{iFold} = YnewR_Aud;
    svmAud.AcyL{iFold} = AcyL_Aud;
    svmAud.AcyR{iFold} = AcyR_Aud;
    svmAud.xAcyL{iFold} = xAcyL;
    svmAud.xAcyR{iFold} = xAcyR;
    svmAud.AcyAud_Self_Types{iFold} = AcyAud_Self_Types;
    svmAud.AcyAud_Self{iFold} = AcyAud_Self;

    svmCross.PredAud_byTac{iFold} = PredAud_byTac;
    svmCross.PredTac_byAud{iFold} = PredTac_byAud;
    svmCross.AcyAud_byTac_Types{iFold} = AcyAud_byTac_Types;
    svmCross.AcyTac_byAud_Types{iFold} = AcyTac_byAud_Types;
    svmCross.AcyAud_byTac{iFold} = AcyAud_byTac;
    svmCross.AcyTac_byAud{iFold} = AcyTac_byAud;
end