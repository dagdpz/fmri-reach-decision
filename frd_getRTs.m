function [trial, RT] = frd_getRTs(runpath, detect_SACCADES_custom_settings, detect_REACHES_custom_settings)
% 'Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\CLSC\20200114\CLSC_2020-01-14_07.mat'

load(runpath);
disp(runpath);

if nargin < 2,
	detect_SACCADES_custom_settings = 'frd_em_custom_settings_humanUMGscanner60Hz.m';
end

if nargin < 3,
	detect_REACHES_custom_settings = 'frd_em_custom_settings_humanUMGscannerTouchscreen125Hz.m';
end

RT = [];
for k = 1:length(trial);
    
    % align time axis to trial start
    trial(k).states_onset = trial(k).states_onset - trial(k).tSample_from_time_start(1);
    trial(k).tSample_from_time_start = trial(k).tSample_from_time_start - trial(k).tSample_from_time_start(1);
    
    
    if trial(k).effector == 3 && trial(k).success == 1 %saccades
        
        out = em_saccade_blink_detection(trial(k).tSample_from_time_start,trial(k).x_eye,trial(k).y_eye,...
            detect_SACCADES_custom_settings);
        
        trial(k).RT = out;
        
    elseif trial(k).effector == 4 && trial(k).success == 1% reaches
        % Interpolate to remove NaNs
        idx_nonnan = find(~isnan(trial(k).x_hnd));
        
        t = trial(k).tSample_from_time_start(idx_nonnan(1):idx_nonnan(end));
        x_ = trial(k).x_hnd(idx_nonnan(1):idx_nonnan(end));
        y_ = trial(k).y_hnd(idx_nonnan(1):idx_nonnan(end));
        
        x = interp1(t(~isnan(x_)),x_(~isnan(x_)),t);
        y = interp1(t(~isnan(x_)),y_(~isnan(y_)),t);
        
        
       out = em_saccade_blink_detection(t,x,y,...
            detect_REACHES_custom_settings);
        
        trial(k).RT = out;
    end
    
    if trial(k).success == 1
    RT(k,1)= trial(k).states_onset(trial(k).states==10) - trial(k).states_onset(trial(k).states==9); %%% CHANGE HERE
    end
end

