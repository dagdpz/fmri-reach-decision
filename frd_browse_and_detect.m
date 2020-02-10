function frd_browse_and_detect (runpath, list_successful_only,which_effector, plot_trials ,detect_movements,plot_movement_detection,detect_saccades_custom_settings,detect_reaches_custom_settings)

% runpath:              A) specific matfile,    B) session folder   C) subject folder    D) experiment folder
% list_successful_only: 0) all trials           1) successful only  2) failed only
% only_reaches_or_sa    1) all trials           3) only saccades     4) only reaches
% plot_trials:          0) no plots of single trials                1) plots every single trial in 1D    2) plots every single trial in 2D


if nargin < 2,
    list_successful_only = 0;
end

if nargin < 3,
    which_effector = 1;
end

if nargin < 4,
    plot_trials = 0;
end

if nargin < 5,
    detect_movements = 0;
end

if nargin < 6,
    plot_movement_detection = 0;
end

if nargin < 7,
    detect_saccades_custom_settings = 'frd_em_custom_settings_humanUMGscanner60Hz.m';
end

if nargin < 8,
    detect_reaches_custom_settings = 'frd_em_custom_settings_humanUMGscannerTouchscreen125Hz.m';
end


load(runpath);
disp(runpath);

if plot_trials,
    hf = figure('Name','Plot trial','CurrentChar',' ');
end

if plot_movement_detection
    hf2 = figure('Name','Saccade detection','CurrentChar',' ');
end



%% Plotting every single trial in 1 D

if plot_trials == 1,
    hf = figure('Name','Plot trial','CurrentChar',' ');
end

for k = 1:length(trial)
    
    if which_effector == 3 && trial(k).effector == 4
        continue;
    elseif which_effector == 4 && trial(k).effector == 3
        continue;
    end
    
    if (list_successful_only == 1 && trial(k).success) || ~list_successful_only || (list_successful_only==2 && ~trial(k).success) % entweder alle erfolgreichen oder alle trials
        
        % align time axis to trial start
        trial(k).states_onset            = trial(k).states_onset            - trial(k).tSample_from_time_start(1); % setze die states_onsets auf "Null"(nicht wirklich, da irgendwie nicht wirklich 0)
        trial(k).tSample_from_time_start = trial(k).tSample_from_time_start - trial(k).tSample_from_time_start(1); % setze den Beginn des Trials auf 0
        
        
        if plot_trials == 1,
            figure(hf);
            subplot(2,1,1); hold on;
            title([sprintf('Eye/Hand Position, Trial %d',k)]); %,...
            %                 cellstr(trial(k).effector),...
            %                 cellstr(RT.choice(k)),...
            %                 cellstr(RT.target_selected(k)),...
            %                 cellstr(RT.abort_code(k)),...
            %                 {RT.aborted_state_duration(k)},...
            %                ]);
            
            
            % eye and hand trajectories
            plot(trial(k).tSample_from_time_start,trial(k).x_eye,'g');
            plot(trial(k).tSample_from_time_start,trial(k).y_eye,'m');
            plot(trial(k).tSample_from_time_start,trial(k).x_hnd,'g','Color',[0.2314    0.4431    0.3373],'LineWidth',2);
            plot(trial(k).tSample_from_time_start,trial(k).y_hnd,'m','Color',[0.5137    0.3804    0.4824],'LineWidth',2);
            
            xlim = get(gca,'Xlim');
            
            % horizontal lines for fixation radius eye + hnd (RED)
            line([0 xlim(2)],[trial(k).task.eye.fix.radius    trial(k).task.eye.fix.radius],   'Color','r','LineStyle',':');
            line([0 xlim(2)],[trial(k).task.eye.fix.radius*-1 trial(k).task.eye.fix.radius*-1],'Color','r','LineStyle',':');
            line([0 xlim(2)],[trial(k).task.hnd.fix.radius    trial(k).task.hnd.fix.radius],   'Color','r','LineStyle',':');
            line([0 xlim(2)],[trial(k).task.hnd.fix.radius*-1 trial(k).task.hnd.fix.radius*-1],'Color','r','LineStyle',':');
            
            if trial(k).effector == 3
                lower_1 = trial(k).task.eye.tar(1).x - trial(k).task.eye.tar(1).radius;
                upper_1 = trial(k).task.eye.tar(1).x + trial(k).task.eye.tar(1).radius;
                lower_2 = trial(k).task.eye.tar(2).x - trial(k).task.eye.tar(2).radius;
                upper_2 = trial(k).task.eye.tar(2).x + trial(k).task.eye.tar(2).radius;
                
            elseif trial(k).effector == 4
                lower_1 = trial(k).task.hnd.tar(1).x - trial(k).task.hnd.tar(1).radius;
                upper_1 = trial(k).task.hnd.tar(1).x + trial(k).task.hnd.tar(1).radius;
                lower_2 = trial(k).task.hnd.tar(2).x - trial(k).task.hnd.tar(2).radius;
                upper_2 = trial(k).task.hnd.tar(2).x + trial(k).task.hnd.tar(2).radius;
            end
            
            % horizontal lines for targets for respective effector (BLACK)
            line([0 xlim(2)], [lower_1 lower_1], 'Color','k','LineStyle',':');
            line([0 xlim(2)], [upper_1 upper_1], 'Color','k','LineStyle',':');
            line([0 xlim(2)], [lower_2 lower_2], 'Color','k','LineStyle',':');
            line([0 xlim(2)], [upper_2 upper_2], 'Color','k','LineStyle',':');
            
            % vertical lines for state_onsets
            plot(trial(k).tSample_from_time_start,trial(k).state,'k');
            ylim([-14 14])
            ig_add_multiple_vertical_lines(trial(k).states_onset,'Color','k');
            
            ylabel('Eye/Hand position, states');
            
            if detect_movements
                
                % saccade detection
                if trial(k).effector == 3
                    if ~isempty(detect_saccades_custom_settings),
                        if plot_movement_detection,
                            figure(hf2);
                            em_saccade_blink_detection(trial(k).tSample_from_time_start,trial(k).x_eye,trial(k).y_eye,...
                                detect_saccades_custom_settings);
                        end
                    else
                        em_saccade_blink_detection(trial(k).tSample_from_time_start,trial(k).x_eye,trial(k).y_eye,...
                            'Downsample2Real',0,'Plot',true,'OpenFigure',true);
                    end
                    
                    
                    % reach detection
                elseif trial(k).effector == 4  % & k==30,
                    if ~isempty(detect_reaches_custom_settings),
                        
                        if plot_movement_detection,
                            figure(hf2);
                        end
                        % Interpolate to remove NaNs
                        idx_nonnan = find(~isnan(trial(k).x_hnd));
                        
                        t = trial(k).tSample_from_time_start(idx_nonnan(1):idx_nonnan(end));
                        x_ = trial(k).x_hnd(idx_nonnan(1):idx_nonnan(end));
                        y_ = trial(k).y_hnd(idx_nonnan(1):idx_nonnan(end));
                        
                        x = interp1(t(~isnan(x_)),x_(~isnan(x_)),t);
                        y = interp1(t(~isnan(x_)),y_(~isnan(y_)),t);
                        
                        
                        em_saccade_blink_detection(t,x,y,...
                            detect_reaches_custom_settings);
                        
                        
                    else
                        em_saccade_blink_detection(trial(k).tSample_from_time_start,trial(k).x_hnd,trial(k).y_hnd,...
                            'Downsample2Real',0,'Plot',true,'OpenFigure',true);
                    end
                    
                end % reach or saccade detection
            end % if detect movements
                
                figure(hf);
                subplot(2,1,2)
                plot(trial(k).tSample_from_time_start,[NaN; diff(trial(k).tSample_from_time_start)],'k.');
                ylabel('Sampling interval');
                
            end
            
            
            if plot_trials == 1,
                figure(hf);
                ig_set_all_axes('Xlim',[trial(k).tSample_from_time_start(1) trial(k).tSample_from_time_start(end)]);
                drawnow; pause;
                
                if get(gcf,'CurrentChar')=='q',
                    % close;
                    break;
                end
                clf(hf);
                if plot_movement_detection
                    clf(hf2);
                end
                
                
            end % if plot == 1 
        end % if successful....  
end % for trial loop


%% Plotting every single trial in 2 D

if plot_trials == 2,
    hf = figure('Name','Plot trial','CurrentChar',' ');
end

for k = 1:length(trial)
    
    if which_effector == 3 && trial(k).effector == 4
        continue;
    elseif which_effector == 4 && trial(k).effector == 3
        continue;
    end
    
    if list_successful_only ~= 1 && plot_trials == 2
        disp('Can only list succesfull trials. Completed but not succesfull trials (WRONG TARGET SELECTED) are ignored so far.')
        break;
        
    elseif (list_successful_only == 1 && trial(k).success)
        
        % align time axis to trial start
        trial(k).states_onset            = trial(k).states_onset            - trial(k).tSample_from_time_start(1); % setze die states_onsets auf "Null"(nicht wirklich, da irgendwie nicht wirklich 0)
        trial(k).tSample_from_time_start = trial(k).tSample_from_time_start - trial(k).tSample_from_time_start(1); % setze den Beginn des Trials auf 0
        
        
        if plot_trials == 2,
            figure(hf);
            hold on;
            title([sprintf('Eye/Hand Position, Trial %d',k)]); %,...
            %                 cellstr(RT.effector(k)),...
            %                 cellstr(RT.choice(k)),...
            %                 cellstr(RT.target_selected(k)),...
            %                 cellstr(RT.abort_code(k)),...
            %                 {RT.aborted_state_duration(k)},...
            %                 ]);
            
            % filter for only target acquisition + hold phase
            fil = trial(k).state == 9 | trial(k).state == 10;
            
            % plot eye or hand trajectories
            
            plot(trial(k).x_eye(fil),trial(k).y_eye(fil),'r');
            plot(trial(k).x_hnd(fil),trial(k).y_hnd(fil),'g');
            
            
            
            % plot rectangles
            if trial(k).effector ==3
                x_left_lower_corner_sq_1    = trial(k).task.eye.tar(1).x - (trial(k).task.eye.tar(1).radius);
                x_left_lower_corner_sq_2    = trial(k).task.eye.tar(2).x - (trial(k).task.eye.tar(2).radius);
                y_left_lower_corner_sq_both = -(trial(k).task.eye.tar(2).radius);
                width_sq                    = trial(k).task.eye.tar(1).radius * 2;
                
                x_left_lower_corner_sq_1_size    = trial(k).task.eye.tar(1).x - (trial(k).task.eye.tar(1).size);
                x_left_lower_corner_sq_2_size    = trial(k).task.eye.tar(2).x - (trial(k).task.eye.tar(2).size);
                y_left_lower_corner_sq_both_size = -(trial(k).task.eye.tar(2).size);
                width_sq_size                    = trial(k).task.eye.tar(1).size * 2;
                
                rectangle('Position',[x_left_lower_corner_sq_1_size, y_left_lower_corner_sq_both_size, width_sq_size, width_sq_size],'LineStyle','-.');
                rectangle('Position',[x_left_lower_corner_sq_2_size, y_left_lower_corner_sq_both_size, width_sq_size, width_sq_size],'LineStyle','-.');
                
            elseif trial(k).effector == 4
                x_left_lower_corner_sq_1    = trial(k).task.hnd.tar(1).x - (trial(k).task.hnd.tar(1).radius);
                x_left_lower_corner_sq_2    = trial(k).task.hnd.tar(2).x - (trial(k).task.hnd.tar(2).radius);
                y_left_lower_corner_sq_both = -(trial(k).task.hnd.tar(2).radius);
                width_sq = trial(k).task.hnd.tar(1).radius * 2;
            end
            
            rectangle('Position',[x_left_lower_corner_sq_1, y_left_lower_corner_sq_both, width_sq, width_sq],'LineStyle',':');
            rectangle('Position',[x_left_lower_corner_sq_2, y_left_lower_corner_sq_both, width_sq, width_sq],'LineStyle',':');
            
            circle(trial(k).task.eye.fix.x, trial(k).task.eye.fix.y, trial(k).task.eye.fix.radius);
            circle(trial(k).task.hnd.fix.x, trial(k).task.hnd.fix.y, trial(k).task.hnd.fix.radius);
            
            figure(hf);
            ig_set_all_axes('Xlim',[-15 15]);
            ig_set_all_axes('Ylim',[-9 9]);
            drawnow; pause;
            
            if get(gcf,'CurrentChar')=='q',
                close;
                break;
            end
            clf(hf);
        end
        
    end % if successful..
    
end % for each trial





function circle(x,y,r)
%x and y are the coordinates of the center of the circle
%r is the radius of the circle
%0.01 is the angle step, bigger values will draw the circle faster but
%you might notice imperfections (not very smooth)
ang=0:0.01:2*pi;
xp=r*cos(ang);
yp=r*sin(ang);
plot(x+xp,y+yp,'LineStyle',':','Color','k');





