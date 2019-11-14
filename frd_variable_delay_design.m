% function frd_variable_delay_desgn
% variable delay design

Performance = 0.9;

Delays = [3:3:15];
% Delays = [3:2:15];

nDelays = length(Delays);

Freq = ones(size(Delays))*1/nDelays; % uniform frequency
Freq = [0.075 0.15 0.25 0.275 0.25]; % ramping up
sumFreq = sum(Freq)

meanDelay = sum(Delays.*Freq)

FixAcq = 2;
FixCue = 12;
TarAcq = 1;
TarHold = 1;
ITI = 2;

totalTrialDur = FixAcq + FixCue + TarAcq + meanDelay + TarHold + ITI

runDur = 12*60; % s

maxTrialsRun = floor(runDur/totalTrialDur)
nDelaysRun = Freq*maxTrialsRun

nRuns = 15;

nTrialsConditionChoice = floor(Performance* 0.6*nRuns*maxTrialsRun/4)
nTrialsConditionInstr = floor(Performance*0.4*nRuns*maxTrialsRun/4)


