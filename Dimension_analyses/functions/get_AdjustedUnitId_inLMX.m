function [UnitId_inLMX, CellTag_Adjusted]= get_AdjustedUnitId_inLMX(NonLinMixed, Pure, LinMixed, NonS, AdjTag)

NMS_Tag = Catch_CellTag(NonLinMixed);
Pure_Tag = Catch_CellTag(Pure);
LinMixed_Tag = Catch_CellTag(LinMixed);
NonS_Tag = Catch_CellTag(NonS);

% AdjTag (Tag for Adjusted):
% 1. all population
% 2. NMS lesion
% 3. LMS lesion
% 4. PS lesion
% 5. NonS lesion
% 6. NMS and LMS lesion

switch AdjTag
    case 1 % 1. all population
        CellTag_Adjusted = [NMS_Tag; Pure_Tag; LinMixed_Tag; NonS_Tag];
        UnitId_inLMX = {NonLinMixed, Pure, LinMixed, NonS};

    case 2 % 2. NMS lesion
        CellTag_Adjusted = [Pure_Tag; LinMixed_Tag; NonS_Tag];
        UnitId_inLMX = {Pure, LinMixed, NonS};

    case 3 % 3. LMS lesion
        CellTag_Adjusted = [NMS_Tag; Pure_Tag; NonS_Tag];
        UnitId_inLMX = {NonLinMixed, Pure, NonS};

    case 4 % 4. PS lesion
        CellTag_Adjusted = [NMS_Tag; LinMixed_Tag; NonS_Tag];
        UnitId_inLMX = {NonLinMixed, LinMixed, NonS};

    case 5 % 5. NonS lesion
        CellTag_Adjusted = [NMS_Tag; Pure_Tag; LinMixed_Tag];
        UnitId_inLMX = {NonLinMixed, Pure, LinMixed};

    case 6 % 6. NMS and LMS lesion
        CellTag_Adjusted = [Pure_Tag; NonS_Tag];
        UnitId_inLMX = {Pure, NonS};

end

function CellTag = Catch_CellTag(CellId_inSess)
    % CellId_inSess: e.g. NonLinMixed_rL, Pure_rL, LinMixed_rL, NonS_rL, GoodFit_rL
    SessTag = arrayfun(@(x) repmat(x, numel(CellId_inSess{x}),1), 1:numel(CellId_inSess),'UniformOutput',false);
    CellTag = [cell2mat(SessTag') transpose(cell2mat(CellId_inSess))];
end

end