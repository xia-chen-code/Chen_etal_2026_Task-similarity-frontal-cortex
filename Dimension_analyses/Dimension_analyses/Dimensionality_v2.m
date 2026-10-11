% Compute dimensionality.
%
% v2: 
% - DO NOT concatenate NeuralData across sessions.
% - Use more trials for training set and test set.
% - Generate neural data for sample, delay and response epochs.
% - Neurons were randomly sampled regardless of their mixed-selectivity classification.
% Xia Chen (2024)

%% ===== Calculate and save NeuralData ===== 
TaskTag = 'TAs';
Area = 'LeftALM'; % 'LeftALM' or 'RightALM'

OrgFolder = 'X:\'; % Original folder for PSTH
PSTHFolder = [OrgFolder 'Data_' TaskTag '_' Area '\'];
Files = dir([PSTHFolder '*mat']);
SaveFolder = 'X:\DataAnalysis\Dimensionality\'; % change this to your own folder

TrialsThrC = 20; % threshold for correct trials
CellFilter.MetricsFRthr = 1; % >= 1spikes/s
CellFilter.DepthRange =  [-Inf 1200];
CellFilter.MetricsDur = [0.3 0.9];

% Initialize (S, D, R: sample, delay, response)
NeuralData_S = cell(numel(Files),4); % {sessions * conditions} units * trials 
NeuralData_D = cell(numel(Files),4);
NeuralData_R = cell(numel(Files),4); 

h = waitbar(0,'Get neural data for each session');
for iSess = 1:numel(Files)
    waitbar(iSess/numel(Files));
    disp(['===== Load session' num2str(iSess) ' =====']);
    % Load simulatenously recorded data.mat
    load([PSTHFolder Files(iSess).name]);

    % check trial number
    continueTag = func_check_Ntrial(Trials,TrialsThrC,{'TLC','TRC','ALC','ARC'});
    if continueTag == 1; disp('Not enough trials'); continue; end

    NeuralData_S(iSess,:) = getTimeAvgCData(PSTHs, Trials, Units, TimeA, CellFilter, TrialsThrC, [0 1], 0); % do not unify sessions
    NeuralData_D(iSess,:) = getTimeAvgCData(PSTHs, Trials, Units, TimeA, CellFilter, TrialsThrC, [1 2], 0);
    NeuralData_R(iSess,:) = getTimeAvgCData(PSTHs, Trials, Units, TimeA, CellFilter, TrialsThrC, [2 3], 0);
end
clear PSTHs Trials Units TimeA
close(h)
save([SaveFolder TaskTag '_' Area '_NeuralDataForDim_NotSessUnified.mat'],'NeuralData_S','NeuralData_D','NeuralData_R','CellFilter', 'TrialsThrC')

%% ===== Get dimentionality with neuron number ===== 
DataSet = {'NeuralData_S','NeuralData_D','NeuralData_R'};
NeuronTag = getNeuronTag(NeuralData_S);
N = size(NeuronTag,1);
numNeuronsList = 50:50:N;
Repeats = 1000; % # of repeats for sampling neurons
Kfold = 10; % k-fold cross-validation

CStarArray = cell(1,3);
for iSet = 1:3
    DataInput = eval(DataSet{iSet});
    CStarArray{iSet} = getNcDimVsNeurons_v2(DataInput, numNeuronsList, Kfold, Repeats); % repeats * neuronlist
end
clear DataInput
save([SaveFolder TaskTag '_' Area '_CStarArray_SDR.mat'],'numNeuronsList','Kfold', 'Repeats', 'CStarArray')

%% =============== PLOT ===============

%% Run before plot
SaveFolder = 'X:\DataAnalysis\Dimensionality\';
FileList = {[SaveFolder 'TAs_LeftALM_CStarArray_SDR.mat'], ...
    [SaveFolder 'TAr_LeftALM_CStarArray_SDR.mat'], ...
    [SaveFolder 'TAs_RightALM_CStarArray_SDR.mat'], ...
    [SaveFolder 'TAr_RightALM_CStarArray_SDR.mat']};
ColorTAsTAr; 
ColorSet = [ColorTAs; ColorTAr; ColorTAs; ColorTAr];

%% Plot dimensionality with neuron number
Epoch = 3;
xmax = 600;

LineSet = {'--', '--','-', '-',}; % left ALM: dash line; right ALM: solid line
figure; hold on
for iF = 1:numel(FileList)
    load(FileList{iF});
    plot_mean_and_sem(numNeuronsList,CStarArray{Epoch},ColorSet(iF,:),LineSet{iF},'shadow','se'); % Alternatively, use any other plotting function of your choice.
end
ylabel('Number of dimensions')
xlabel('Number of neurons')
set(gcf,'position',[100 100 300 250])
set(gca,'TickDir','out','TickLength',[0.02 0.04],'ytick',1:4)
xlim([50 xmax])

%% Plot quantification
% plot sample, delay, and response in the same figure. 
% plot left and right ALM in different panels. (upper panel, left ALM; lower panel, right ALM)

figure(2); clf; set(gcf,'position',[100 100 330 360]) 
figure(3); clf; set(gcf,'position',[100 100 330 360]) 
xloc = [1 2; 4 5; 7 8];
SelfLimit = [600 600 600]; % set xlim [sample delay response]

for Epoch = 1:3
    % initialize
    numNeurons_Max = nan(1,numel(FileList));
    numNeuronsListSet = cell(1,numel(FileList));
    Dim_AUC = cell(1,numel(FileList));
    Idx_set = cell(1,numel(FileList));

    % ======= Fig 2: plot Number of neurons to reach maximum dimensionality =======
    for iF = 1:numel(FileList)
        load(FileList{iF});
        numNeurons_Max(iF) = max(numNeuronsList);
        numNeuronsListSet{iF} = numNeuronsList;
        % Find x_index when dimensionality reaches maxD (i.e, max-dimensionality: 4)
        Idx_set{iF} = arrayfun(@(x) find_v_maxD(CStarArray{Epoch}(x,:),4,0), 1:size(CStarArray{Epoch},1));
    end

    numNeurons = arrayfun(@(x) numNeuronsListSet{x}(Idx_set{x}), (1:4)', 'UniformOutput', false);
    means = cellfun(@mean, numNeurons);
    errs = cellfun(@(x) std(x)./sqrt(numel(x)),numNeurons); % SE
    arrayfun(@(x) disp([num2str(means(x)) '+-' num2str(errs(x))]),1:4)

    figure(2); 
    subplot(2,1,1); hold on;
    bar(xloc(Epoch,1),means(1),'FaceColor','flat','BarWidth',0.6, 'LineWidth',1, 'EdgeColor',ColorTAs,'FaceColor',ColorTAs);
    bar(xloc(Epoch,2),means(2),'FaceColor','flat','BarWidth',0.6, 'LineWidth',1, 'EdgeColor',ColorTAr,'FaceColor',ColorTAr);
    errorbar(xloc(Epoch,:),means(1:2),errs(1:2),'ok');

    subplot(2,1,2); hold on;
    bar(xloc(Epoch,1),means(3),'FaceColor','flat','BarWidth',0.6, 'LineWidth',1, 'EdgeColor',ColorTAs,'FaceColor',ColorTAs);
    bar(xloc(Epoch,2),means(4),'FaceColor','flat','BarWidth',0.6, 'LineWidth',1, 'EdgeColor',ColorTAr,'FaceColor',ColorTAr);
    errorbar(xloc(Epoch,:),means(3:4),errs(3:4),'ok');

    % ======= Fig 3: plot AUC (Area Under Curve) =======
    xLimit = SelfLimit(Epoch);
    for iF = 1:numel(FileList)
        load(FileList{iF});
        id = find(numNeuronsList<=xLimit);
        Dim_AUC{iF} = trapz(numNeuronsList(id),CStarArray{Epoch}(:,id),2);  % Estimate AUC
    end
    means = cellfun(@mean, Dim_AUC);
    errs = cellfun(@(x) std(x)./sqrt(numel(x)),Dim_AUC); % SE

    figure(3); 
    subplot(2,1,1);hold on;
    bar(xloc(Epoch,1),means(1),'FaceColor','flat','BarWidth',0.6, 'LineWidth',1, 'EdgeColor',ColorTAs,'FaceColor',ColorTAs);
    bar(xloc(Epoch,2),means(2),'FaceColor','flat','BarWidth',0.6, 'LineWidth',1, 'EdgeColor',ColorTAr,'FaceColor',ColorTAr);
    errorbar(xloc(Epoch,:),means(1:2),errs(1:2),'ok');
    
    subplot(2,1,2);hold on;
    bar(xloc(Epoch,1),means(3),'FaceColor','flat','BarWidth',0.6, 'LineWidth',1, 'EdgeColor',ColorTAs,'FaceColor',ColorTAs);
    bar(xloc(Epoch,2),means(4),'FaceColor','flat','BarWidth',0.6, 'LineWidth',1, 'EdgeColor',ColorTAr,'FaceColor',ColorTAr);
    errorbar(xloc(Epoch,:),means(3:4),errs(3:4),'ok');

end

XTicklabels = {'TAs','TAr','TAs','TAr','TAs','TAr'};
figure(2);
subplot(2,1,1);ylabel({'# of neurons to reach'; ' maximum dimensionality'});set(gca,'xtick',reshape(xloc',1,[]),'xticklabel',XTicklabels,'TickDir','out','Ticklength',[0.02 0.02])
subplot(2,1,2);ylabel({'# of neurons to reach'; ' maximum dimensionality'});set(gca,'xtick',reshape(xloc',1,[]),'xticklabel',XTicklabels,'TickDir','out','Ticklength',[0.02 0.02])
figure(3);
subplot(2,1,1);ylabel('AUC');set(gca,'xtick',reshape(xloc',1,[]),'xticklabel',XTicklabels,'TickDir','out','Ticklength',[0.02 0.02],'ylim',[1900 2200])
subplot(2,1,2);ylabel('AUC');set(gca,'xtick',reshape(xloc',1,[]),'xticklabel',XTicklabels,'TickDir','out','Ticklength',[0.02 0.02],'ylim',[1900 2200])

%% Function used for quantification 
function idx_maxD = find_v_maxD(V, maxD, ContinuousTag)
    % V: 1 × x vector
    idx_maxD = [];

    if ContinuousTag == 1
        % Find three consecutive points reaching maxD
        for i = 1:(numel(V)-2)
            if all(V(i:i+2) == maxD)
                idx_maxD = i;
                return;
            end
        end
    else
        % Find first point reaching maxD
        idx = find(V == maxD, 1, 'first');
        if ~isempty(idx)
            idx_maxD = idx;
        end
    end
end