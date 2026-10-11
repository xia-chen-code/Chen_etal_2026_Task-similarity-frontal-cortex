% Matching # of NMSs in TAs and TAr. Then calculate dimensionality for the peudo-data.

% Typically the sessions and neurons in both 'LMX' (Linear_NonLinear_selectivity_3way.m)
% and 'NeuralData' (Dim_v2.m) are paired.
% The criterion of choosing cells are the same, but not for choosing sessions.
% 'LMX' needs more error trials, while 'NeuralData' only checks correct trials
% Here we selected intersected sessions for analysis.

PlotEpoch = 1;
Area = 'LeftALM';

anovaTag = 1; % if 1, fitting with additional FRbase and TrialOrder
suffix = '_TrialOrder';

%% Load LMX dataset
[TAsFile, TArFile, Func_DispLMX] = Load_LMX_File(PlotEpoch, Area);

pAlpha = 0.05;
ColorTAsTAr;

load(TAsFile,'LMX','SessTag','NonLinearIdx','MeanFR'); LMXsL = LMX; SessTagsL = SessTag; NonLinearIdx_sL = NonLinearIdx; MeanFRsL = MeanFR;
load(TArFile,'LMX','SessTag','NonLinearIdx','MeanFR'); LMXrL = LMX; SessTagrL = SessTag; NonLinearIdx_rL = NonLinearIdx; MeanFRrL = MeanFR;
clear LMX SessTag

%% load NeuralData datasets
TAsFile =  ['X:\DataAnalysis\Dimensionality\TAs_' Area '_NeuralDataForDim_NotSessUnified.mat'];
TArFile =  ['X:\DataAnalysis\Dimensionality\TAr_' Area '_NeuralDataForDim_NotSessUnified.mat'];

switch PlotEpoch
    case 1
        load(TAsFile,'NeuralData_S'); NeuralData_sL = NeuralData_S;
        load(TArFile,'NeuralData_S'); NeuralData_rL = NeuralData_S; clear NeuralData_S
    case 2
        load(TAsFile,'NeuralData_D'); NeuralData_sL = NeuralData_D;
        load(TArFile,'NeuralData_D'); NeuralData_rL = NeuralData_D; clear NeuralData_D
    case 3
        load(TAsFile,'NeuralData_R'); NeuralData_sL = NeuralData_R;
        load(TArFile,'NeuralData_R'); NeuralData_rL = NeuralData_R; clear NeuralData_R
end

%%  find overlapping sessions of NeuralData and LMX, left ALM
% TAs
s1 = find(cellfun(@(x) ~isempty(x),NeuralData_sL(:,1)));
s2 = find(cellfun(@(x) ~isempty(x),LMXsL));
sessId_TAs = intersect(s1,s2);
[~] = CheckSessUnitN(NeuralData_sL(sessId_TAs,:),LMXsL(sessId_TAs));
[NonLinMixed_sL,Pure_sL,LinMixed_sL,NonS_sL,GoodFit_sL] = arrayfun(@(x) Func_DispLMX(LMXsL{x},pAlpha), sessId_TAs','UniformOutput',false);
% NMSprop_TAs = sum(cellfun(@numel,NonLinMixed_sL)) / sum(cellfun(@numel,GoodFit_sL));
LmxNum_TAs = [sum(cellfun(@numel,NonLinMixed_sL)) sum(cellfun(@numel,Pure_sL)) sum(cellfun(@numel,LinMixed_sL)) sum(cellfun(@numel,NonS_sL))];
LmxProp_TAs = LmxNum_TAs./sum(LmxNum_TAs);

% TAr
s1 = find(cellfun(@(x) ~isempty(x),NeuralData_rL(:,1)));
s2 = find(cellfun(@(x) ~isempty(x),LMXrL));
sessId_TAr = intersect(s1,s2);
[~] = CheckSessUnitN(NeuralData_rL(sessId_TAr,:),LMXrL(sessId_TAr));
[NonLinMixed_rL,Pure_rL,LinMixed_rL,NonS_rL,GoodFit_rL] = arrayfun(@(x) Func_DispLMX(LMXrL{x},pAlpha), sessId_TAr','UniformOutput',false);
% NMSprop_TAr = sum(cellfun(@numel,NonLinMixed_rL)) / sum(cellfun(@numel,GoodFit_rL));
LmxNum_TAr = [sum(cellfun(@numel,NonLinMixed_rL)) sum(cellfun(@numel,Pure_rL)) sum(cellfun(@numel,LinMixed_rL)) sum(cellfun(@numel,NonS_rL))];
LmxProp_TAr = LmxNum_TAr./sum(LmxNum_TAr);

%% Matching TAr neurons' proportions to TAs
% Typically TAr had more NMS neurons than TAs. So We downsampled NMS proportions of TAr mice.
% Match to the proportions in TAs
% resampled number of each type of neurons  should not exceed its number in original group
AllNum_Adjusted = min(LmxNum_TAr./LmxProp_TAs);
disp(['Maximum number of group: ' num2str(AllNum_Adjusted)])
LmxNum_TAr_Adjusted = round(AllNum_Adjusted*LmxProp_TAs);

numNeuronsList = unique([50:25:300 300:100:800]); % The maximum should be smaler than the AllNum_Adjusted
if numNeuronsList(end)>AllNum_Adjusted; error('Check numNeuronsList!'); end
Repeats = 100; % # of repeats for sampling neurons
Kfold = 10; % k-fold cross-validation
% For TAr
% Matching Proportions of neurons in _v3.
UnitId_inLMX = {NonLinMixed_rL, Pure_rL, LinMixed_rL, NonS_rL};
CStarArray_rL = getNcDimVsNeurons_v3(NeuralData_rL(sessId_TAr,:), UnitId_inLMX, numNeuronsList, Kfold, Repeats,...
    'lmx_prop_Adjusted',LmxProp_TAs);

SaveFolder = 'X:\DataAnalysis\Match_NMS_Dim\Left ALM\';
save([SaveFolder 'AdjustedTAr_CStarArray_MatchTArPropToTAs' '_Epoch' num2str(PlotEpoch) suffix '.mat'],'numNeuronsList','CStarArray_rL', 'UnitId_inLMX',...
    'Kfold', 'Repeats', 'LmxProp_TAs')

%% Matching TAs neurons' proportions to TAr
AllNum_Adjusted = min(LmxNum_TAs./LmxProp_TAr);
disp(['Maximum number of group: ' num2str(AllNum_Adjusted)])
LmxNum_TAs_Adjusted = round(AllNum_Adjusted*LmxProp_TAr);

numNeuronsList = unique([50:25:300 300:100:600]); % The maximum should be smaler than the AllNum_Adjusted
if numNeuronsList(end)>AllNum_Adjusted; error('Check numNeuronsList!'); end
Repeats = 100; % # of repeats for sampling neurons
Kfold = 10; % k-fold cross-validation
% Matching Proportions of neurons in _v3.
UnitId_inLMX = {NonLinMixed_sL, Pure_sL, LinMixed_sL, NonS_sL};
CStarArray_sL = getNcDimVsNeurons_v3(NeuralData_sL(sessId_TAs,:), UnitId_inLMX, numNeuronsList, Kfold, Repeats,...
    'lmx_prop_Adjusted',LmxProp_TAr);

SaveFolder = 'X:\DataAnalysis\Match_NMS_Dim\Left ALM\';
save([SaveFolder 'AdjustedTAs_CStarArray_MatchTAsPropToTAr' '_Epoch' num2str(PlotEpoch) suffix '.mat'],'numNeuronsList','CStarArray_sL', 'UnitId_inLMX',...
    'Kfold', 'Repeats', 'LmxProp_TAr')

%%  plot TAs and TAr
PlotEpoch = 3; 
MonteCarlo_correction = false; % to avoid P=0: true, (b+1)/(B+1); false, b/B
ColorTAsTAr; 
ColorM  = [156 156 192]/255; % match TAr to TAs
ColorM2 = [66 57 100]/255; % match TAs to TAr
ColorList = [ColorTAs; ColorTAr; ColorM; ColorM2];

SaveFolder = 'X:\DataAnalysis\Match_NMS_Dim\Left ALM\';
FileList = {[SaveFolder 'AdjustedTAs_CStarArray_MatchProp_Epoch' num2str(PlotEpoch) suffix '.mat'],...
    [SaveFolder 'AdjustedTAr_CStarArray_MatchProp_Epoch' num2str(PlotEpoch) suffix '.mat'],...
    [SaveFolder 'AdjustedTAr_CStarArray_MatchTArPropToTAs_Epoch' num2str(PlotEpoch) suffix '.mat'] };
% FileList{end+1} = [SaveFolder 'AdjustedTAs_CStarArray_MatchTAsPropToTAr_Epoch' num2str(PlotEpoch) suffix '.mat'];

TaskTag = {'TAs','TAr','TAr','TAs'};
numNeurons_Max = nan(1,numel(FileList));
Dim_AUC = cell(1,numel(FileList));

figure; set(gcf,'position',[0 100 680 330]);
subplot(1,2,1); hold on
for i = 1:numel(FileList)
    load(FileList{i});
    numNeurons_Max(i) = max(numNeuronsList);
    switch TaskTag{i}
        case 'TAs'
            plot_mean_and_sem(numNeuronsList,CStarArray_sL,ColorList(i,:),'-','shadow','se');
            Dim_AUC{i} = trapz(numNeuronsList,CStarArray_sL,2);  % Estimate AUC (Area Under Curve)
        case 'TAr'
            plot_mean_and_sem(numNeuronsList,CStarArray_rL,ColorList(i,:),'-','shadow','se');
            Dim_AUC{i} = trapz(numNeuronsList,CStarArray_rL,2);  % Estimate AUC (Area Under Curve)
    end
end
xLimit = min([numNeurons_Max 500]);
set(gca,'tickdir','out','TickLength',[0.02, 0.03],'xlim',[50 xLimit],'xtick',50:100:xLimit)
ylabel('Number of dimensions')

% Plot AUC
for i = 1:numel(FileList)
    load(FileList{i});
    id = find(numNeuronsList<=xLimit);
    switch TaskTag{i}
        case 'TAs'
            Dim_AUC{i} = trapz(numNeuronsList(id),CStarArray_sL(:,id),2);  % Estimate AUC (Area Under Curve)
        case 'TAr'
            Dim_AUC{i} = trapz(numNeuronsList(id),CStarArray_rL(:,id),2);  % Estimate AUC (Area Under Curve)
    end
end

subplot(1,2,2); hold on
xloc = 1:numel(FileList);
Dim_AUC_plot = Dim_AUC;
% plot median is more appropriate
h = percentile_boxplot(cell2mat(Dim_AUC_plot), ColorList, 0.4);

set(gca,'tickdir','out','TickLength',[0.02, 0.03],'xlim',[0 numel(FileList)+1],'xtick',xloc,...
    'ytick',1500:100:1800) % AUC before 500
% ylimits = [2000 2200]; set(gca,'ylim',ylimits,'YTick',ylimits(1):100:ylimits(2))
ylim([1500 1850])
title(['AUC: before ' num2str(xLimit)])

% test
% pair_id = [1 2; 2 3; 1 3; 1 4; 2 4; 3 4];
% pair_names = ['TAs-TAr, TAr-TArMatch, TAs-TArMatch, TAs-TAsMatch, TAr-TAsMatch, M-M'];
pair_id = [1 2; 2 3; 1 3];
pair_names = ['TAs-TAr, TAr-TArMatch, TAs-TArMatch'];
nBoot = 10000;
SideTag = 2;
p = arrayfun(@(x) permu_test(Dim_AUC_plot{pair_id(x,1)},Dim_AUC_plot{pair_id(x,2)}, nBoot, SideTag, MonteCarlo_correction),1:size(pair_id,1));

% p = arrayfun(@(x) permu_test_studentized(Dim_AUC_plot{pair_id(x,1)},Dim_AUC_plot{pair_id(x,2)}, nBoot, SideTag, MonteCarlo_correction),1:size(pair_id,1));
% disp(['Bonferroni-corrected studentized p-value, compared with black bar: ' num2str(p*size(pair_id,1))])

sgtitle({ ...
    sprintf('Epoch%d, Corrected P:', PlotEpoch), ...
    sprintf('%.2g ', p*size(pair_id,1)) ...
    })

%% Removing neurons from TAs populations
% AdjTag (Tag for Adjusted):
% 1. all population
% 2. NMS lesion
% 3. LMS lesion
% 4. PS lesion
% 5. NonS lesion
% 6. NMS and LMS lesion
AdjTagNames = {'','_NMSlesion','_LMSlesion','_PSlesion','_NonSlesion','_NMSandLMSlesion'};
Repeats = 100; % # of repeats for sampling neurons
Kfold = 10; % k-fold cross-validation

for AdjTag = 1:6
    [UnitId_inLMX, CellTag_Adjusted]= get_AdjustedUnitId_inLMX(NonLinMixed_sL, Pure_sL, LinMixed_sL, NonS_sL, AdjTag);
    % re-catch NeuralData
    NeuralData_Adjusted = Catch_AdjustedNeuralData(NeuralData_sL, sessId_TAs, CellTag_Adjusted);

    CellNum_Adjusted = size(CellTag_Adjusted,1);
    if CellNum_Adjusted>=800
        numNeuronsList = unique([50:25:400 400:100:800]);
    elseif CellNum_Adjusted<400
        numNeuronsList = unique(50:25:CellNum_Adjusted);
    else
        numNeuronsList = unique([50:25:400 400:100:CellNum_Adjusted]);
    end
    % Matching Proportions of neurons in _v3.
    CStarArray_sL = getNcDimVsNeurons_v3(NeuralData_sL(sessId_TAs,:), UnitId_inLMX, numNeuronsList, Kfold, Repeats);
    SaveFolder = 'X:\DataAnalysis\Match_NMS_Dim\Left ALM\';
    save([SaveFolder 'AdjustedTAs_CStarArray_MatchProp' AdjTagNames{AdjTag} '_Epoch' num2str(PlotEpoch) suffix '.mat'],'numNeuronsList','CStarArray_sL','NeuralData_Adjusted', 'UnitId_inLMX')
end

%% Removing neurons from TAr populations
% AdjTag (Tag for Adjusted):
% 1. all population
% 2. NMS lesion
% 3. LMS lesion
% 4. PS lesion
% 5. NonS lesion
% 6. NMS and LMS lesion
AdjTagNames = {'','_NMSlesion','_LMSlesion','_PSlesion','_NonSlesion','_NMSandLMSlesion'};
Repeats = 100; % # of repeats for sampling neurons
Kfold = 10; % k-fold cross-validation

for AdjTag = 1:6
    [UnitId_inLMX, CellTag_Adjusted]= get_AdjustedUnitId_inLMX(NonLinMixed_rL, Pure_rL, LinMixed_rL, NonS_rL, AdjTag);
    % re-catch NeuralData
    NeuralData_Adjusted = Catch_AdjustedNeuralData(NeuralData_rL, sessId_TAr, CellTag_Adjusted);

    % =============================================================== %
    % Recalculate dimensionality for the group with selected neurons.
    CellNum_Adjusted = size(CellTag_Adjusted,1);
    if CellNum_Adjusted>=800
        numNeuronsList = unique([50:25:400 400:100:800]);
    elseif CellNum_Adjusted<400
        numNeuronsList = unique(50:25:CellNum_Adjusted);
    else
        numNeuronsList = unique([50:25:400 400:100:CellNum_Adjusted]);
    end
    % Matching Proportions of neurons in _v3.
    CStarArray_rL = getNcDimVsNeurons_v3(NeuralData_rL(sessId_TAr,:), UnitId_inLMX, numNeuronsList, Kfold, Repeats);
    SaveFolder = 'X:\DataAnalysis\Match_NMS_Dim\Left ALM\';
    save([SaveFolder 'AdjustedTAr_CStarArray_MatchProp' AdjTagNames{AdjTag} '_Epoch' num2str(PlotEpoch) suffix '.mat'],'numNeuronsList','CStarArray_rL','NeuralData_Adjusted', 'UnitId_inLMX')
end

%% plot these lesion conditions 
PlotEpoch = 3;
TaskTag = 'TAr';
suffix = '_TrialOrder'; 
AUCTag = 2; % bar-plot: 1, actual AUC; 2, relative AUC (minus black AUC - control group)
MonteCarlo_correction = false; % true, (b+1)/(B+1); false, b/B

PlotNames = {'','_PSlesion','_LMSlesion','_NMSlesion','_NMSandLMSlesion','_NonSlesion'};
ColorList = [0 0 0 % balck
    161 47 47 % red
    246 213 114 % yellow
    87 135 170 % dark blue
    194 229 255 % light blue
    159 160 160 % grey
    ]./255;

figure; set(gcf,'position',[0 100 680 300]);
subplot(1,2,1); hold on
data = cell(1,6); % collect for source data
numNeurons_Max = nan(1,numel(PlotNames));
Dim_AUC = cell(1,numel(PlotNames));
for i = 1:numel(PlotNames)
    load(['X:\DataAnalysis\Match_NMS_Dim\Left ALM\Adjusted' TaskTag '_CStarArray_MatchProp' PlotNames{i} '_Epoch' num2str(PlotEpoch) suffix '.mat'])
    numNeurons_Max(i) = max(numNeuronsList);
    switch TaskTag
        case 'TAs'
            plot_mean_and_sem(numNeuronsList,CStarArray_sL,ColorList(i,:),'-','shadow','se');
            Dim_AUC{i} = trapz(numNeuronsList,CStarArray_sL,2);  % Estimate AUC (Area Under Curve)
            data{i} = [numNeuronsList; mean(CStarArray_sL,1); std(CStarArray_sL,1)/sqrt(size(CStarArray_sL,1))];
            
        case 'TAr'
            plot_mean_and_sem(numNeuronsList,CStarArray_rL,ColorList(i,:),'-','shadow','se');
            Dim_AUC{i} = trapz(numNeuronsList,CStarArray_rL,2);  % Estimate AUC (Area Under Curve)
            data{i} = [numNeuronsList; mean(CStarArray_rL,1); std(CStarArray_rL,1)/sqrt(size(CStarArray_rL,1))];
    end
end
disp(['minimum_numNeurons: ' num2str(numNeurons_Max)])
xLimit = min([500 numNeurons_Max]);
set(gca,'tickdir','out','TickLength',[0.02, 0.03],'xlim',[50 xLimit],'xtick',50:100:xLimit)
ylabel('Number of dimensions')

% plot AUC
ax2 = subplot(1,2,2); hold on
for i = 1:numel(PlotNames)
    load(['X:\DataAnalysis\Match_NMS_Dim\Left ALM\Adjusted' TaskTag '_CStarArray_MatchProp' PlotNames{i} '_Epoch' num2str(PlotEpoch) suffix '.mat'])
    id = find(numNeuronsList<=xLimit);
    switch TaskTag
        case 'TAs'
            Dim_AUC{i} = trapz(numNeuronsList(id),CStarArray_sL(:,id),2);  % Estimate AUC (Area Under Curve)
        case 'TAr'
            Dim_AUC{i} = trapz(numNeuronsList(id),CStarArray_rL(:,id),2);  % Estimate AUC (Area Under Curve)
    end
end
nBar = numel(PlotNames);
switch AUCTag
    case 1 
        Dim_AUC_plot = Dim_AUC;
        ylabel('AUC')
    case 2 % minus black line
        Dim_AUC_plot = arrayfun(@(x) Dim_AUC{x}-mean(Dim_AUC{1}),1:nBar,'UniformOutput',false);
        ylabel('Relative AUC')
end
xloc = 1:nBar;
% plot median is more appropriate
h = percentile_boxplot(cell2mat(Dim_AUC_plot), ColorList, 0.3);
yline(0,'k--')
set(gca,'tickdir','out','TickLength',[0.02, 0.03],'xlim',[0 nBar+1],'xtick',xloc)
title(['AUC: before ' num2str(xLimit)])
% for insets, reset the size
ax2.Position = [0.60 0.1 0.35 0.55];  % [left bottom width height]

nBoot = 10000;
SideTag = 2;
p = arrayfun(@(x) permu_test(Dim_AUC_plot{1},Dim_AUC_plot{x}, nBoot, SideTag, MonteCarlo_correction),2:nBar);
% p = arrayfun(@(x) permu_test_studentized(Dim_AUC_plot{1},Dim_AUC_plot{x}, nBoot, SideTag, MonteCarlo_correction),2:nBar);

disp(['Bonferroni-corrected p-value, compared with black bar: ' num2str(p*numel(p))])
sgtitle({ ...
    sprintf('%s, Epoch%d, Corrected P:', TaskTag, PlotEpoch), ...
    sprintf('%.2g ', p*numel(p)) ...
    })

%% functions
function NeuralData_Adjusted = Catch_AdjustedNeuralData(NeuralData, sessId, CellTag_Adjusted)
    NeuralData_Adjusted = cell(numel(sessId),4);
    for iSess = 1:numel(sessId)
        SessOrig = sessId(iSess);
        % find cell in this session
        CellId = CellTag_Adjusted((CellTag_Adjusted(:,1)==iSess),2);
        for iType = 1:4
            NeuralData_Adjusted{iSess,iType} = NeuralData{SessOrig,iType}(CellId,:);
        end
    end
end
