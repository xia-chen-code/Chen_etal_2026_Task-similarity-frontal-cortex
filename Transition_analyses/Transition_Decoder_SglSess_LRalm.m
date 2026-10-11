% Decoder will be trained with "stable trials after transition". In single session.  
% Choose time-window of activity to train the decoder
% Test the decoder on transition trials
% Left and right ALM data are catenated as [LeftALM-Units,RightALM-Units]*time*trials
% to decode together.

TaskTag='TAs';
TaskFolderName = 'TAs_loose';
PSTHFolder = ['X:\PSTH\SglSessPSTH_LRalm\' TaskFolderName '\'];
Files = dir([PSTHFolder '*mat']);
SaveFile = ['X:\PSTH\SglSessPSTH_LRalm\transition\' TaskTag '_transition_decoder_DeletePreLickAndNoResp_C8E6_SampleN15.mat']; % 2025/04/28

null = 1; % if 1, get null model for L/R prediction

time_svm.Sry = [0 1];
time_svm.Cho = [1 2];
time_svm.Act = [2 2.3];
time_svm.Ouc = [2 3];
time_svm.Mod = [-1.5 -0.5];

SampleN = 15;

UnitsThr = 5; % if units number in either areas <= UnitsThr (Threshold), escape this session
TrialsThrC = 8;
TrialsThrE = 6;

FilteringCells = 1;
CellFilter.MetricsFRthr = 0.1; % >= 1spikes/s
CellFilter.DepthRange =  [-Inf 1200];%[1200 +inf];
CellFilter.MetricsDur = [0.3 0.9];

SessTag = nan(numel(Files),6); % [Ani Sess FirTransitType FirSessType CellUsedForDecodingArea1 ~Area2]
svmA = initialize_svm_area(numel(Files),null);

xL = cell(1,numel(Files)); xR = cell(1,numel(Files)); 
LeftVTags = cell(1,numel(Files)); RightVTags = cell(1,numel(Files)); 
%
h=waitbar(0,'Decode transition using stable trials for each session');
for iSess = 1:numel(Files)
    waitbar(iSess/numel(Files));
    disp(['===== Load session' num2str(iSess) ' =====']);
    tic

    % Load simulatenously recorded data.mat
    load([PSTHFolder Files(iSess).name]);

    % re-catch first session type: 1,whisker,2,auditory
    FirSessTypeR = ReCatchFirSessType(Trials);
    if FirSessType ~= FirSessTypeR
        disp('re-catch session type for this session')
        FirSessType = FirSessTypeR;
    end

    % accumulate animal and session label
    SessTag(iSess,1:4) = [Ani Sess FirTransitType FirSessType];
    if FirTransitType==0; disp('Not used in transition analysis'); continue; end

    % filtering cells
    if FilteringCells==1
        CellIdArea1 = func_LiteCellFilter(UnitsArea1,CellFilter);
        CellIdArea2 = func_LiteCellFilter(UnitsArea2,CellFilter);
    else
        CellIdArea1 = 1:numel(UnitsArea1);
        CellIdArea2 = 1:numel(UnitsArea2);
    end

    % check units number
    if any([numel(CellIdArea1) numel(CellIdArea2)]<UnitsThr)
        disp('Not enough cells'); continue
    end
    SessTag(iSess,5:6) = [numel(UnitsArea1(CellIdArea1)) numel(UnitsArea2(CellIdArea2))];

    % check trial number
    continueTag = func_check_Ntrial(Trials,TrialsThrC,{'TLC','TRC','ALC','ARC'});
    continueTagE = func_check_Ntrial(Trials,TrialsThrE,{'TLE','TRE','ALE','ARE'});
    if continueTag == 1 || continueTagE ==1
        disp('Not enough trials'); continue
    end
    
    %%%%%%%%%%%%%%%% run svm and predict transition trials %%%%%%%%%%%%%%%%%
    % Area1 and area2 deocoding together
    catPSTH = cat(1,PSTHsArea1(CellIdArea1,:,:),PSTHsArea2(CellIdArea2,:,:));
    if null==0
        [svmA.Tac_Sry{iSess},svmA.Aud_Sry{iSess},xL{iSess},xR{iSess},LeftVTags{iSess},RightVTags{iSess},svmA.Cross_Sry{iSess}]...
            = svm_stable_cv('sensory', time_svm.Sry, catPSTH, Trials, TimeA, SampleN);
        [svmA.Tac_Cho{iSess},svmA.Aud_Cho{iSess},~,~,~,~,svmA.Cross_Cho{iSess}] ...
            = svm_stable_cv('choice', time_svm.Cho, catPSTH, Trials, TimeA, SampleN);
        [svmA.Tac_Act{iSess},svmA.Aud_Act{iSess},~,~,~,~,svmA.Cross_Act{iSess}] ...
            = svm_stable_cv('action', time_svm.Act, catPSTH, Trials, TimeA, SampleN);
        [svmA.Tac_Ouc{iSess},svmA.Aud_Ouc{iSess},~,~,~,~,svmA.Cross_Ouc{iSess}] ...
            = svm_stable_cv('outcome', time_svm.Ouc, catPSTH, Trials, TimeA, SampleN);
    else % get null model
        [svmA.Tac_Sry{iSess},svmA.Aud_Sry{iSess},xL{iSess},xR{iSess},LeftVTags{iSess},RightVTags{iSess},svmA.Cross_Sry{iSess},...
            svmA.Tac_Sry_null{iSess},svmA.Aud_Sry_null{iSess}] = svm_stable_cv_null('sensory', time_svm.Sry, catPSTH, Trials, TimeA, SampleN);

        [svmA.Tac_Cho{iSess},svmA.Aud_Cho{iSess},~,~,~,~,svmA.Cross_Cho{iSess},...
            svmA.Tac_Cho_null{iSess},svmA.Aud_Cho_null{iSess}] = svm_stable_cv_null('choice', time_svm.Cho, catPSTH, Trials, TimeA, SampleN);

        [svmA.Tac_Act{iSess},svmA.Aud_Act{iSess},~,~,~,~,svmA.Cross_Act{iSess},...
            svmA.Tac_Act_null{iSess},svmA.Aud_Act_null{iSess}] = svm_stable_cv_null('action', time_svm.Act, catPSTH, Trials, TimeA, SampleN);

        [svmA.Tac_Ouc{iSess},svmA.Aud_Ouc{iSess},~,~,~,~,svmA.Cross_Ouc{iSess},...
            svmA.Tac_Ouc_null{iSess},svmA.Aud_Ouc_null{iSess}] = svm_stable_cv_null('outcome', time_svm.Ouc, catPSTH, Trials, TimeA, SampleN);
    end
    
    [svmA.Crt_Mod{iSess},svmA.Err_Mod{iSess},~,~,~,~,svmA.Cross_Mod{iSess}] ...
        = svm_stable_cv_modality(catPSTH, Trials, TimeA, time_svm.Mod, SampleN);
    clear catPSTH

    toc
end
close(h)
save(SaveFile,'SessTag', 'SampleN','svmA','time_svm',...
    'xL','xR','LeftVTags','RightVTags','UnitsThr','TrialsThrC','TrialsThrE') % save 'UnitsThr','TrialsThrC','TrialsThrE' after 25.7.3
