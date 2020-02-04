function Real_RT_loop

[trial, RT_states, onset_state9] = frd_getRTs('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\CLSC\20200114\CLSC_2020-01-14_07.mat');
 
RealRT = [];
k = 0;
for j = 1:length(trial);
    
    if trial(j).success == 1 && trial(j).effector == 3
        
        k = k + 1;
        nice_saccade = [trial(j).RT.sac_onsets];
        nice_saccade_afterGo = nice_saccade(nice_saccade > onset_state9(j));
        
        RealRT(k) = nice_saccade_afterGo(1) - onset_state9(j);
        StateRT(k) = RT_states(j);
        TrialNumbers(k) = j;
        % continue
 
    
%         if trial(j).task.timing.mem_time_hold > 0
%            Mem_time_hold(j) = [trial(j).task.timing.mem_time_hold];
% 
%         end
    
    end
    
    
end
corrcoef(StateRT,RealRT)
plot(StateRT,RealRT,'o')
TrialNumbers
StateRT - RealRT


% RealRT(RealRT == 0) =[];
% RT_states(RT_states ==0) = [];
% Corr_Coeff_RT_States = corr2(RealRT, RT_states);

%  Mem_time_hold(j) = transpose([trial(j).task.timing.mem_time_hold]);
%         Mem_time =  transpose(Mem_time_hold);
%         Mem_time(Mem_time == 0) = [];





    
%  elseif trial(j).effector == 4 && trial(j).success == 0

% so geht es generell
% s = [];
% for i = 1:length(D)
%     
%     s = s + D(i);
%     
% end
%  RealRT = RealRT + trial(j);