%% cos angle between tactile and auditory CD
TaskTag = 'TAr';
Area = 'LeftALM';
% Area = 'RightALM';
Folder = ['X:\PSTH\SglSess_' Area '\'];
SaveFile = ['X:\PSTH\Trial_averaged_ForMDS\' TaskTag '_' Area '_trial_averaged_PSTHs_forMDS_V.mat'];

load(SaveFile, 'AvgPSTH', 'time', 'TrialNames')

%% Plot heatmap of angles between tactile and auditory coding directions for single session
TimeBound = [-1 4];
TimeWin = 200;
StepWin = 50;
SmoothWin = 1;

PlotType = 2; % 1: pi to 0, 2: cos(theta)
[AglCrt, AglErr, Time_points] = ComputeAgl_TA_CodingDirection_PlotLine(AvgPSTH, TimeBound, TimeWin, StepWin, SmoothWin, TrialNames, time, PlotType);
set(gcf,'Renderer','painters','position',[0 500 600 220]); 

%% plot TAs and TAr
% figure; hold on
ColorTAsTAr;
ColorPlot = eval(['Color' TaskTag]);
% plot_mean_and_sem(time, cell2mat(AglCrt),ColorPlot,'-');
% plot_mean_and_sem(time, cell2mat(AglErr),ColorPlot,'--');
plot_median_and_sem(Time_points, cell2mat(AglCrt),ColorPlot,'-');
plot_median_and_sem(Time_points, cell2mat(AglErr),ColorPlot,'--');
xlim([-1 4]); xline([0 1 2],'k--'); ylim([-1 1])
set(gca,'TickLength',[0.02, 0.01], 'YTick', [-1 0 1], 'YTickLabel', {-1 0 1}, ...
    'XTick', [0 1 2], 'XTickLabel', {0 1 2},'Box','off', 'TickDir','out');
set(gcf,'Renderer','painters','position',[0 100 300 220]); 
