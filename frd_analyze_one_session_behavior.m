function frd_analyze_one_session_behavior(runpath, list_successful_only, plot_trials, do_summary, detect_saccades,detect_saccades_custom_settings)
% What to put in:

% runpath: A) specific matfile, B) session folder
% list_successful_only: 0) all trials 1) successful only 2) failed only
% plot_trials: 0) no plotting of single trials 1) plots every single trial
% do_summary: 0) no summary plots 1) summary plots
% detect saccades: idk
% detect_saccades_custom_settings: idk


% TODO:
% figure size
% title with subj/session
% export to pdf properly
% subject wise analysis + whole experiment analysis



if nargin < 2,
    list_successful_only = 0; 
end

if nargin < 3,
    plot_trials = 0;
end

if nargin < 4,
    do_summary = 1;
end

if nargin < 5,
    detect_saccades = 0;
end

if nargin < 6,
    detect_saccades_custom_settings = '';
end


%warning off

%%
% list_successful_only = 1; % 0 - list all, 1 - only successful, 2 - only not successful
% plot_trials = 0;
% do_summary = 1;
% detect_saccades = 0;
% detect_saccades_custom_settings = '';
% runpath = ('Y:\MRI\Human\fMRI-reach-decision\Pilot\behavioral data\LEHU\all_runs');
% % load('Y:\MRI\Human\fMRI-reach-decision\Pilot\behavioral data\LEHU\all_runs\LEHU_2019-07-24_02.mat');
%% concatenate matfiles
% with additional info of run, files, and location

if isempty(strfind(runpath,'.mat')), % folder
    
    fi  = dir([runpath filesep '*.mat']); % How many mat files are there
    temp = load([runpath filesep fi(1).name]); % load first file
    [temp.trial(:).run] = deal(1); % add run number
    [temp.trial(:).fileinfo] = deal(fi(1)); % add fileinfo
    [temp.trial(:).path] = deal([runpath filesep fi(1).name]); % add path
    tempges = temp.trial; % take only variable trial and save it
    
    for i = 2:length(fi)
        
        temp =  load([runpath filesep fi(i).name]);
        [temp.trial(:).run] = deal(i);
        [temp.trial(:).fileinfo] = deal(fi(i));
        [temp.trial(:).path] = deal([runpath filesep fi(i).name]);
        
        tempges = [tempges temp.trial];
        
    end
    
    trial = tempges;
    clear ('temp','tempges');
    
else % one run
    load(runpath);
    [trial.run] = deal(1); % add run number
end
%% Define new and correct states and states_onset

for k = 1:length(trial)
    
    trial(k).states = unique(trial(k).state,'stable')';
    
    indi = logical([1 (diff(trial(k).state) ~= 0)']);
    trial(k).states_onset = trial(k).tSample_from_time_start(indi)';
    
end

%% create reaction time and such

RT= (NaN(length(trial),2));

for k = 1:length(trial)
    
    if trial(k).completed
        RT(k,1)= trial(k).states_onset(trial(k).states==10) - trial(k).states_onset(trial(k).states==9); %%% CHANGE HERE
    end
    
    
    if trial(k).task.correct_choice_target == [1 2]
        RT(k,2) = 1;
    elseif trial(k).task.correct_choice_target == 1
        RT(k,2) = 0;
    end
    
    
end % for each trial


RT = array2table(RT);
RT.Properties.VariableNames  = {'value' 'choice'};
%RT.choice = categorical(RT.choice);
RT.choice = categorical(RT.choice, [0 1], {'instructed' 'choice'});
RT.completed = logical([trial.completed]');
RT.success = logical([trial.success]');
RT.effector = [trial.effector]';
RT.number = [1:length(RT.success)]';
RT.run = categorical([trial.run]');

RT.cause_abort = cell(height(RT),1);
RT.cause_abort(strncmpi('ABORT_EYE',{trial.abort_code}',9)) = {'eye_cause'};
RT.cause_abort(strncmpi('ABORT_HND',{trial.abort_code}',9)) = {'hand_cause'};

valueset  = {
    'ABORT_EYE_FIX_ACQ_STATE'
    'ABORT_HND_FIX_ACQ_STATE'
    
    'ABORT_EYE_FIX_HOLD_STATE'
    'ABORT_HND_FIX_HOLD_STATE'
    
    'ABORT_EYE_CUE_ON'
    'ABORT_HND_CUE_ON'
    
    'ABORT_EYE_TAR_ACQ_STATE' % wenn dya.time_spent_in_state < 0.2
    'ABORT_HND_TAR_ACQ_STATE' % ???
    
    'ABORT_EYE_MEM_PER_STATE'
    'ABORT_HND_MEM_PER_STATE'
    
    'ABORT_EYE_TAR_ACQ_INV_STATE'
    'ABORT_HND_TAR_ACQ_INV_STATE'
    
    'ABORT_EYE_TAR_HOLD_INV_STATE'
    'ABORT_HND_TAR_HOLD_INV_STATE'
    
    'ABORT_WRONG_TARGET_SELECTED'
    'NO ABORT'
    };

names = {
    'EYE FIX ACQ'
    'HND FIX ACQ'
    
    'EYE FIX HOLD'
    'HND FIX HOLD'
    
    'EYE CUE ON'
    'HND CUE ON'
    
    'EYE TAR ACQ' % wenn dya.time_spent_in_state < 0.2
    'HND TAR ACQ' % ???
    
    'EYE MEM PER'
    'HND MEM PER'
    
    'EYE TAR ACQ INV'
    'HND TAR ACQ INV'
    
    'EYE TAR HOLD INV'
    'HND TAR HOLD INV'
    
    'WRONG TARGET SELECTED'
    'NO ABORT'
    };

RT.abort_code = categorical({trial.abort_code}',valueset,names);
RT.target_selected = cell(height(RT),1);
RT.correct_target = cell(height(RT),1);

%% chosen targets and correct targets

for k = 1:length(trial) %go through all trials
    
    % target selected
    if ~isnan(trial(k).target_selected) %trial(k).completed == 1
        % the reason for that change here is, because you can have a
        % target selected, but abort during hold, meaning no completion.
        % Thats the difference.
        
        if trial(k).effector == 3 % get only saccade trials
            whichtarget = trial(k).target_selected(1); % here in saccade trials pic the number (can be 1 or 2) which is FIRST in target_selected (because it is for saccades)
            
            RT.target_N_selected(k)=trial(k).target_selected(1);
            if       trial(k).eye.tar(whichtarget).pos(1) < 0
                RT.target_selected(k) = {'left'};
            elseif   trial(k).eye.tar(whichtarget).pos(1) > 0
                RT.target_selected(k) = {'right'};
            else
                RT.target_selected(k) = {'error'};
            end
            
        elseif trial(k).effector == 4 % get only reach trials
            whichtarget = trial(k).target_selected(2); % here in reach trials pic the number (its value can be 1 or 2) which is SECOND in target_selected (because it is for reaches)
            
            RT.target_N_selected(k)=trial(k).target_selected(2);
            if       trial(k).hnd.tar(whichtarget).pos(1) < 0
                RT.target_selected(k) = {'left'};
            elseif   trial(k).hnd.tar(whichtarget).pos(1) > 0
                RT.target_selected(k) = {'right'};
            else
                RT.target_selected(k) = {'error'};
            end
            
        else
            RT.target_selected(k) = {'effector unknown'};
        end
        
    else
        RT.target_selected(k) = {'none'};
        
    end
    
    
    % correct target
    RT.correct_target(k) = {'unclear'};
    if numel(trial(k).task.correct_choice_target)>1
        RT.correct_target(k) = {'both'};
        
    elseif trial(k).effector==3
        if trial(k).task.eye.tar(trial(k).task.correct_choice_target).x <0
            RT.correct_target(k) = {'left'};
        elseif trial(k).task.eye.tar(trial(k).task.correct_choice_target).x >0
            RT.correct_target(k) = {'right'};
        end
        
    elseif trial(k).effector==4
        if trial(k).task.hnd.tar(trial(k).task.correct_choice_target).x <0
            RT.correct_target(k) = {'left'};
        elseif trial(k).task.hnd.tar(trial(k).task.correct_choice_target).x >0
            RT.correct_target(k) = {'right'};
        end
        
    end
    
    
    % NOCH ZU ÄNDERN:
    
    % Sollte alles abhängig sein davon, ob der Trial aborted wurde? Es ist ja auch interessant zu wissen, welches Target man ausgewählt hat, und dann einen Hold Fehler hatte?
    
    
end

RT.correct_target = categorical(RT.correct_target);
RT.target_selected = categorical(RT.target_selected);

RT_struct=table2struct(RT);
for k=1:size(RT,1)
    choice_cell=cellstr(RT_struct(k).choice);
    correct_cell=cellstr(RT_struct(k).correct_target);
    RT.trial_type{k}=[choice_cell{1} '_' correct_cell{1}];
end

RT.trial_type= categorical(RT.trial_type);
RT.effector = categorical(RT.effector, [3 4], {'saccade', 'reach'});


% gib mir für alle instructed trials(nicht both), die Targets an, in denen
% das falsche Target gewählt wurde (auch die, wo vorher der Trial aborted
% wurde weil fixation break during HOLD

RT.wrong_target_selected = zeros(height(RT),1);
RT.wrong_target_selected(...
    RT.correct_target ~= 'both' & ...
    RT.target_selected == ('right') & ...
    RT.target_selected == ('left') & ...
    RT.target_selected ~= RT.correct_target ...
    ) = 1;
RT.wrong_target_selected = logical(RT.wrong_target_selected);

RT.aborted_state_duration = [trial.aborted_state_duration]';

%% Plotting every single trial in 1 D

if plot_trials == 1,
    hf = figure('Name','Plot trial','CurrentChar',' ');
end

for k = 1:length(trial)
    
    if (list_successful_only == 1 && trial(k).success) || ~list_successful_only || (list_successful_only==2 && ~trial(k).success) % entweder alle erfolgreichen oder alle trials

        % align time axis to trial start
        trial(k).states_onset            = trial(k).states_onset            - trial(k).tSample_from_time_start(1); % setze die states_onsets auf "Null"(nicht wirklich, da irgendwie nicht wirklich 0)
        trial(k).tSample_from_time_start = trial(k).tSample_from_time_start - trial(k).tSample_from_time_start(1); % setze den Beginn des Trials auf 0
        
        % WARUM FÄNGT DER STATE IMMER VOR 0 an?
        
        if plot_trials == 1,
            figure(hf);
            subplot(2,1,1); hold on;
            title([sprintf('Eye/Hand Position, Trial %d',k),...
                cellstr(RT.effector(k)),...
                cellstr(RT.choice(k)),...
                cellstr(RT.target_selected(k)),...
                cellstr(RT.abort_code(k)),...
                {RT.aborted_state_duration(k)}]);
            

            % plot eye and hand trajectories
            plot(trial(k).tSample_from_time_start,trial(k).x_eye,'g');
            plot(trial(k).tSample_from_time_start,trial(k).y_eye,'m');
            plot(trial(k).tSample_from_time_start,trial(k).x_hnd,'g','Color',[0.2314    0.4431    0.3373],'LineWidth',2);
            plot(trial(k).tSample_from_time_start,trial(k).y_hnd,'m','Color',[0.5137    0.3804    0.4824],'LineWidth',2);
            
            xlim = get(gca,'Xlim');
            
            % horizontal lines for fixation radius eye + hnd
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
            
            % horizontal lines for targets for respective effector 
            line([0 xlim(2)], [lower_1 lower_1], 'Color','k','LineStyle',':');
            line([0 xlim(2)], [upper_1 upper_1], 'Color','k','LineStyle',':');
            line([0 xlim(2)], [lower_2 lower_2], 'Color','k','LineStyle',':');
            line([0 xlim(2)], [upper_2 upper_2], 'Color','k','LineStyle',':'); 
            
            % vertical lines for state_onsets
            plot(trial(k).tSample_from_time_start,trial(k).state,'k');
            ylim([-14 14])
            ig_add_multiple_vertical_lines(trial(k).states_onset,'Color','k');            
            
            ylabel('Eye/Hand position, states');
            
            
            if detect_saccades,
                if ~isempty(detect_saccades_custom_settings),
                    em_saccade_blink_detection(trial(k).tSample_from_time_start,trial(k).x_eye,trial(k).y_eye,...
                        detect_saccades_custom_settings);
                else
                    em_saccade_blink_detection(trial(k).tSample_from_time_start,trial(k).x_eye,trial(k).y_eye,...
                        'Downsample2Real',0,'Plot',true,'OpenFigure',true);
                end
            end
            
            
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
                close;
                break;
            end
            clf(hf);
        end
    
    end % if successful..
    
end % for each trial

%% Plotting every single trial in 2 D

if plot_trials == 2,
    hf = figure('Name','Plot trial','CurrentChar',' ');
end

for k = 1:length(trial)
    
    if list_successful_only ~= 1 && plot_trials == 2
        disp('Can only list succesfull trials. Completed but not succesfull trials (WRONG TARGET SELECTED) are ignored so far.')
        break;
        
    elseif (list_successful_only == 1 && trial(k).success)

        % align time axis to trial start
        trial(k).states_onset            = trial(k).states_onset            - trial(k).tSample_from_time_start(1); % setze die states_onsets auf "Null"(nicht wirklich, da irgendwie nicht wirklich 0)
        trial(k).tSample_from_time_start = trial(k).tSample_from_time_start - trial(k).tSample_from_time_start(1); % setze den Beginn des Trials auf 0
        
        % WARUM FÄNGT DER STATE IMMER VOR 0 an?
        
        if plot_trials == 2,
            figure(hf);
            hold on;
            title([sprintf('Eye/Hand Position, Trial %d',k),...
                cellstr(RT.effector(k)),...
                cellstr(RT.choice(k)),...
                cellstr(RT.target_selected(k)),...
                cellstr(RT.abort_code(k)),...
                {RT.aborted_state_duration(k)}]);
            
            % filter for only target acquisition + hold phase
            fil = trial(k).state == 9 | trial(k).state == 10;
            
            % plot eye or hand trajectories
      
            plot(trial(k).x_eye(fil),trial(k).y_eye(fil),'r');
            plot(trial(k).x_hnd(fil),trial(k).y_hnd(fil),'g');
                

            
            % plot rectangles
            if trial(k).effector ==3
                x_left_lower_corner_sq_1 = trial(k).task.eye.tar(1).x - (trial(k).task.eye.tar(1).radius); 
                x_left_lower_corner_sq_2 = trial(k).task.eye.tar(2).x - (trial(k).task.eye.tar(2).radius); 
                y_left_lower_corner_sq_both = -(trial(k).task.eye.tar(2).radius);
                width_sq = trial(k).task.eye.tar(1).radius * 2;
                
                x_left_lower_corner_sq_1_size = trial(k).task.eye.tar(1).x - (trial(k).task.eye.tar(1).size); 
                x_left_lower_corner_sq_2_size = trial(k).task.eye.tar(2).x - (trial(k).task.eye.tar(2).size); 
                y_left_lower_corner_sq_both_size = -(trial(k).task.eye.tar(2).size);
                width_sq_size = trial(k).task.eye.tar(1).size * 2;
               
                rectangle('Position',[x_left_lower_corner_sq_1_size, y_left_lower_corner_sq_both_size, width_sq_size, width_sq_size],'LineStyle','-.');
                rectangle('Position',[x_left_lower_corner_sq_2_size, y_left_lower_corner_sq_both_size, width_sq_size, width_sq_size],'LineStyle','-.');
                
            elseif trial(k).effector == 4
                x_left_lower_corner_sq_1 = trial(k).task.hnd.tar(1).x - (trial(k).task.hnd.tar(1).radius); 
                x_left_lower_corner_sq_2 = trial(k).task.hnd.tar(2).x - (trial(k).task.hnd.tar(2).radius); 
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




%% Errors clustered by intruction

Err= rowfun(@numel,RT,'GroupingVariables',{'abort_code','effector','trial_type'},'InputVariables',{'value'});
Err.prop = Err.GroupCount./(sum(Err.GroupCount)) * 100 ;
Err.choi = zeros(height(Err),1);
Err.choi(Err.trial_type == 'choi_both') = +1;
Err.choi = categorical(Err.choi, [0 1], {'instr' 'choi'});

Err.cause = cell(height(Err),1);
Err.cause(strncmpi('EYE',cellstr(Err.abort_code),3)) = {'eye_cause'};
Err.cause(strncmpi('HND',cellstr(Err.abort_code),3)) = {'hand_cause'};

%%
if 0
    %% Trajectories Hand, Reach Trials only 

    xf = figure;
    for k = 1:length(trial)
       figure(xf)
       hold on;

       if trial(k).effector == 4

       fil = trial(k).state == 9 | trial(k).state == 10;
       plot(trial(k).x_hnd(fil),trial(k).y_hnd(fil),'g')

       ig_set_all_axes('Xlim',[-15 15]);
       ig_set_all_axes('Ylim',[-9 9]);

                   % plot rectangles
                if trial(k).effector ==3
                    x_left_lower_corner_sq_1 = trial(k).task.eye.tar(1).x - (trial(k).task.eye.tar(1).radius); 
                    x_left_lower_corner_sq_2 = trial(k).task.eye.tar(2).x - (trial(k).task.eye.tar(2).radius); 
                    y_left_lower_corner_sq_both = -(trial(k).task.eye.tar(2).radius);
                    width_sq = trial(k).task.eye.tar(1).radius * 2;

                    x_left_lower_corner_sq_1_size = trial(k).task.eye.tar(1).x - (trial(k).task.eye.tar(1).size); 
                    x_left_lower_corner_sq_2_size = trial(k).task.eye.tar(2).x - (trial(k).task.eye.tar(2).size); 
                    y_left_lower_corner_sq_both_size = -(trial(k).task.eye.tar(2).size);
                    width_sq_size = trial(k).task.eye.tar(1).size * 2;

                    rectangle('Position',[x_left_lower_corner_sq_1_size, y_left_lower_corner_sq_both_size, width_sq_size, width_sq_size],'LineStyle','-.');
                    rectangle('Position',[x_left_lower_corner_sq_2_size, y_left_lower_corner_sq_both_size, width_sq_size, width_sq_size],'LineStyle','-.');

                elseif trial(k).effector == 4
                    x_left_lower_corner_sq_1 = trial(k).task.hnd.tar(1).x - (trial(k).task.hnd.tar(1).radius); 
                    x_left_lower_corner_sq_2 = trial(k).task.hnd.tar(2).x - (trial(k).task.hnd.tar(2).radius); 
                    y_left_lower_corner_sq_both = -(trial(k).task.hnd.tar(2).radius);
                    width_sq = trial(k).task.hnd.tar(1).radius * 2;
                end

                rectangle('Position',[x_left_lower_corner_sq_1, y_left_lower_corner_sq_both, width_sq, width_sq],'LineStyle',':');
                rectangle('Position',[x_left_lower_corner_sq_2, y_left_lower_corner_sq_both, width_sq, width_sq],'LineStyle',':');

                circle(trial(k).task.eye.fix.x, trial(k).task.eye.fix.y, trial(k).task.eye.fix.radius);
                circle(trial(k).task.hnd.fix.x, trial(k).task.hnd.fix.y, trial(k).task.hnd.fix.radius);
       end
    end

    %% Trajectories Eye, Saccade Trials only

    xf = figure;
    for k = 1:length(trial)
       figure(xf)
       hold on;

       if trial(k).effector == 3

       fil = trial(k).state == 9 | trial(k).state == 10;
       plot(trial(k).x_eye(fil),trial(k).y_eye(fil),'r')

       ig_set_all_axes('Xlim',[-15 15]);
       ig_set_all_axes('Ylim',[-9 9]);


                      % plot rectangles
                if trial(k).effector ==3
                    x_left_lower_corner_sq_1 = trial(k).task.eye.tar(1).x - (trial(k).task.eye.tar(1).radius); 
                    x_left_lower_corner_sq_2 = trial(k).task.eye.tar(2).x - (trial(k).task.eye.tar(2).radius); 
                    y_left_lower_corner_sq_both = -(trial(k).task.eye.tar(2).radius);
                    width_sq = trial(k).task.eye.tar(1).radius * 2;

                    x_left_lower_corner_sq_1_size = trial(k).task.eye.tar(1).x - (trial(k).task.eye.tar(1).size); 
                    x_left_lower_corner_sq_2_size = trial(k).task.eye.tar(2).x - (trial(k).task.eye.tar(2).size); 
                    y_left_lower_corner_sq_both_size = -(trial(k).task.eye.tar(2).size);
                    width_sq_size = trial(k).task.eye.tar(1).size * 2;

                    rectangle('Position',[x_left_lower_corner_sq_1_size, y_left_lower_corner_sq_both_size, width_sq_size, width_sq_size],'LineStyle','-.');
                    rectangle('Position',[x_left_lower_corner_sq_2_size, y_left_lower_corner_sq_both_size, width_sq_size, width_sq_size],'LineStyle','-.');

                elseif trial(k).effector == 4
                    x_left_lower_corner_sq_1 = trial(k).task.hnd.tar(1).x - (trial(k).task.hnd.tar(1).radius); 
                    x_left_lower_corner_sq_2 = trial(k).task.hnd.tar(2).x - (trial(k).task.hnd.tar(2).radius); 
                    y_left_lower_corner_sq_both = -(trial(k).task.hnd.tar(2).radius);
                    width_sq = trial(k).task.hnd.tar(1).radius * 2;
                end

                rectangle('Position',[x_left_lower_corner_sq_1, y_left_lower_corner_sq_both, width_sq, width_sq],'LineStyle',':');
                rectangle('Position',[x_left_lower_corner_sq_2, y_left_lower_corner_sq_both, width_sq, width_sq],'LineStyle',':');

                circle(trial(k).task.eye.fix.x, trial(k).task.eye.fix.y, trial(k).task.eye.fix.radius);
                circle(trial(k).task.hnd.fix.x, trial(k).task.hnd.fix.y, trial(k).task.hnd.fix.radius);
       end
    end

    %%
end
%% Trajectories using gramm
A = arrayfun(@(a)   {a.x_eye(a.state == 9 | a.state == 10)},trial);
B = arrayfun(@(a)   {a.y_eye(a.state == 9 | a.state == 10)},trial);
A_abs = arrayfun(@(a)   {abs(a.x_eye(a.state == 9 | a.state == 10))},trial);

C = arrayfun(@(a)   {a.x_hnd(a.state == 9 | a.state == 10)},trial);
D = arrayfun(@(a)   {a.y_hnd(a.state == 9 | a.state == 10)},trial);
C_abs = arrayfun(@(a)   {abs(a.x_hnd(a.state == 9 | a.state == 10))},trial);

%% PLots
if ~do_summary; return; end

%% Saccades normal 
figure('Name','saccade trajectories, for target acquisiton + hold phase');
    g1 = gramm('x',A,'y',B,'group',categorical([1:length(trial)]),'color',RT.choice, 'subset',RT.effector == 'saccade' & RT.success);
    g1.geom_line();
    g1.axe_property('Xlim',[-15 15],'Ylim',[-9 9]);
    g1.set_line_options('base_size',0.1);
    g1.set_title('saccade trajectories, for target acquisiton + hold phase');
    g1.set_names('x','x_trajcetories','y','y_trajectories','Color','','row','','column',''); 
    g1.draw;

%% Reaches normal
figure('Name','reach trajectories, for target acquisiton + hold phase');
    g2 = gramm('x',C,'y',D,'group',categorical([1:length(trial)]),'color',RT.choice, 'subset',RT.effector == 'reach' & RT.success);
    g2.geom_line('alpha',0);
    g2.axe_property('Xlim',[-15 15],'Ylim',[-9 9]);
    g2.set_line_options('base_size',0.1);
    g2.set_title('reach trajectories, for target acquisiton + hold phase');
    g2.set_names('x','x_trajcetories','y','y_trajectories','Color','','row','','column',''); 
    g2.draw;
    

%% AUGEN folded left to right
figure('Name','left movements mirrored onto the right, for target acquisiton + hold phase');
    g0(1,1) = gramm('x',A_abs,'y',B,'group',categorical([1:length(trial)]),'color',RT.target_selected, 'subset',RT.effector == 'saccade' & RT.success);
    g0(1,1).geom_point();
    g0(1,1).axe_property('Xlim',[0 15],'Ylim',[-4 4]);
    g0(1,1).set_names('x','abs(x_trajcetories)','y','y_trajectories','Color','','row','','column','');   
    g0(1,1).set_title('saccades');
    
    g0(2,1) = gramm('x',C_abs,'y',D,'group',categorical([1:length(trial)]),'color',RT.target_selected, 'subset',RT.effector == 'reach' & RT.success);
    g0(2,1).geom_point('alpha',0);
    g0(2,1).axe_property('Xlim',[0 15],'Ylim',[-4 4]);
    g0(2,1).set_title('reaches');
    
    g0.set_names('x','abs(x_trajcetories)','y','y_trajectories','Color','','row','','column','');   
    g0.set_title('left movements mirrored onto the right, for target acquisiton + hold phase');
    g0.set_color_options('map','brewer2');
    g0.set_point_options('base_size',2);
    g0.draw;

%% plots

    %%
    figure; % Succes Rate
    g5(1,1) = gramm('x',categorical(RT.success), 'color', RT.choice,'column',RT.effector);%,'subset',RT.success == 1); %'x',categorical(RT.success
    g5(1,1).stat_bin('normalization','probability');
    %g5(1,1).facet_wrap(RT.effector);
    g5(1,1).set_names('x','','y','proportion in %','Color','','row','','column','');
    
    g5(2,1) = gramm('x',categorical(RT.success),'color', RT.trial_type,'column',RT.effector,'subset', RT.trial_type ~= 'choi_both');
    g5(2,1).stat_bin('normalization','probability');
    g5(2,1).set_color_options('map','brewer2');
    g5(2,1).set_names('x','','y','proportion in %','Color','','row','','column','');
    
    g5.set_title({'success rate clustered by instruction'});
    g5.draw;
    %g5.export('file_name',['SuccessRate_' trial(1).fileinfo.name(1:4) '_' trial(1).path(61:70)],'export_path', runpath(1:59));
    % g5(2,1) = gramm('x', Err.trial_type,'color', Err.trial_type,'column',Err.effector,'subset', Err.abort_code ~= {'NO ABORT'} & Err.trial_type ~= 'choi_both');
    % g5(2,1).stat_bin('geom','bar');
    % g5(2,1).set_color_options('map','brewer2');
    % g5(2,1).set_names('x','','y','proportion in %','Color','','row','','column','');
    % g5(2,1).set_title({'instructed left vs. right'});
    %
    % g5.set_title({'Proportion of Errors clustered by instruction'});
    % g5.draw;
    
    %%
    figure; %2 reaction times
    g(1,1) = gramm('x', RT.value, 'color', RT.choice,'linestyle', RT.target_selected,'column',RT.effector,'subset',logical(RT.success));
    g(1,1).stat_density();
    g(1,1).set_names('x','RT / s','Color','','row','','column','','linestyle','target selected');
    
    
    g(2,1) = gramm('x', RT.target_selected, 'y', RT.value,'column',RT.effector,'color', RT.choice,'subset',logical(RT.success));
    g(2,1).geom_jitter('dodge', 0.8);
    g(2,1).set_names('x','target selected','y','RT/s','Color','','row','','column','');
    
    g.set_title({'reaction time, successfull only, N = ' (sum(RT.success))});
    g.draw;
    %g.export('file_name',['RTs_' trial(1).fileinfo.name(1:4) '_' trial(1).path(61:70)],'export_path', runpath(1:59));
    
    
    %%
    figure; %7 Which Errors
    g6 = gramm('x', Err.abort_code,'y', Err.prop,'color',Err.trial_type, 'subset', Err.abort_code ~= 'NO ABORT');
    g6.stat_summary('geom','bar');
    g6.facet_grid(Err.cause,Err.effector);
    g6.set_text_options('base_size',8);
    g6.set_names('x','','y','proportion in %','Color','instruction','row','cause of error','column','');
    g6.set_title({'Which errors occur for which effector? Clustered by instruction. proportion of errors: ' (sum(~RT.success))/length(RT.success)  });
    
    g6.draw;
    %g6.export('file_name',['Errors_' trial(1).fileinfo.name(1:4) '_' trial(1).path(61:70)],'export_path', runpath(1:59));
    
    %%
    
    figure; %4 choice bias
    g3(1,1) = gramm('x', RT.target_selected, 'subset', RT.target_selected ~= 'none' & RT.choice == 'choice' & RT.success);
    g3(1,1).stat_bin('geom','bar','normalization','probability');
    g3(1,1).facet_wrap(RT.effector,'ncols',2);
    g3(1,1).set_names('x','','y','proportion in %','Color','','row','','column','');
    g3(1,1).set_title({'relative amount of left/right answers in choice trials'});
    
    g3(1,2) = gramm('x',categorical(RT.target_selected), 'color', RT.choice, 'subset', RT.target_selected ~= 'none' & RT.success);
    g3(1,2).stat_bin('geom','bar','normalization','count');
    g3(1,2).facet_wrap(RT.effector,'ncols',2);
    g3(1,2).set_names('x','','y','count','Color','','row','','column','');
    g3(1,2).set_title({'Is there an equal amount of N in each condition?'});
    
    g3(2,2) = gramm('x',RT.effector, 'color', RT.choice, 'subset', RT.target_selected ~= 'none' & RT.success);
    g3(2,2).stat_bin('geom','bar','normalization','count');
    g3(2,2).set_names('x','','y','count','Color','','row','','column','');
    g3(2,2).set_title({'How many trials in choice vs. instructed?'});
    
    g3.set_title({'Choice Bias for successful trials'})
    
    g3.draw;
    %g3.export('file_name',['ChoiceBias_' trial(1).fileinfo.name(1:4) '_' trial(1).path(61:70)],'export_path', runpath(1:59),'width',56,'height',33,'units','centimeters');

    %%

%%    
%     figure; % 5 aborted_state_duration
%     g2 = gramm('x',RT.aborted_state_duration,'row',RT.abort_code,'subset',or(RT.abort_code == 'HND FIX HOLD', RT.abort_code == 'EYE FIX HOLD'));
%     g2.stat_bin('nbins',200);
%    % g2.axe_property('XLim',[0 2]);
%     g2.set_names('x','time in s','y','count','Color','','row','');
%     g2.set_title({'Fixation Hold Errors for first 2 seconds'})
%     g2.draw;
%     
%     figure;    
%     g4 = gramm('x',RT.aborted_state_duration,'color',RT.abort_code,'subset',or(RT.abort_code == 'HND FIX HOLD', RT.abort_code == 'EYE FIX HOLD'));
%     g4.stat_bin('nbins',200);
%     %g4.axe_property('XLim',[0 2]);
%     g4.facet_wrap(double(RT.run));
%     g4.set_names('x','time in s','y','count','Color','','row','');
%     g4.set_title({'Fixation Hold Errors for first 2 seconds by run'})
%     g4.draw;


function circle(x,y,r)
%x and y are the coordinates of the center of the circle
%r is the radius of the circle
%0.01 is the angle step, bigger values will draw the circle faster but
%you might notice imperfections (not very smooth)
ang=0:0.01:2*pi; 
xp=r*cos(ang);
yp=r*sin(ang);
plot(x+xp,y+yp,'LineStyle',':','Color','k');

