%% load data
TaskTag = 'TAr';
Folder = 'X:\PSTH\SglSess_LeftALM\';
% Folder = 'X:\PSTH\SglSess_RightALM\';

FolderName = [Folder 'transition\' TaskTag '_dires_DeletePreLicksNoResp\'];
Files = dir([FolderName '*.mat']);
FirSessTypeList = arrayfun(@(x) str2double(Files(x).name(strfind(Files(x).name,'.mat')-1)), 1:length(Files));

%% GET valid session: choose transition type and session type to accumulate session 
FirstSessType = 2;      % 1,whisker;   2,auditory
SessId = find(FirSessTypeList==FirstSessType);
SessN = numel(SessId)

% for pool session, trials before/after transition should be the same length across session
BeforeTransit = 50; % this parameter is consistent between L and R trials.
% Different transition type 
switch TaskTag
    case 'TAs'; switch FirstSessType; case 1; AfterTransit = 50; case 2; AfterTransit = 90; end
    case 'TAr'; switch FirstSessType; case 1; AfterTransit = 90; case 2; AfterTransit = 115; end
end

SampleN = 15; % trial-window
% aligned trials --> aligned transit-windows 
TrialAligned = -BeforeTransit:AfterTransit;
TransitAligned = TrialAligned(1:numel(TrialAligned)-SampleN+1)+SampleN-1; % zero indicate window included the first transition trial

n = 0;
xL_all = cell(SessN,1);  LeftVTags_all = cell(SessN,1); 
xR_all = cell(SessN,1);  RightVTags_all = cell(SessN,1);
for iSess = SessId
    n = n+1;
    load([FolderName Files(iSess).name], 'xL', 'xR', 'LeftVTags', 'RightVTags');
    xL_all{n} = xL;  LeftVTags_all{n} = LeftVTags;
    xR_all{n} = xR;  RightVTags_all{n} = RightVTags;
end
load([FolderName Files(1).name],'TimeA');

% plot performance
TrialSmoothWin = 2;
figure;hold on; set(gcf,'position',[100 100 300 200])
[HR_L,HR_R] = plot_aligned_performance(xL_all, xR_all, LeftVTags_all, RightVTags_all, (1:SessN)', TransitAligned, SampleN, TrialSmoothWin);
HR_L = cell2mat(HR_L); HR_R = cell2mat(HR_R); 

% set file name to save projection results
SaveName = [Folder 'transition\' TaskTag '_dires_SglProjecResults\' ...
    TaskTag '_transition_dires_SglProjecResults_DeletePreLickNoResp_FirstSessType_' num2str(FirstSessType) '.mat'];

%% get single session direction, test set projection-traces
% setup for direction
Gram_Schmidt = 1;
normDire = 1;
% set up for projection
offsetproj = 1;
DirePools = {'ID','CD','AD','OD','RM','GM','MD'};
nDire = numel(DirePools);

DireTacGS = cell(SessN,1);  
DireAudGS = cell(SessN,1);
ProjTestTrace_Tac = cell(SessN,1);
ProjTestTrace_Aud = cell(SessN,1);
ProjTestScore_Tac = cell(SessN,1);
ProjTestScore_Aud = cell(SessN,1);
LProj_Tac = cell(SessN,1);
RProj_Tac = cell(SessN,1);
LProj_Aud = cell(SessN,1);
RProj_Aud = cell(SessN,1);
n=0;
%
for iSess = SessId
    n=n+1;
    load([FolderName Files(iSess).name], 'TimeA', 'time_proj', 'DireTac', 'DireAud', 'MD', 'PSTHset_test', ...
    'PSTHsL', 'PSTHsR', 'xL', 'xR', 'LeftVTags', 'RightVTags')

    disp(['ValidSess ' num2str(n) '; Unit number ' num2str(size(DireTac.ID,2))])
    tic
    % reverse the direction of Dire.OD (previous script calculate OD as error-correct
    DireTac.OD = -DireTac.OD;
    DireAud.OD = -DireAud.OD;

    % ======== get direction ======== .dire: folds*units
    DireTacGS{n} = getDire_sglSess_GS(DireTac,MD,Gram_Schmidt,normDire);
    DireAudGS{n} = getDire_sglSess_GS(DireAud,MD,Gram_Schmidt,normDire);

    %  ======== get test traces and scores ======== .dire: {trial type} (folds*trials)*time
    for iD = 1:nDire % last is MD
        if strcmp(DirePools{iD},'MD')%  MD, no offset
            [ProjTestTrace_Tac{n}.(DirePools{iD}),ProjTestScore_Tac{n}.(DirePools{iD})] = ...
                getTestTracesAndScores_sglSess(DirePools{iD}, DireTacGS{n}.(DirePools{iD}), PSTHset_test, TimeA, 0);
            [ProjTestTrace_Aud{n}.(DirePools{iD}),ProjTestScore_Aud{n}.(DirePools{iD})] = ...
                getTestTracesAndScores_sglSess(DirePools{iD}, DireAudGS{n}.(DirePools{iD}), PSTHset_test, TimeA, 0);
        else
            [ProjTestTrace_Tac{n}.(DirePools{iD}),ProjTestScore_Tac{n}.(DirePools{iD})] = ...
                getTestTracesAndScores_sglSess(DirePools{iD}, DireTacGS{n}.(DirePools{iD}), PSTHset_test, TimeA, offsetproj);
            [ProjTestTrace_Aud{n}.(DirePools{iD}),ProjTestScore_Aud{n}.(DirePools{iD})] = ...
                getTestTracesAndScores_sglSess(DirePools{iD}, DireAudGS{n}.(DirePools{iD}), PSTHset_test, TimeA, offsetproj);
        end

    end

    %  ======== get transition projection ======== 
    % PSTHOff: (Units x TrialsAligned)
    [PSTHsLiAlignOff, PSTHsRiAlignOff] = getPSTHTransition_sglSess('offset', TrialAligned, PSTHsL, PSTHsR, xL, xR, TimeA, time_proj);
    for iD = 1:nDire
        % PSTH: (Units x TrialsAligned)
        [PSTHsLiAlign, PSTHsRiAlign] = getPSTHTransition_sglSess(DirePools{iD}, TrialAligned, PSTHsL, PSTHsR, xL, xR, TimeA, time_proj);
        LProj_Tac{n}.(DirePools{iD}) = DireTacGS{n}.(DirePools{iD}) * PSTHsLiAlign;
        RProj_Tac{n}.(DirePools{iD}) = DireTacGS{n}.(DirePools{iD}) * PSTHsRiAlign;
        LProj_Aud{n}.(DirePools{iD}) = DireAudGS{n}.(DirePools{iD}) * PSTHsLiAlign;
        RProj_Aud{n}.(DirePools{iD}) = DireAudGS{n}.(DirePools{iD}) * PSTHsRiAlign;
        if ~strcmp(DirePools{iD},'MD') && offsetproj==1
            LProj_Tac{n}.(DirePools{iD}) = LProj_Tac{n}.(DirePools{iD})- DireTacGS{n}.(DirePools{iD}) * PSTHsLiAlignOff;
            RProj_Tac{n}.(DirePools{iD}) = RProj_Tac{n}.(DirePools{iD})- DireTacGS{n}.(DirePools{iD}) * PSTHsRiAlignOff;
            LProj_Aud{n}.(DirePools{iD}) = LProj_Aud{n}.(DirePools{iD})- DireAudGS{n}.(DirePools{iD}) * PSTHsLiAlignOff;
            RProj_Aud{n}.(DirePools{iD}) = RProj_Aud{n}.(DirePools{iD})- DireAudGS{n}.(DirePools{iD}) * PSTHsRiAlignOff;
        end
    end
    toc
    clear PSTHsLiAlign PSTHsRiAlign PSTHsLiAlignOff PSTHsRiAlignOff
end
save(SaveName, 'TrialAligned','DireTacGS','DireAudGS','ProjTestTrace_Tac','ProjTestTrace_Aud','ProjTestScore_Tac','ProjTestScore_Aud',...
'LProj_Tac','RProj_Tac','LProj_Aud','RProj_Aud')

%% load saved projection results
load(SaveName)

%% plot
% fig1, panels:
%               Tac-test-traces   Aud-test-traces  Tac-Transition-proj     
% Directions
DirePools = {'ID','CD','AD','OD','RM','GM','MD'};
nDire = numel(DirePools);

plotTestScoreTag=1;% 1,plot correct, 2, plot all(average correct and error set)
AvgFoldsTrials=1; % for test set scores
AvgFoldsTrials_traces=1;  % for test set tracesc
AvgFolds=1; % for transitiontrials

TraceSmoothWin = 200;
timeTrace = [-1 4];
timeTraceId = TimeA.time>=timeTrace(1) & TimeA.time<=timeTrace(2);
xtime = TimeA.time(timeTraceId);

TacSet = 1:4; % TLC,TRC,TLE,TRE
AudSet = 5:8; % ALC,ARC,ALE,ARE
CrtSet = [1 2 5 6]; % correct set 
ErrSet = [3 4 7 8]; % error set
ColorList = [83 210 220; % TL
             49 125 226; % TR
             83 210 220; % TL
             49 125 226; % TR
             255 192 95; % AL
             225 97 90; % ARs
             255 192 95; % AL
             225 97 90]/255; % AR
xBefore = TransitAligned(1)-10:TransitAligned(1)-1;
xAfter  = TransitAligned(end)+1:TransitAligned(end)+10;

LProjV = cell(2,nDire); RProjV= cell(2,nDire); % collect for source data, (tasks * directions)
for ifig = 1:2
    figure; set(gcf,'Position',[0 0 200*3 300*nDire ],'Renderer','painters');
    if ifig==1; task='Tac';  sgtitle('Projections on tactile modes')
    elseif ifig==2; task='Aud'; sgtitle('Projections on auditory modes')
    end

    % panels: Tac (correct error), Aud  (correct error)
    for iD = 1:nDire % last is MD
        if iD~=nDire
            subplot(nDire,3, 3*iD-2); hold on
            [ymin1,ymax1] = plotTestTraces3(eval(['ProjTestTrace_' task]), DirePools{iD}, TacSet, timeTraceId, xtime, TraceSmoothWin, ColorList, AvgFoldsTrials_traces,'sem');
            subplot(nDire,3, 3*iD-1); hold on
            [ymin2,ymax2] = plotTestTraces3(eval(['ProjTestTrace_' task]), DirePools{iD}, AudSet, timeTraceId, xtime, TraceSmoothWin, ColorList, AvgFoldsTrials_traces,'sem');
        else
            subplot(nDire,3, 3*iD-2); hold on
            [ymin1,ymax1] = plotTestTraces3(eval(['ProjTestTrace_' task]), DirePools{iD}, CrtSet, timeTraceId, xtime, TraceSmoothWin, ColorList, AvgFoldsTrials_traces,'sem');
            subplot(nDire,3, 3*iD-1); hold on
            [ymin2,ymax2] = plotTestTraces3(eval(['ProjTestTrace_' task]), DirePools{iD}, ErrSet, timeTraceId, xtime, TraceSmoothWin, ColorList, AvgFoldsTrials_traces,'sem');
        end
        ymin = min([ymin1 ymin2]); ymax = max([ymax1 ymax2]);
        subplot(nDire,3, 3*iD-2);  ylim([ymin ymax]); subplot(nDire,3, 3*iD-1);  ylim([ymin ymax])

        subplot(nDire,3, 3*iD); hold on
        [LProjV{ifig, iD}, RProjV{ifig, iD}] = plotTranstion3(eval(['LProj_' task]), eval(['RProj_' task]), DirePools{iD}, TrialAligned, SampleN, AvgFolds, 'sem');
        plotTestScore3(FirstSessType, eval(['ProjTestScore_' task]), DirePools{iD}, plotTestScoreTag, xBefore, xAfter, AvgFoldsTrials,'sem')
    end
end

% figure(4);
%  for iD = 1:nDire % last is MD
%      subplot(nDire,3, 3*iD-2);  
%      set(gca,'TickDir','out','TickLength',[0.02 0.03])
%      subplot(nDire,3, 3*iD-1);  
%      set(gca,'TickDir','out','TickLength',[0.02 0.03])
%  end