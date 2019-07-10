% function fdr_analyze_one_session_behavior(runpath, list_successful_only, plot_trials, detect_saccades,detect_saccades_custom_settings)
% % pass in runpath the location where the matfiles are
% 
% analyze_reach_decision('Y:\Personal\Peter\Data\IVSK\20190618')
% 
% if nargin < 2,
% 	list_successful_only = 0;
% end
% 
% if nargin < 3,
% 	plot_trials = 0;
% end
% 
% if nargin < 4,
% 	detect_saccades = 0;
% end
% 
% if nargin < 5,
% 	detect_saccades_custom_settings = '';
% end

warning off

%%
list_successful_only = 1; % 0 - list all, 1 - only successful, 2 - only not successful
plot_trials = 0;
detect_saccades = 0;
detect_saccades_custom_settings = '';
runpath = ('Y:\Personal\Peter\Data\IVSK\20190620');

%% concentate matfiles
% with additional info of run, files, and location

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


%% create reaction time and such

RT= (NaN(length(trial),2));

    if plot_trials,
        hf = figure('Name','Plot trial','CurrentChar',' ');
    end

    for k = 1:length(trial)


        if (list_successful_only == 1 && trial(k).success) || ~list_successful_only || (list_successful_only==2 && ~trial(k).success) % entweder alle erfolgreichen oder alle trials

            % align time axis to trial start
            trial(k).states_onset = trial(k).states_onset - trial(k).tSample_from_time_start(1); % setze die states_onsets auf "Null"(nicht wirklich, da irgendwie nicht wirklich 0)
            trial(k).tSample_from_time_start = trial(k).tSample_from_time_start - trial(k).tSample_from_time_start(1); % setze den Beginn des Trials auf 0

            % WARUM FÄNGT DER STATE IMMER VOR 0 an?

            if plot_trials,
                figure(hf);
                subplot(3,1,1); hold on;
                title(sprintf('Eye Position, Trial %d',k));

                plot(trial(k).tSample_from_time_start,trial(k).state,'k');
                plot(trial(k).tSample_from_time_start,trial(k).x_eye,'g');
                plot(trial(k).tSample_from_time_start,trial(k).y_eye,'m');
                ig_add_multiple_vertical_lines(trial(k).states_onset,'Color','k');
                ylabel('Eye position, states');


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
                subplot(3,1,2); hold on;
                title(sprintf('Hand Position, Trial %d',...
                    k));

                plot(trial(k).tSample_from_time_start,trial(k).state,'k');
                plot(trial(k).tSample_from_time_start,trial(k).x_hnd,'g');
                plot(trial(k).tSample_from_time_start,trial(k).y_hnd,'m');
                ig_add_multiple_vertical_lines(trial(k).states_onset,'Color','k');
                ylabel('Hand position, states');



                figure(hf);
                subplot(3,1,3)
                plot(trial(k).tSample_from_time_start,[NaN; diff(trial(k).tSample_from_time_start)],'k.');
                ylabel('Sampling interval');

            end


            if plot_trials,
                figure(hf);
                ig_set_all_axes('Xlim',[trial(k).tSample_from_time_start(1) trial(k).tSample_from_time_start(end)]);
                %drawnow; pause;

                if get(gcf,'CurrentChar')=='q',
                    % close;
                    break;
                end
                clf(hf);
            end
            
        end % if successful...  


        if trial(k).completed
            RT(k,1)= trial(k).states_onset(trial(k).states==10) - trial(k).states_onset(trial(k).states==9);
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
RT.choice = categorical(RT.choice, [0 1], {'instr' 'choi'});
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
    'EYE_FIX_ACQ_STATE'
    'HND_FIX_ACQ_STATE'
    
    'EYE_FIX_HOLD_STATE'
    'HND_FIX_HOLD_STATE'
    
    'EYE_CUE_ON'
    'HND_CUE_ON'
    
    'EYE_TAR_ACQ_STATE' % wenn dya.time_spent_in_state < 0.2
    'HND_TAR_ACQ_STATE' % ???
    
    'EYE_MEM_PER_STATE'
    'HND_MEM_PER_STATE'
    
    'EYE_TAR_ACQ_INV_STATE'
    'HND_TAR_ACQ_INV_STATE'
    
    'EYE_TAR_HOLD_INV_STATE'
    'HND_TAR_HOLD_INV_STATE'
    
    'WRONG_TARGET_SELECTED'
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
RT.effector = categorical(RT.effector, [3 4], {'eye', 'hand'});


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


%% Errors clustered by intruction

Err= rowfun(@numel,RT,'GroupingVariables',{'abort_code','effector','trial_type'},'InputVariables',{'value'});
Err.prop = Err.GroupCount./(sum(Err.GroupCount)) * 100 ;
Err.choi = zeros(height(Err),1);
Err.choi(Err.trial_type == 'choi_both') = +1;
Err.choi = categorical(Err.choi, [0 1], {'instr' 'choi'});

Err.cause = cell(height(Err),1);
Err.cause(strncmpi('EYE',cellstr(Err.abort_code),3)) = {'eye_cause'};
Err.cause(strncmpi('HND',cellstr(Err.abort_code),3)) = {'hand_cause'};

%% Errors clustered by behavior

Err_b= rowfun(@numel,RT,'GroupingVariables',{'abort_code','effector','target_selected','choice'},'InputVariables',{'value'});
Err_b.prop = Err.GroupCount./(sum(Err.GroupCount)) * 100 ;
Err.choi = zeros(height(Err),1);
Err.choi(Err.trial_type == 'choi_both') = +1;
Err.choi = categorical(Err.choi, [0 1], {'instr' 'choi'});

Err.cause = cell(height(Err),1);
Err.cause(strncmpi('EYE',cellstr(Err.abort_code),3)) = {'eye_cause'};
Err.cause(strncmpi('HND',cellstr(Err.abort_code),3)) = {'hand_cause'};


%% plots 
if 1
%%
figure; % Succes Rate
g5(1,1) = gramm('x',categorical(RT.success), 'color', RT.choice,'column',RT.effector);
g5(1,1).stat_bin('normalization','probability');
%g5(1,1).facet_wrap(RT.effector);
g5(1,1).set_names('x','','y','proportion in %','Color','','row','','column','');

g5(2,1) = gramm('x',categorical(RT.success),'color', RT.trial_type,'column',RT.effector,'subset', RT.trial_type ~= 'choi_both');
g5(2,1).stat_bin('normalization','probability');
g5(2,1).set_color_options('map','brewer2');
g5(2,1).set_names('x','','y','proportion in %','Color','','row','','column','');

g5.set_title({'success rate clustered by instruction'});
g5.draw;

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



%%
figure; %7 Which Errors
g6 = gramm('x', Err.abort_code,'y', Err.prop,'color',Err.trial_type, 'subset', Err.abort_code ~= 'NO ABORT');
g6.stat_summary('geom','bar');
g6.facet_grid(Err.cause,Err.effector);
g6.set_text_options('base_size',8);
g6.set_names('x','','y','proportion in %','Color','instruction','row','cause of error','column','');
g6.set_title({'Which errors occur for which effector? Clustered by instruction'});
g6.draw;


%%

figure; %4 choice bias
g3(1,1) = gramm('x', RT.target_selected, 'subset', RT.target_selected ~= 'none' & RT.choice == 'choi' & RT.success);
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



end

