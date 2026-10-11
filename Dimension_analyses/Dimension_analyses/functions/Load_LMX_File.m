function [TAsFile, TArFile, Func_DispLMX] = Load_LMX_File(PlotEpoch, Area)

switch PlotEpoch
    case 1
        TAsFile = ['X:\PSTH\SglSess_' Area '\linear-non-lin\TAs_Regression_lmx_3way_winS_sample_TIC_UnitsMetrics_TrialOrder.mat'];
        TArFile = ['X:\PSTH\SglSess_' Area '\linear-non-lin\TAr_Regression_lmx_3way_winS_sample_TIC_UnitsMetrics_TrialOrder.mat'];
        Func_DispLMX = @get_mixed_lmx_all_anova;
    case 2
        TAsFile = ['X:\PSTH\SglSess_' Area '\linear-non-lin\TAs_Regression_lmx_3way_winS_delay_TIC_UnitsMetrics_TrialOrder.mat'];
        TArFile = ['X:\PSTH\SglSess_' Area '\linear-non-lin\TAr_Regression_lmx_3way_winS_delay_TIC_UnitsMetrics_TrialOrder.mat'];
        Func_DispLMX = @get_mixed_lmx_all_anova;
    case 3
        TAsFile = ['X:\PSTH\SglSess_' Area '\linear-non-lin\TAs_Regression_lmx_3way_winS_response_TCO_UnitsMetrics_TrialOrder.mat'];
        TArFile = ['X:\PSTH\SglSess_' Area '\linear-non-lin\TAr_Regression_lmx_3way_winS_response_TCO_UnitsMetrics_TrialOrder.mat'];
        Func_DispLMX = @get_mixed_lmx_TCO_all_anova;
end

end