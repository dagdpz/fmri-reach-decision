function frd_reach_detection(runpath, list_successful_only, plot_trials, detect_saccades,detect_saccades_custom_settings,plot_reach_detection)
% EXAMPLE: frd_reach_detection('Y:\Personal\Tihana\DAGU_2020-01-08_05.mat',1,4,1,'Y:\Personal\Tihana\Repos\fmri-reach-decision\em_custom_settings_humanUMGscannerTouchscreenXXHz.m')

% DATA: 'Y:\Personal\Tihana\DAGU_2020-01-08_05.mat'
% frd_reach_detection('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\CLSC\20200114\CLSC_2020-01-14_07.mat',1,4,1,'Y:\Personal\Tihana\Repos\fmri-reach-decision\frd_em_custom_settings_humanUMGscannerTouchscreen125Hz.m',1)
% CUSTUM_FILE: 'Y:\Personal\Tihana\Repos\fmri-reach-decision\em_custom_settings_humanUMGscannerTouchscreenXXHz.m'

% set plot_trial to 3 for only saccades or to 4 for only reaches

if nargin < 2,
    list_successful_only = 0;
end

if nargin < 3,
    plot_trials = 0;
end

if nargin < 4,
    detect_saccades = 0;
end

if nargin < 5,
    detect_saccades_custom_settings = '';
end

if nargin < 6,
    plot_reach_detection = 0;
end


load(runpath);
disp(runpath);


if plot_trials,
    hf = figure('Name','Plot trial','CurrentChar',' ');
end

if plot_reach_detection
    hf2 = figure('Name','Saccade detection','CurrentChar',' ');
end

for k = 1:length(trial),
    
    if plot_trials == 3 && trial(k).effector == 4
        continue;
    elseif plot_trials == 4 && trial(k).effector == 3
        continue;
    end
    
    if (list_successful_only && trial(k).success) || ~list_successful_only
        
        % align time axis to trial start
        trial(k).states_onset = trial(k).states_onset - trial(k).tSample_from_time_start(1);
        trial(k).tSample_from_time_start = trial(k).tSample_from_time_start - trial(k).tSample_from_time_start(1);
        
        
        if plot_trials,
            figure(hf);
            subplot(2,1,1); hold on;
            title(sprintf('Trial %d',...
                k));
            
            plot(trial(k).tSample_from_time_start,trial(k).state,'k');
            plot(trial(k).tSample_from_time_start,trial(k).x_hnd,'g');
            plot(trial(k).tSample_from_time_start,trial(k).y_hnd,'m');
            ig_add_multiple_vertical_lines(trial(k).states_onset,'Color','k');
            ylabel('Eye position, states');
            
            
            if detect_saccades % & k==30,
                if ~isempty(detect_saccades_custom_settings),
                    if plot_reach_detection,
                        figure(hf2);
                        % Interpolate to remove NaNs
                        idx_nonnan = find(~isnan(trial(k).x_hnd));
                        
                        t = trial(k).tSample_from_time_start(idx_nonnan(1):idx_nonnan(end));
                        x_ = trial(k).x_hnd(idx_nonnan(1):idx_nonnan(end));
                        y_ = trial(k).y_hnd(idx_nonnan(1):idx_nonnan(end));
                        
                        x = interp1(t(~isnan(x_)),x_(~isnan(x_)),t);
                        y = interp1(t(~isnan(x_)),y_(~isnan(y_)),t);
                        
                        
                        em_saccade_blink_detection(t,x,y,...
                            detect_saccades_custom_settings);
                    end
                else
                    em_saccade_blink_detection(trial(k).tSample_from_time_start,trial(k).x_hnd,trial(k).y_hnd,...
                        'Downsample2Real',0,'Plot',true,'OpenFigure',true);
                end
            end
            
            
            
            figure(hf);
            subplot(2,1,2)
            plot(trial(k).tSample_from_time_start,[NaN; diff(trial(k).tSample_from_time_start)],'k.');
            ylabel('Sampling interval');
            
        end
        
        
        if plot_trials,
            figure(hf);
            ig_set_all_axes('Xlim',[trial(k).tSample_from_time_start(1) trial(k).tSample_from_time_start(end)]);
            drawnow; pause;
            
            if get(gcf,'CurrentChar')=='q',
                % close;
                break;
            end
            clf(hf);
            if plot_reach_detection % plot saccade detection figure
                clf(hf2);
            end
        end
    end
    
end % for each trial

