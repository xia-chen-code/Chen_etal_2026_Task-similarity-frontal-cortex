function [DireTac, DireAud] = func_MeanDiffDire_Fold(Dtype, timewin, PSTHset, TrainId, TimeA, TaskTag, normalizeDire)

timeidx =  TimeA.time>=timewin(1) & TimeA.time<timewin(2);
% get averaged psth for compute direction, average over trial then over time
TrainPSTHforDire = arrayfun(@(x) mean(mean(PSTHset{x}(:,timeidx,TrainId{x}),3),2), 1:8, 'UniformOutput', false);

% calculate direction with mean-diff
switch Dtype
    case 'SD'
        %  === SD: sensory direction === right(CR,ER) - left(CL,EL)
        DireTac = (TrainPSTHforDire{2} + TrainPSTHforDire{4}) - (TrainPSTHforDire{1} + TrainPSTHforDire{3});
        DireAud = (TrainPSTHforDire{6} + TrainPSTHforDire{8}) - (TrainPSTHforDire{5} + TrainPSTHforDire{7});
    case 'ID'
        % === ID: sitmulus intensity direction === strong - weak
        switch TaskTag
            case 'TAs'
                DireTac = (TrainPSTHforDire{2} + TrainPSTHforDire{4}) - (TrainPSTHforDire{1} + TrainPSTHforDire{3});
                DireAud = (TrainPSTHforDire{6} + TrainPSTHforDire{8}) - (TrainPSTHforDire{5} + TrainPSTHforDire{7});
            case 'TAr'
                DireTac = (TrainPSTHforDire{2} + TrainPSTHforDire{4}) - (TrainPSTHforDire{1} + TrainPSTHforDire{3});
                DireAud = (TrainPSTHforDire{5} + TrainPSTHforDire{7}) - (TrainPSTHforDire{6} + TrainPSTHforDire{8});
        end
    case {'CD','AD'}
        % === CD: choice direction /or/ AD: action direction === CR,EL - CL,ER
        DireTac = (TrainPSTHforDire{2} + TrainPSTHforDire{3}) - (TrainPSTHforDire{1} + TrainPSTHforDire{4});
        DireAud = (TrainPSTHforDire{6} + TrainPSTHforDire{7}) - (TrainPSTHforDire{5} + TrainPSTHforDire{8});
    case 'OD'
        % === OD: outcome direction === correct - error
        DireTac = (TrainPSTHforDire{3} + TrainPSTHforDire{4}) - (TrainPSTHforDire{1} + TrainPSTHforDire{2});
        DireAud = (TrainPSTHforDire{7} + TrainPSTHforDire{8}) - (TrainPSTHforDire{5} + TrainPSTHforDire{6});
end

DireTac = DireTac/2 ;
DireAud = DireAud/2 ;

% transpose to row vector
if normalizeDire == 1
    DireTac = normalize(DireTac','norm',2);
    DireAud = normalize(DireAud','norm',2);
else
    DireTac = DireTac';
    DireAud = DireAud';
end