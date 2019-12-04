%% Initiate conditions
global SETTINGS
% 
% %% these 2??
%         SETTINGS.useParallel                = 0;
%         SETTINGS.useSerial                  = 0;
% 
% 
%         SETTINGS.UseMouseAsTouch = 1; % use mouse instead of touchscreen
%         SETTINGS.useSound                   = 0;
%         SETTINGS.useMouse                   = 0;         % 0: use mouse instead of eye position
%         SETTINGS.useVPacq                   = 1;         % 1: allow ViewPoint toolbox
        
if ~exist('dyn','var') || dyn.trialNumber == 1
    
  % esperimentazione        = {'calibration'};
   esperimentazione      = {'Symbolic_cue_sac_reach'};
    
   
    for n_exp = 1:numel(esperimentazione)
        experiment=esperimentazione{n_exp};
        shuffle_conditions                  = 1;
        task.calibration                    = 1;
        SETTINGS.GUI_in_acquisition         = 0;
        SETTINGS.check_motion_jaw           = 0;
        SETTINGS.check_motion_body          = 0;
        task.rest_hand                      = [0 0];
        multiple_targets_per_trial          = 0;
        
     
        
        %% Order of fields here defines the order of parameters to be sent to TDT as the trial_classifiers
        All = struct('angle_cases',0,'instructed_choice_con',0,'type_con',0,'effector_con',0,'reach_hand_con',0,'excentricities',0,'stim_con',0,'timing_con',0,'size_con',0,...
            'correct_choice_target',1,'tar_dis_con',0,'mat_dis_con',0,'cue_pos_con',0,'shape_con',0,'offset_con',0,'invert_con',0,'exact_excentricity_con_x',NaN,'exact_excentricity_con_y',NaN,'var_x',0,'var_y',0);
        
        switch experiment
            
            case 'calibration'
                SETTINGS.check_motion_jaw           = 0;
                SETTINGS.GUI_in_acquisition         = 1;
                
                force_conditions                    = 2;
                N_repetitions                       = 100;
                
                % relative to 'straight ahead' -> task.screen_uh_cm
                fix_eye_y                           = 0.375; % -2
                fix_hnd_y                           = -0.375; % -6
                
                task.calibration                    = 1;
                task.reward.time_neutral            = [0.1 0.1];
                task.rest_hand                      = [0 0];
                
                All.offset_con                      = 0;
                All.reach_hand_con                  = 2;
                All.type_con                        = 1; % 1 - fixation, 2 - direct saccade
                All.effector_con                    = 0;
                All.reach_hand_con                  = 2;
                All.timing_con                      = 0;
                All.size_con                        = 0;
                All.correct_choice_target           = 0;
                All.instructed_choice_con           = 0;
                All.var_x                           = 0;
                All.var_y                           = 0;
                
                All.exact_excentricity_con_x    = [-9.5 9.5];
                All.exact_excentricity_con_y    = [-5 5];
                SETTINGS.GUI_in_acquisition         = 1;
                
            case 'Symbolic_cue_sac_reach'
                SETTINGS.background_image           = 'rectangles';
                SETTINGS.check_motion_jaw           = 0;
                SETTINGS.Radius_square              = 1;
                SETTINGS.TextFeedback               = 1;
                
                fix_eye_y                           = 0.375; % -2
                fix_hnd_y                           = -0.375; % -6
                
                task.reward.time_neutral            = [0 0]; % ???? 0.2s -> 0.24 ml per hit
                task.rest_hand                      = [0];
                All.rest_hands_con                  = 0;
                
                All.offset_con                      = 0;
                All.reach_hand_con                  = 2; %2
                All.type_con                        = 3;
                All.effector_con                    = [3 4];  %0 eye %1 free gaze reach %2 joint movement eye and hand  %3 dissociated saccade %4 dissociated reach %6 free gaze reach with initial eye fixation
                All.timing_con                      = 31; % 29 playground, 31 Master Thesis, 33  Carstens Paper 
                All.size_con                        = 9; %symbolic cue
                All.correct_choice_target           = [1 1 2 2 2]; %1 only first target correct %2 both are correct, %[1 2] % [1 1 2 2 2];
                All.instructed_choice_con           = 1; % special for instructed-choice task, where both targets are visible but there is an instruction
                All.var_x                           = 0;
                All.var_y                           = 0;
                
                All.exact_excentricity_con_x    = [-9.5 9.5];
                All.exact_excentricity_con_y    = [0 0];
                
                
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                put_back                            = [2 4]; % min max how many trials later error is being put back
                
                % new part about pre-saved trial sequence
                load([pathname filesep monkey_name filesep monkey_name filesep 'shuffled_conditions_S01.mat']);
                
                if exist('dyn','var') && dyn.trialNumber > 1,
                    
                    if trial(end-1).success==0 % previous trial was failure, put it back
                        
                        % put error trial back into present
                        err_back = randperm(length(put_back(1):put_back(2)),1) - 1 + put_back(1);
                        
                        present = [present(1:(counter + err_back - 1),:); ...
                            present(counter,:); ...
                            present((counter + err_back):end,:)];
                        
                    end
                    
                    % save updated _shuffled_conditions_S01
                    shuffled_conditions_counter = shuffled_conditions_counter + 1;
                    save([pathname filesep monkey filesep monkey_name filesep 'shuffled_conditions_S01.mat'],'present','shuffled_conditions_counter');
                    
                end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
                
                
                
                
        end
        
        all_fieldnames=fieldnames(All);
        N_total_conditions       =1;
        sequence_cell            ={};
        for FN=1:numel(all_fieldnames)
            N_total_conditions=N_total_conditions*numel(All.(all_fieldnames{FN}));
            sequence_cell=[sequence_cell, {All.(all_fieldnames{FN})}];
        end
        
        sequence_matrix_exp_temp          = repmat(CombVec(sequence_cell{:}),1,N_repetitions);
        
        sequence_matrix_exp{n_exp}          = sequence_matrix_exp_temp;
        ordered_sequence_indexes_exp{n_exp} = 1:N_total_conditions*N_repetitions;
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % choice
    if strcmp('Symbolic_cue_sac_reach',esperimentazione)
        
        % choice
        if strcmp('choi',present.choice(shuffled_conditions_counter - 1))
     
            Current_con.correct_choice_target = [1 2];
            
        elseif strcmp('instr',present.choice(shuffled_conditions_counter - 1))
            
            Current_con.correct_choice_target  = 1;
        end
        
        % effector
        if strcmp('hnd',present.choice(shuffled_conditions_counter - 1))
            
            Current_con.effector_con = 4;
            
        elseif strcmp('eye',present.choice(shuffled_conditions_counter - 1))
        
            Current_con.effector_con = 3;
            
        end
        
        % side  
        if strcmp('left',present.choice(shuffled_conditions_counter - 1))
            
            Current_con.exact_excentricity_con_x = [-9.5];
            
        elseif strcmp('eye',present.choice(shuffled_conditions_counter - 1))
        
            Current_con.exact_excentricity_con_x = [9.5];
            
        end
    
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%
    
    sequence_matrix          = [sequence_matrix_exp{:}];
    idx_exact_x=ismember(all_fieldnames,'exact_excentricity_con_x');
    idx_exact_y=ismember(all_fieldnames,'exact_excentricity_con_y');
    conditions_to_remove=(sequence_matrix(idx_exact_y,:)==0 & sequence_matrix(idx_exact_x,:)==0);
    sequence_matrix(:,conditions_to_remove)=[];
    
    
    
    ordered_sequence_indexes = 1:(numel([ordered_sequence_indexes_exp{:}])-sum(conditions_to_remove));
end


%% Shuffling conditions
if ~exist('dyn','var') || (dyn.trialNumber == 1 && shuffle_conditions==0)
    sequence_indexes = ordered_sequence_indexes;
elseif dyn.trialNumber == 1 && (shuffle_conditions==1)
    sequence_indexes = Shuffle(ordered_sequence_indexes);
end
if exist('dyn','var') && dyn.trialNumber > 1,
    if force_conditions==1
        if sum([trial.success])==length(sequence_indexes),
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence_indexes(sum([trial.success])+1);
        end
        % semi-forced: if trial is unsuccessful, the condition is put back into the pool
    elseif force_conditions==2
        if trial(end-1).success==1
            sequence_indexes=sequence_indexes(2:end);
        else
            sequence_indexes=Shuffle(sequence_indexes);
        end
        if numel(sequence_indexes)==0
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence_indexes(1);
        end
    else
        if numel(trial)-1==length(sequence_indexes),
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence_indexes(numel(trial));
        end
    end
else
    custom_trial_condition = sequence_indexes(1);
    
    
end

%dyn.trial_classifier(1)=numel(All.tar_pos_con);
for field_index=1:numel(all_fieldnames)
    Current_con.(all_fieldnames{field_index})=sequence_matrix(field_index,custom_trial_condition);
    %dyn.trial_classifier(field_index+1) = Current_con.(all_fieldnames{field_index});
    dyn.trial_classifier(field_index) = abs(round(Current_con.(all_fieldnames{field_index})));
end


%% Fixation offset
fix_eye_x             = Current_con.offset_con;
fix_hnd_x             = fix_eye_x;



%% CHOICE\INSTRUCTED
task.choice                 = Current_con.instructed_choice_con;

%% TYPE
task.type                   = Current_con.type_con;

%% EFFECTOR
task.effector               = Current_con.effector_con;

%% REACH hand
task.reach_hand             = Current_con.reach_hand_con;

%% TIMING
switch Current_con.timing_con
    case 0 % 'calibration'
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        
        task.timing.wait_for_reward             = 0.2;
        task.timing.ITI_success                 = 1;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 1;
        task.timing.ITI_fail_var                = 0;
        task.timing.ITI_incorrect_completed     = 1;
        task.timing.grace_time_eye              = 1.3;
        task.timing.grace_time_hand             = 0;
        task.timing.fix_time_to_acquire_hnd     = 1; %1
        task.timing.tar_time_to_acquire_hnd     = 1.5; % 1.5
        task.timing.tar_inv_time_to_acquire_hnd = 1;
        task.timing.fix_time_to_acquire_eye     = 10.5;
        task.timing.tar_time_to_acquire_eye     = 10.5;
        task.timing.tar_inv_time_to_acquire_eye = 0.5;
        task.timing.fix_time_hold               = 0.8;
        task.timing.fix_time_hold_var           = 0.2;
        task.timing.cue_time_hold               = 0.5;
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 0;
        task.timing.mem_time_hold_var           = 0;
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0;
        task.timing.tar_inv_time_hold_var       = 0;
        task.timing.tar_time_hold               = 0.5;
        task.timing.tar_time_hold_var           = 0;
        task.timing.text_feedback               = 1.5;
        
    case 29 % playground
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.wait_for_reward             = 0.3;
        
        task.timing.grace_time_eye              = 0.5; % time allowed for blinking
        task.timing.grace_time_hand             = 0.2;
        
        % 21 ? 
        task.timing.ITI_success                 = 1;%3; % 3 inter trial interval after success
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 1;%3; % 3 inter trial interval after error
        task.timing.ITI_fail_var                = 0;
        task.timing.ITI_incorrect_completed     = 1;
        
        % 2 
        task.timing.fix_time_to_acquire_eye     = 2; %0.5;
        task.timing.fix_time_to_acquire_hnd     = 2; %1.5;
        
        % 3 FIXATION
        task.timing.fix_time_hold               = 2; % 5 
        task.timing.fix_time_hold_var           = 0; 
        
        % 6 CUE
        task.timing.cue_time_hold               = 0.2; % .700; 
        task.timing.cue_time_hold_var           = 0; 
        
        % 7 MEMORY
        task.timing.mem_time_hold               = 2;%2;
        task.timing.mem_time_hold_var           = 0;
        
        % 9 GO
        task.timing.tar_inv_time_to_acquire_eye = 5; 
        task.timing.tar_inv_time_to_acquire_hnd = 2;
        
        % 10 HOLD
        task.timing.tar_inv_time_hold           = 3;%1
        task.timing.tar_inv_time_hold_var       = 0;
        
        % 4 OLD ACQ (does not add up to overall hold, since targets already reached)
        task.timing.tar_time_to_acquire_eye     = 0; %0.5
        task.timing.tar_time_to_acquire_hnd     = 0; % 1 % 0.7
        
        % 5 HOLD 2
        task.timing.tar_time_hold               = 0; %2 %when targets with color, they light up in that phase
        task.timing.tar_time_hold_var           = 0;
        
        
        task.timing.text_feedback               = 2;
        
        
    case 31 %Peter's master saccade-reach project
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.wait_for_reward             = 0.3;
        
        task.timing.grace_time_eye              = 0.7; % time allowed for blinking
        task.timing.grace_time_hand             = 0.2;
        
        task.timing.ITI_success                 = 5;%3; % 3 inter trial interval after success
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 5;%3; % 3 inter trial interval after error
        task.timing.ITI_fail_var                = 0;
        task.timing.ITI_incorrect_completed     = 5;
        
        task.timing.fix_time_to_acquire_eye     = 3; % 0.5
        task.timing.fix_time_to_acquire_hnd     = 3;
        
        task.timing.fix_time_hold               = 11.8;   % 0.5; % 5
        task.timing.fix_time_hold_var           = 0;      % 0
        
        task.timing.cue_time_hold               = 0.200; % 0.200
        task.timing.cue_time_hold_var           = 0; % 0
        
        task.timing.mem_time_hold               = present.delay(shuffled_conditions_counter -1);
        task.timing.mem_time_hold_var           = 0;
        
        task.timing.tar_inv_time_to_acquire_eye = 1; %3 % 0.5
        task.timing.tar_inv_time_to_acquire_hnd = 2;
        
        task.timing.tar_inv_time_hold           = 1;%0.2;
        task.timing.tar_inv_time_hold_var       = 0;
        
        task.timing.tar_time_to_acquire_eye     = 0; %0.5
        task.timing.tar_time_to_acquire_hnd     = 0; % 1 % 0.7
        
        task.timing.tar_time_hold               = 0; %2 %when targets with color, they light up in that phase
        task.timing.tar_time_hold_var           = 0;
        
        
        task.timing.text_feedback               = 2;
   
        
        
    case 32 %Carsten paper
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.wait_for_reward             = 0.3;
        
        task.timing.grace_time_eye              = 0.3; % time allowed for blinking
        task.timing.grace_time_hand             = 0.2;
        
        task.timing.ITI_success                 = 8;%3; % 3 inter trial interval after success
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 8;%3; % 3 inter trial interval after error
        task.timing.ITI_fail_var                = 0;
        task.timing.ITI_incorrect_completed     = 8;
        
        task.timing.fix_time_to_acquire_eye     = 3; % 0.5
        task.timing.fix_time_to_acquire_hnd     = 3;
        
        task.timing.fix_time_hold               = 11.8;   % 0.5; % 5
        task.timing.fix_time_hold_var           = 0; % 0
        
        task.timing.cue_time_hold               = 0.200; % 0.200
        task.timing.cue_time_hold_var           = 0; % 0
        
        task.timing.mem_time_hold               = 15;%2; after cue disappears
        task.timing.mem_time_hold_var           = 0;
        
        task.timing.tar_inv_time_to_acquire_eye = 1; %3 % 0.5
        task.timing.tar_inv_time_to_acquire_hnd = 2;
        
        task.timing.tar_inv_time_hold           = 2;%0.2;
        task.timing.tar_inv_time_hold_var       = 0;
        
        task.timing.tar_time_to_acquire_eye     = 0; %0.5
        task.timing.tar_time_to_acquire_hnd     = 0; % 1 % 0.7
        
        task.timing.tar_time_hold               = 0; %2 %when targets with color, they light up in that phase
        task.timing.tar_time_hold_var           = 0;
        
        task.timing.text_feedback               = 2;
        
        %task.timing.del_time_hold               = 2; % 1
        %task.timing.del_time_hold_var           = 0; % 0
        
        
        
end

%% RADIUS & SIZES


switch Current_con.size_con
    case 0 %'calibration'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 100;
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 100;
        
        task.hnd.fix.radius     = 4;
        task.hnd.fix.size       = 2;
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 4;
        
    case 1 %'fixation'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 5;
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 5;
        
        task.hnd.fix.radius     = 4;
        task.hnd.fix.size       = 4;
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 4;
        
    case 9 % symbolic cue
        
        task.eye.fix.size       = 0.25;
        task.eye.fix.radius     = 4.5;
        task.eye.tar(1).size    = 3.4;
        task.eye.tar(1).radius  = 4; %3.4
        
        task.hnd.fix.size       = 0.75; %4
        task.hnd.fix.radius     = 0.75; %4
        task.hnd.tar(1).size    = 3.4;
        task.hnd.tar(1).radius  = 3.4;
        
        % target 2 has the same sizes as target 1
        task.eye.tar(2).size    = task.eye.tar(1).size;
        task.hnd.tar(2).size    = task.hnd.tar(1).size ; % deg
        task.eye.tar(2).radius  = task.eye.tar(1).radius;
        task.hnd.tar(2).radius  = task.hnd.tar(1).radius; % deg
        
        if task.effector==3
            
            % for saccades, the hand fixation becomes a target with the
            % same sizes as the fixation
            
            task.hnd.tar(1).size    = task.hnd.fix.size;
            task.hnd.tar(1).radius  = task.hnd.fix.radius;
            
            task.hnd.tar(2).size    = task.hnd.tar(1).size ; % deg
            task.hnd.tar(2).radius  = task.hnd.tar(1).radius; % deg
            
        elseif task.effector==4
            
            % for reaches, the eye fixation becomes a target with the
            % same sizes as the fixation
            
            task.eye.tar(1).size    = task.eye.fix.size;
            task.eye.tar(1).radius  = task.eye.fix.radius;
            
            task.eye.tar(2).size    = task.eye.tar(1).size;
            task.eye.tar(2).radius  = task.eye.tar(1).radius;
            
        end
end

%% POSITIONS
tar_dis_x   = Current_con.exact_excentricity_con_x;
tar_dis_y   = Current_con.exact_excentricity_con_y;

tar_dis_1x = + tar_dis_x + Current_con.var_x;
tar_dis_1y = + tar_dis_y + Current_con.var_y;
tar_dis_2x = - tar_dis_x + Current_con.var_x;  %%%%% CHANGE HERE TO (-) FOR SYMETRIC CONTRACTION EXPANSION OR (+) FOR SYMETRIC LEFT RIGHT
tar_dis_2y = + tar_dis_y + Current_con.var_y;


if task.type==1
    
    task.eye.fix.x    = fix_eye_x  + tar_dis_1x;
    task.eye.fix.y    = fix_eye_y  + tar_dis_1y;
    task.hnd.fix.x    = fix_hnd_x  + tar_dis_1x;
    task.hnd.fix.y    = fix_hnd_y  + tar_dis_1y;
else
    
    task.eye.fix.x    = fix_eye_x;
    task.eye.fix.y    = fix_eye_y;
    task.hnd.fix.x    = fix_hnd_x;
    task.hnd.fix.y    = fix_hnd_y;
end

if task.effector==3
    
    % target position relative to fixation
    task.eye.tar(1).x = fix_eye_x  + tar_dis_1x; 
    task.eye.tar(1).y = fix_eye_y  + tar_dis_1y - 0.375;%-1
    task.eye.tar(2).x = fix_eye_x  + tar_dis_2x;
    task.eye.tar(2).y = fix_eye_y  + tar_dis_2y - 0.375;%-1
    
    % saccades: hand fixation --> hand target
    task.hnd.tar(1).x = fix_hnd_x; % both targets merge at the hand fixation point
    task.hnd.tar(1).y = fix_hnd_y;
    task.hnd.tar(2).x = fix_hnd_x;
    task.hnd.tar(2).y = fix_hnd_y;
    
elseif task.effector==4 || task.effector==6    
    
    task.eye.tar(1).x = fix_eye_x;
    task.eye.tar(1).y = fix_eye_y;
    task.eye.tar(2).x = fix_eye_x;
    task.eye.tar(2).y = fix_eye_y;
    
    % reaches: eye fixation --> eye target
    task.hnd.tar(1).x = fix_hnd_x  + tar_dis_1x;
    task.hnd.tar(1).y = fix_hnd_y  + tar_dis_1y + 0.375; % target position on y axis in relation to hand fixation point
    task.hnd.tar(2).x = fix_hnd_x  + tar_dis_2x;
    task.hnd.tar(2).y = fix_hnd_y  + tar_dis_2y + 0.375; % target position on y axis in relation to hand fixation point
else    
    
    task.eye.tar(1).x = fix_eye_x  + tar_dis_1x;
    task.eye.tar(1).y = fix_eye_y  + tar_dis_1y;
    task.eye.tar(2).x = fix_eye_x  + tar_dis_2x;
    task.eye.tar(2).y = fix_eye_y  + tar_dis_2y;
    
    task.hnd.tar(1).x = fix_hnd_x  + tar_dis_1x;
    task.hnd.tar(1).y = fix_hnd_y  + tar_dis_1y;
    task.hnd.tar(2).x = fix_hnd_x  + tar_dis_2x;
    task.hnd.tar(2).y = fix_hnd_y  + tar_dis_2y;
end

%% COLORS FIXATION
task.eye.fix.color_dim          = [100 0 0]; % color of eye fix before fixated (with both eye and hand)
task.eye.fix.color_bright       = [180 0 0]; % color of eye fix after fixated (with both eye and hand)

task.hnd_right.color_dim_fix     =  [0 100 0]; % color of hand fix before fixated (with both eye and hand)
task.hnd_right.color_bright_fix  =  [0 180 0]; % color of hand fix before fixated (with both eye and hand)


%% CUE assignment (Positions and colors !)
task.eye.cue                                        = task.eye.tar; %%% ???????????
task.hnd.cue                                        = task.hnd.tar; %%% ???????????

task.eye.tar(1).color_dim       = [0 0 0]; % saccades: Color of selected target quickly before phase 5 (TAR_HOLD) - not influencibale in length in timing structure
task.eye.tar(1).color_bright    = [0 0 0]; % saccades: Color of selected target during phase 5 (TAR_HOLD) 

task.eye.tar(2).color_dim       = [0 0 0]; % these don't seem to have an influence on anything  
task.eye.tar(2).color_bright    = [0 0 0]; % these don't seem to have an influence on anything

task.hnd_right.color_dim        = [0 0 0]; % reaches: Color of selected target quickly before phase 5 (TAR_HOLD) - not influencibale in length in timing structure
task.hnd_right.color_bright     = [0 0 0]; % reaches: Color of selected target during phase 5 (TAR_HOLD)


task.eye.cue(1).color_bright    = [255 0 0]; % doesn't seem to have an influence on anything



% COLOR OF THE CUES
task.eye.cue(1).color_dim       = [180 0 0]; %%%%%%%%% COLOR OF EYE CUE
task.hnd_right.color_cue        = [0 180 0]; %%%%%%%%%%%% COLOR OF THE HAND CUE



%% this part for one correct versus 2 correct (free choice vs "instr choice with two targets)
% first target is always correct, but the position of target one varies
% dependent on position parameters

switch Current_con.correct_choice_target;    
    case 0
    
    case 1 % target #1 correct, target 2 is incorrect
        task.correct_choice_target  = 1;
        
        % Cue positions for hand and eyes
        task.eye.cue(2)=[];
        task.eye.cue(1).x=fix_eye_x;
        task.eye.cue(1).y=fix_eye_y+1.2;
        task.hnd.cue(2)=[];
        task.hnd.cue(1).x=fix_eye_x;
        task.hnd.cue(1).y=fix_eye_y+1.2;
        
        task.eye.cue=rmfield(task.eye.cue,'shape');
        task.hnd.cue=rmfield(task.hnd.cue,'shape');
        % Cue size
        task.eye.cue(1).size =0.66;       %% arrow lleft right
        task.eye.cue(1).rad  =0.66;       %% arrow lleft right
        task.hnd.cue(1).size =0.66;       %% arrow lleft right
        
        
        if task.hnd.tar(1).x < 0 || task.eye.tar(1).x < 0
            task.eye.cue(1).shape.mode ='arrows';       %% arrow lleft right
            task.eye.cue(1).shape.option ='LL';       %% arrow lleft right
            task.hnd.cue(1).shape.mode ='arrows';       %% arrow lleft right
            task.hnd.cue(1).shape.option ='LL';       %% arrow lleft right
        else
            %disp(task.eye.tar(1).x)
            task.eye.cue(1).shape.mode ='arrows';       %% arrow lleft right
            task.eye.cue(1).shape.option ='RR';       %% arrow lleft right
            task.hnd.cue(1).shape.mode ='arrows';       %% arrow lleft right
            task.hnd.cue(1).shape.option ='RR';       %% arrow lleft right
        end
        
    case 2 % target #1 and target #2 correct 
        task.correct_choice_target  = [1 2];
        
        %Cue position eye
        task.eye.cue(2)=[];
        task.eye.cue(1).x=fix_eye_x;
        task.eye.cue(1).y=fix_eye_y+1.2;
        %Cue shape + size eye
        task.eye.cue=rmfield(task.eye.cue,'shape');
        task.eye.cue(1).shape.mode ='arrows';       %% arrow lleft right
        task.eye.cue(1).shape.option ='LR';       %% arrow lleft right
        task.eye.cue(1).size =0.66;       %% arrow lleft right
        
        %Cue position hand
        task.hnd.cue(2)=[];
        task.hnd.cue(1).x=fix_eye_x;
        task.hnd.cue(1).y=fix_eye_y+1.2;
        % Cue shape + size
        task.hnd.cue=rmfield(task.hnd.cue,'shape');
        task.hnd.cue(1).shape.mode ='arrows';       %% arrow lleft right
        task.hnd.cue(1).shape.option ='LR';       %% arrow lleft right
        task.hnd.cue(1).size =0.66;       %% arrow lleft right        
end

% specific case for circles vs rectangles
% task.eye.tar(1).radiusShape ='circle';
% task.eye.tar(2).radiusShape ='circle';
% task.eye.tar(1).shape ='circle';
% task.eye.tar(2).shape ='circle';
% task.hnd.tar(1).radiusShape ='circle';
% task.hnd.tar(2).radiusShape ='circle';
% task.hnd.tar(1).shape ='circle';
% task.hnd.tar(2).shape ='circle';

task.hnd.tar(1).radiusShape ='square';
task.hnd.tar(2).radiusShape ='square';
task.hnd.tar(1).shape ='square';
task.hnd.tar(2).shape ='square';
task.eye.tar(1).radiusShape ='square';
task.eye.tar(2).radiusShape ='square';
task.eye.tar(1).shape ='square';
task.eye.tar(2).shape ='square';
        
        
switch Current_con.effector_con
    case 0 % saccade only (calibration with visible targets)
        
        task.eye.tar(1).color_dim       = [128 0 0];  
        task.eye.tar(1).color_bright    = [200 0 0];
        task.eye.tar(2).color_dim       = [128 0 0]; 
        task.eye.tar(2).color_bright    = [200 0 0];
%     case 3 % dissociated saccade
%         task.eye.cue(1).color_bright = [255 0 0]; %this is the color of the arrows!
%         task.eye.tar(1).radiusShape ='square';
%         task.eye.tar(2).radiusShape ='square';
%         task.eye.tar(1).shape ='square';
%         task.eye.tar(2).shape ='square';
%         
%         task.hnd_right.color_dim        = task.hnd_right.color_dim_fix; %
%         task.hnd_right.color_bright     = task.hnd_right.color_bright_fix;% color of right hand target
%         task.hnd_left.color_dim         = task.hnd_left.color_dim_fix; %
%         task.hnd_left.color_bright      = task.hnd_left.color_bright_fix; % color of left hand target
%     case 4 % dissociated reach        
%         % eye fixation during target presentation
%         task.eye.tar(1).color_dim       = [128 0 0];  % 2.5 or 3 change here to check if rectangles have the same size as background % also - color of cues
%         task.eye.tar(1).color_bright    = [255 0 0];
%         task.eye.tar(2).color_dim       = [128 0 0]; %  % 2.5 or 3
%         task.eye.tar(2).color_bright    = [255 0 0];        
% 
%         task.hnd.tar(1).radiusShape ='square';
%         task.hnd.tar(2).radiusShape ='square';
%         task.hnd.tar(1).shape ='square';
%         task.hnd.tar(2).shape ='square';
end



    
    