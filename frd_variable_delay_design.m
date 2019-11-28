%% function frd_variable_delay_desgn

%% variable delay design

Performance = 1;

Delays = [3:3:15];
% Delays = [3:2:15];

nDelays = length(Delays);

% Freq = ones(size(Delays))*1/nDelays; % uniform frequency
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

%% fixed delay + Catch trials

if 0
Performance = 0.9;

% real trials
tmeanDelay = 12;

% catch trials
cTrials_upperLimit = tmeanDelay-2;
cTrials_lowerLimit = 3;
cmeanDelay = (cTrials_upperLimit + cTrials_lowerLimit)/2;
cProportion = 0.2;

% periods
FixAcq = 2;
FixCue = 12;
TarAcq = 1;
TarHold = 1;
ITI = 2;

totalTrialDur = FixAcq + FixCue + TarAcq + tmeanDelay*(1-cProportion) + cmeanDelay*cProportion + TarHold + ITI

nRuns = 15;
runDur = 12*60; %s
maxTrialsRun = floor(runDur/totalTrialDur)
maxTrialsExp = nRuns*maxTrialsRun

n_tTrials = (1-cProportion)*maxTrialsRun
n_cTrials = cProportion*maxTrialsRun
example_lengths_cTrials_pRun = rand(1,round(n_cTrials))*(cTrials_upperLimit - cTrials_lowerLimit)+ cTrials_lowerLimit
example_lengths_cTrials_pExp = rand(1,round(n_cTrials)*nRuns)*(cTrials_upperLimit - cTrials_lowerLimit)+ cTrials_lowerLimit;

plot(sort(example_lengths_cTrials_pExp),'*')
hold on
plot(sort(example_lengths_cTrials_pRun),'*','Color','r')
hold off

% here, for choice and instructed trials seperately, for the whole
% experiment, with the given expected performance, the number of "real"
% trials (not catch trials) is being calculated
nTrialsConditionChoice_realTrials = floor(Performance* 0.6*(nRuns*maxTrialsRun - length(example_lengths_cTrials_pExp))/4) 
nTrialsConditionInstr_realTrials = floor(Performance*0.4*(nRuns*maxTrialsRun - length(example_lengths_cTrials_pExp))/4)
end
