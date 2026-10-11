function [NonLinMixed,Pure,LinMixed,NonS,GoodFit]=get_mixed_lmx_TCO_all_anova(lmx,varargin)

if nargin == 2
    pAlpha = varargin{1};
else
    meanFR = varargin{1};
    pAlpha = varargin{2};
end

NonLinMixed = [];
Pure = [];
LinMixed = [];
NonS = [];
GoodFit = [];

for iU = 1:numel(lmx)
    %% check if model is significant
    lmx_anova = anova(lmx{iU},'summary');
    if lmx_anova('Model',:).pValue<pAlpha 
        GoodFit(end+1) = iU;
    end
    if nargin > 2
        if any([mean(meanFR(1:4,iU)) mean(meanFR(5:8,iU))]<0.001)
            continue;
        end
    end

    %% 
    % non-linear
    anova_results = anova(lmx{iU},'component',3);
    if anova_results{'Task:Choice','pValue'}<pAlpha || ...
            anova_results{'Task:Outcome','pValue'}<pAlpha || ...
            anova_results{'Choice:Outcome','pValue'}<pAlpha || ...
            anova_results{'Task:Choice:Outcome','pValue'}<pAlpha
        NonLinMixed(end+1) = iU;
    % linear
    else
        LinSigN = sum([anova_results{'Task','pValue'}<pAlpha anova_results{'Choice','pValue'}<pAlpha anova_results{'Outcome','pValue'}<pAlpha]);
        if LinSigN==1
            Pure(end+1) = iU;
        elseif LinSigN>1
            LinMixed(end+1) = iU;
        elseif LinSigN==0
            NonS(end+1) = iU;
        end
    end
end
