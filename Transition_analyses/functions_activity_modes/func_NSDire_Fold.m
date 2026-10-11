function [DireTac, DireAud] = func_NSDire_Fold(timewin1, timewin2, PSTHset, TrainId, TimeA, normalizeDire)
% get non-selective direction for single session
% only use correct trials

timeidx1 =  TimeA.time>=timewin1(1) & TimeA.time<timewin1(2);
timeidx2 =  TimeA.time>=timewin2(1) & TimeA.time<timewin2(2);

% get averaged psth for compute direction, average over trial then over time
TrainPSTHforDire1 = arrayfun(@(x) mean(mean(PSTHset{x}(:,timeidx1,TrainId{x}),3),2), 1:8, 'UniformOutput', false);
TrainPSTHforDire2 = arrayfun(@(x) mean(mean(PSTHset{x}(:,timeidx2,TrainId{x}),3),2), 1:8, 'UniformOutput', false);

% get direction (activity in timewin2 - in timewin1)
DireTac = (TrainPSTHforDire2{1} + TrainPSTHforDire2{2}) - (TrainPSTHforDire1{1} + TrainPSTHforDire1{2});
DireTac(isnan(DireTac)) = 0;
DireAud = (TrainPSTHforDire2{5} + TrainPSTHforDire2{6}) - (TrainPSTHforDire1{5} + TrainPSTHforDire1{6});
DireAud(isnan(DireAud)) = 0;

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