function frd_analyze_one_session_behavior_v2(runpath)
% What to put in:

% runpath:              A) specific matfile,    B) session folder   C) subject folder    D) experiment folder
% list_successful_only: 0) all trials           1) successful only  2) failed only
% plot_trials:          0) no plots of single trials                1) plots every single trial in 1D    2) plots every single trial in 2D 
% do_summary:           0) no summary plots     1) summary plots
% detect saccades:      idk
% detect_saccades_custom_settings: idk


% TODO:
% only read in experimental folders, not shuffled conditions etc.
% figure size
% title with subj/session
% export to pdf properly
% plot trials in 2D for all trials, not only unsuccessful
% subject wise analysis + whole experiment analysis


%% load in data

[trial, analysis_level] = frd_conc_trial(runpath);

   
%% Define new and correct states and states_onset
% this part overwrites states_onset with the all onsets and their time from
% tSample....
for k = 1:length(trial)
    
    trial(k).states = unique(trial(k).state,'stable')'; % now trial.states includes all states
    
    indi = logical([1 (diff(trial(k).state) ~= 0)']);
    trial(k).states_onset = trial(k).tSample_from_time_start(indi)';
    
end

%% create reaction time and such

dat = (NaN(length(trial),6));

for k = 1:length(trial)
    
    % +++ real RT
    if trial(k).effector == 3 && trial(k).completed == 1 %saccades
        
        out = em_saccade_blink_detection(trial(k).tSample_from_time_start,trial(k).x_eye,trial(k).y_eye,...
            'frd_em_custom_settings_humanUMGscanner60Hz.m');
        
        mov_onset = [out.sac_onsets];
        mov_onset = mov_onset(mov_onset > trial(k).states_onset(trial(k).states==9)); % all onsets occuring after Tar_Aqu state
        
        dat(k,1) = mov_onset(1) - trial(k).states_onset(trial(k).states==9); % calulate realRT
        
    elseif trial(k).effector == 4 && trial(k).completed == 1% reaches
        % Interpolate to remove NaNs
        idx_nonnan = find(~isnan(trial(k).x_hnd));
        
        t = trial(k).tSample_from_time_start(idx_nonnan(1):idx_nonnan(end));
        x_ = trial(k).x_hnd(idx_nonnan(1):idx_nonnan(end));
        y_ = trial(k).y_hnd(idx_nonnan(1):idx_nonnan(end));
        
        x = interp1(t(~isnan(x_)),x_(~isnan(x_)),t);
        y = interp1(t(~isnan(x_)),y_(~isnan(y_)),t);
        
        
        out = em_saccade_blink_detection(t,x,y,...
            'frd_em_custom_settings_humanUMGscannerTouchscreen125Hz.m');
        
        mov_onset = [out.sac_onsets];
        mov_onset = mov_onset(mov_onset > trial(k).states_onset(trial(k).states==9)); % all onsets occuring after Tar_Aqu state
        
        dat(k,1) = mov_onset(1) - trial(k).states_onset(trial(k).states==9); % calulate realRT
        
    end
    

    % +++ state RT
    if trial(k).completed
        dat(k,2)= trial(k).states_onset(trial(k).states==10) - trial(k).states_onset(trial(k).states==9); %%% CHANGE HERE
    end
    
    % +++ if choice or not
    if trial(k).task.correct_choice_target == [1 2]
        dat(k,3) = 1;
    elseif trial(k).task.correct_choice_target == 1
        dat(k,3) = 0;
    end

    
    % +++ delay
    dat(k,4) = trial(k).task.timing.mem_time_hold;
    
    % +++ target selected
    if ~isnan(trial(k).target_selected) 
        % used to be: if trial(k).completed == 1
        % the reason for that change here is, because you can have a
        % target selected, but abort during hold, meaning no completion.
        % Thats the difference.
        
        if trial(k).effector == 3 % get only saccade trials
            whichtarget = trial(k).target_selected(1); % here in saccade trials pic the number (can be 1 or 2) which is FIRST in target_selected (because it is for saccades)
            
            %dat.target_N_selected(k)=trial(k).target_selected(1);
            if       trial(k).eye.tar(whichtarget).pos(1) < 0
               dat(k,5) = -1;
            elseif   trial(k).eye.tar(whichtarget).pos(1) > 0
               dat(k,5) = 1;
            else
               dat(k,5) = 99;
            end
            
        elseif trial(k).effector == 4 % get only reach trials
            whichtarget = trial(k).target_selected(2); % here in reach trials pic the number (its value can be 1 or 2) which is SECOND in target_selected (because it is for reaches)
            
            %dat.target_N_selected(k)=trial(k).target_selected(2);
            if       trial(k).hnd.tar(whichtarget).pos(1) < 0
                dat(k,5) = -1;
            elseif   trial(k).hnd.tar(whichtarget).pos(1) > 0
                dat(k,5) = 1;
            else
                dat(k,5) = 99;
            end
            
        end
        
    else
        dat(k,5) = 0;
        
    end
    
    
    % +++ correct target
    if numel(trial(k).task.correct_choice_target)>1
        dat(k,6) = 0;
        
    elseif trial(k).effector==3
        if trial(k).task.eye.tar(trial(k).task.correct_choice_target).x <0
            dat(k,6) = -1;
        elseif trial(k).task.eye.tar(trial(k).task.correct_choice_target).x >0
            dat(k,6) = 1;
        end
        
    elseif trial(k).effector==4
        if trial(k).task.hnd.tar(trial(k).task.correct_choice_target).x <0
            dat(k,6) = -1;
        elseif trial(k).task.hnd.tar(trial(k).task.correct_choice_target).x >0
            dat(k,6) = 1;
        end
        
    end
    

    
    
end % for each trial

% create table
dat = array2table(dat);
dat.Properties.VariableNames  = {'RT' 'stateRT' 'choice' 'delay' 'target_selected' 'correct_target'};

% add complete, success, effector and a running number
dat.choice       = categorical(dat.choice, [0 1], {'instructed' 'choice'});
dat.complete     = logical([trial.completed]');
dat.success      = logical([trial.success]');
dat.effector     = [trial.effector]';
dat.number       = [1:length(dat.success)]';

% into categorical 
dat.run          = categorical([trial.run]');
dat.session      = categorical([trial.session]');
dat.subj         = categorical({trial.subj}');
dat.correct_target  = categorical(dat.correct_target,[-1 0 1],{'left' 'both' 'right'});
dat.target_selected = categorical(dat.target_selected,[-1 0 1],{'left' 'none' 'right'});
dat.delay        = categorical(dat.delay);
dat.effector = categorical(dat.effector, [3 4], {'saccade', 'reach'});

% shorten 
dat.cause_abort = cell(height(dat),1);
dat.cause_abort(strncmpi('ABORT_EYE',{trial.abort_code}',9)) = {'eye_cause'};
dat.cause_abort(strncmpi('ABORT_HND',{trial.abort_code}',9)) = {'hand_cause'};

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

dat.abort_code       = categorical({trial.abort_code}',valueset,names);




% RT_struct=table2struct(dat);
% for k=1:size(dat,1)
%     choice_cell=cellstr(RT_struct(k).choice);
%     correct_cell=cellstr(RT_struct(k).correct_target);
%     dat.trial_type{k}=[choice_cell{1} '_' correct_cell{1}];
% end

% dat.trial_type= categorical(dat.trial_type);



% gib mir für alle instructed trials(nicht both), die Targets an, in denen
% das falsche Target gewählt wurde (auch die, wo vorher der Trial aborted
% wurde weil fixation break during HOLD

dat.wrong_target_selected = zeros(height(dat),1);
dat.wrong_target_selected(...
    dat.correct_target ~= 'both' & ...
    dat.target_selected == ('right') & ...
    dat.target_selected == ('left') & ...
    dat.target_selected ~= dat.correct_target ...
    ) = 1;
dat.wrong_target_selected = logical(dat.wrong_target_selected);

dat.aborted_state_duration = [trial.aborted_state_duration]';
%%
disp('stop here')
%%
% RT AND DELAY
figure;
gDelay=gramm('x',dat.delay,'y',dat.RT,'color',dat.session)
gDelay.set_order_options('x',{'3' '6' '9' '12' '15'})
gDelay.facet_grid(dat.target_selected,dat.effector)
gDelay.stat_boxplot()
gDelay.set_names('Column','','x','delay','y','reaction time')
gDelay.set_title('Influence of delay on reaction time')
gDelay.draw()

% Right VS Left hand
figure;
gHand=gramm('x',dat.target_selected,'y',dat.RT,'color',dat.session)
gHand.facet_grid([],dat.session)
gHand.stat_boxplot()
gHand.set_names('Column','session','x','Hand choice','y','reaction time')
gHand.set_title('Influence of Hand choice on reaction time')
gHand.draw()

% Instructed VS Choice
figure;
gChoice=gramm('x',dat.choice,'y',dat.RT,'color',dat.session)
gChoice.facet_grid([],dat.session)
gChoice.stat_boxplot()
gChoice.set_names('Column','session','x','Decision','y','reaction time')
gChoice.set_title('Influence of free choice on reaction time')
gChoice.draw()

% Saccade VS Reach
figure;
gEffector=gramm('x',dat.effector,'y',dat.RT,'color',dat.session)
gEffector.facet_grid([],dat.session)
gEffector.stat_boxplot()
gEffector.set_names('Column','session','x','Effector','y','reaction time')
gEffector.set_title('Influence of effector choice on reaction time')
gEffector.draw()








%% Errors clustered by intruction

Err= rowfun(@numel,dat,'GroupingVariables',{'abort_code','effector','trial_type'},'InputVariables',{'value'});
Err.prop = Err.GroupCount./(sum(Err.GroupCount)) * 100 ;
Err.choi = zeros(height(Err),1);
Err.choi(Err.trial_type == 'choi_both') = +1;
Err.choi = categorical(Err.choi, [0 1], {'instr' 'choi'});

Err.cause = cell(height(Err),1);
Err.cause(strncmpi('EYE',cellstr(Err.abort_code),3)) = {'eye_cause'};
Err.cause(strncmpi('HND',cellstr(Err.abort_code),3)) = {'hand_cause'};


%% Trajectories using gramm
A = arrayfun(@(a)   {a.x_eye(a.state == 9 | a.state == 10)},trial);
B = arrayfun(@(a)   {a.y_eye(a.state == 9 | a.state == 10)},trial);
A_abs = arrayfun(@(a)   {abs(a.x_eye(a.state == 9 | a.state == 10))},trial);

C = arrayfun(@(a)   {a.x_hnd(a.state == 9 | a.state == 10)},trial);
D = arrayfun(@(a)   {a.y_hnd(a.state == 9 | a.state == 10)},trial);
C_abs = arrayfun(@(a)   {abs(a.x_hnd(a.state == 9 | a.state == 10))},trial);

%%



%%








% %% Saccades normal 
% figure('Name','saccade trajectories, for target acquisiton + hold phase');
%     g1 = gramm('x',A,'y',B,'group',categorical([1:length(trial)]),'color',dat.choice, 'subset',dat.effector == 'saccade' & dat.success);
%     g1.geom_line();
%     g1.axe_property('Xlim',[-15 15],'Ylim',[-9 9]);
%     g1.set_line_options('base_size',0.1);
%     g1.set_title('saccade trajectories, for target acquisiton + hold phase');
%     g1.set_names('x','x_trajcetories','y','y_trajectories','Color','','row','','column',''); 
%     g1.draw;
% 
% %% Reaches normal
% figure('Name','reach trajectories, for target acquisiton + hold phase');
%     g2 = gramm('x',C,'y',D,'group',categorical([1:length(trial)]),'color',dat.choice, 'subset',dat.effector == 'reach' & dat.success);
%     g2.geom_line('alpha',0);
%     g2.axe_property('Xlim',[-15 15],'Ylim',[-9 9]);
%     g2.set_line_options('base_size',0.1);
%     g2.set_title('reach trajectories, for target acquisiton + hold phase');
%     g2.set_names('x','x_trajcetories','y','y_trajectories','Color','','row','','column',''); 
%     g2.draw;
%     
% 
% %% AUGEN folded left to right
% figure('Name','left movements mirrored onto the right, for target acquisiton + hold phase');
%     g0(1,1) = gramm('x',A_abs,'y',B,'group',categorical([1:length(trial)]),'color',dat.target_selected, 'subset',dat.effector == 'saccade' & dat.success);
%     g0(1,1).geom_point();
%     g0(1,1).axe_property('Xlim',[0 15],'Ylim',[-4 4]);
%     g0(1,1).set_names('x','abs(x_trajcetories)','y','y_trajectories','Color','','row','','column','');   
%     g0(1,1).set_title('saccades');
%     
%     g0(2,1) = gramm('x',C_abs,'y',D,'group',categorical([1:length(trial)]),'color',dat.target_selected, 'subset',dat.effector == 'reach' & dat.success);
%     g0(2,1).geom_point('alpha',0);
%     g0(2,1).axe_property('Xlim',[0 15],'Ylim',[-4 4]);
%     g0(2,1).set_title('reaches');
%     
%     g0.set_names('x','abs(x_trajcetories)','y','y_trajectories','Color','','row','','column','');   
%     g0.set_title('left movements mirrored onto the right, for target acquisiton + hold phase');
%     g0.set_color_options('map','brewer2');
%     g0.set_point_options('base_size',2);
%     g0.draw;
% 
% %% plots
% 
%     %%
%     figure; % Succes Rate
%     g5(1,1) = gramm('x',categorical(dat.success), 'color', dat.choice,'column',dat.effector);%,'subset',dat.success == 1); %'x',categorical(dat.success
%     g5(1,1).stat_bin('normalization','probability');
%     %g5(1,1).facet_wrap(dat.effector);
%     g5(1,1).set_names('x','','y','proportion in %','Color','','row','','column','');
%     
%     g5(2,1) = gramm('x',categorical(dat.success),'color', dat.trial_type,'column',dat.effector,'subset', dat.trial_type ~= 'choi_both');
%     g5(2,1).stat_bin('normalization','probability');
%     g5(2,1).set_color_options('map','brewer2');
%     g5(2,1).set_names('x','','y','proportion in %','Color','','row','','column','');
%     
%     g5.set_title({'success rate clustered by instruction'});
%     g5.draw;
%     %g5.export('file_name',['SuccessRate_' trial(1).fileinfo.name(1:4) '_' trial(1).path(61:70)],'export_path', runpath(1:59));
%     % g5(2,1) = gramm('x', Err.trial_type,'color', Err.trial_type,'column',Err.effector,'subset', Err.abort_code ~= {'NO ABORT'} & Err.trial_type ~= 'choi_both');
%     % g5(2,1).stat_bin('geom','bar');
%     % g5(2,1).set_color_options('map','brewer2');
%     % g5(2,1).set_names('x','','y','proportion in %','Color','','row','','column','');
%     % g5(2,1).set_title({'instructed left vs. right'});
%     %
%     % g5.set_title({'Proportion of Errors clustered by instruction'});
%     % g5.draw;
%     
%     %%
%     figure; %2 reaction times
%     g(1,1) = gramm('x', dat.value, 'color', dat.choice,'linestyle', dat.target_selected,'column',dat.effector,'subset',logical(dat.success));
%     g(1,1).stat_density();
%     g(1,1).set_names('x','dat / s','Color','','row','','column','','linestyle','target selected');
%     
%     
%     g(2,1) = gramm('x', dat.target_selected, 'y', dat.value,'column',dat.effector,'color', dat.choice,'subset',logical(dat.success));
%     g(2,1).geom_jitter('dodge', 0.8);
%     g(2,1).set_names('x','target selected','y','dat/s','Color','','row','','column','');
%     
%     g.set_title({'reaction time, successfull only, N = ' (sum(dat.success))});
%     g.draw;
%     %g.export('file_name',['RTs_' trial(1).fileinfo.name(1:4) '_' trial(1).path(61:70)],'export_path', runpath(1:59));
%     
%     if strcmp('experiment',analysis_level)
%         figure; %2 reaction times
%         g(1,1) = gramm('x', dat.value, 'color', dat.subj,'row', dat.target_selected,'column',dat.effector,'subset',logical(dat.success));
%         g(1,1).stat_density();
%         g(1,1).set_names('x','dat / s','Color','','row','','column','');
%         g.draw;
%     end
%     
%         
%     %%
%     figure; %7 Which Errors
%     g6 = gramm('x', Err.abort_code,'y', Err.prop,'color',Err.trial_type, 'subset', Err.abort_code ~= 'NO ABORT');
%     g6.stat_summary('geom','bar');
%     g6.facet_grid(Err.cause,Err.effector);
%     g6.set_text_options('base_size',8);
%     g6.set_names('x','','y','proportion in %','Color','instruction','row','cause of error','column','');
%     g6.set_title({'Which errors occur for which effector? Clustered by instruction. proportion of errors: ' (sum(~dat.success))/length(dat.success)  });
%     
%     g6.draw;
%     %g6.export('file_name',['Errors_' trial(1).fileinfo.name(1:4) '_' trial(1).path(61:70)],'export_path', runpath(1:59));
%     
%     %%
%     
%     figure; %4 choice bias
%     g3(1,1) = gramm('x', dat.target_selected, 'subset', dat.target_selected ~= 'none' & dat.choice == 'choice' & dat.success);
%     g3(1,1).stat_bin('geom','bar','normalization','probability');
%     g3(1,1).facet_wrap(dat.effector,'ncols',2);
%     g3(1,1).set_names('x','','y','proportion in %','Color','','row','','column','');
%     g3(1,1).set_title({'relative amount of left/right answers in choice trials'});
%     
%     g3(1,2) = gramm('x',categorical(dat.target_selected), 'color', dat.choice, 'subset', dat.target_selected ~= 'none' & dat.success);
%     g3(1,2).stat_bin('geom','bar','normalization','count');
%     g3(1,2).facet_wrap(dat.effector,'ncols',2);
%     g3(1,2).set_names('x','','y','count','Color','','row','','column','');
%     g3(1,2).set_title({'Is there an equal amount of N in each condition?'});
%     
%     g3(2,2) = gramm('x',dat.effector, 'color', dat.choice, 'subset', dat.target_selected ~= 'none' & dat.success);
%     g3(2,2).stat_bin('geom','bar','normalization','count');
%     g3(2,2).set_names('x','','y','count','Color','','row','','column','');
%     g3(2,2).set_title({'How many trials in choice vs. instructed?'});
%     
%     g3.set_title({'Choice Bias for successful trials'})
%     
%     g3.draw;
%     %g3.export('file_name',['ChoiceBias_' trial(1).fileinfo.name(1:4) '_' trial(1).path(61:70)],'export_path', runpath(1:59),'width',56,'height',33,'units','centimeters');
% 
%     %%
% 
% %%    
% %     figure; % 5 aborted_state_duration
% %     g2 = gramm('x',dat.aborted_state_duration,'row',dat.abort_code,'subset',or(dat.abort_code == 'HND FIX HOLD', dat.abort_code == 'EYE FIX HOLD'));
% %     g2.stat_bin('nbins',200);
% %    % g2.axe_property('XLim',[0 2]);
% %     g2.set_names('x','time in s','y','count','Color','','row','');
% %     g2.set_title({'Fixation Hold Errors for first 2 seconds'})
% %     g2.draw;
% %     
% %     figure;    
% %     g4 = gramm('x',dat.aborted_state_duration,'color',dat.abort_code,'subset',or(dat.abort_code == 'HND FIX HOLD', dat.abort_code == 'EYE FIX HOLD'));
% %     g4.stat_bin('nbins',200);
% %     %g4.axe_property('XLim',[0 2]);
% %     g4.facet_wrap(double(dat.run));
% %     g4.set_names('x','time in s','y','count','Color','','row','');
% %     g4.set_title({'Fixation Hold Errors for first 2 seconds by run'})
% %     g4.draw;
% 
% 
% %% Are trial durations as long as they are supposed to be? - Calculation
% if 0
% periods = struct();
% ITI_v1 = [];
% for k = 1:length(trial)
%     
%     periods(k).states = unique(trial(k).state,'stable')'; 
%     indi = logical([1 (diff(trial(k).state) ~= 0)']);
%     periods(k).states_onset = trial(k).tSample_from_time_start(indi)';
%     
%     periods(k).duration = diff(periods(k).states_onset);
%     ITI_timestamps = trial(k).tSample_from_time_start(trial(k).state == 50);
%     
%     ITI_dur = ITI_timestamps(end) - ITI_timestamps(1);
%     
%     if periods(k).states(end) ~= 99 % all trials when run is still going
%         periods(k).duration(end +1) = ITI_dur;
%     end
%     
%     ITI_v1 = [ITI_v1 ITI_dur];
%     
% end
% 
% %% Are trial durations as long as they are supposed to be? - Visualization
% % this part gives you all supposed durations of periods (hard coded) and
% % their respective real durations (from tSample...)
% 
%     a = struct();
%     for l = 1:length(periods)
%         
%         times = [3 11.8 0.2 trial(l).task.timing.mem_time_hold 1 1 0 0 0 2];
%         pnames = cell({'fix_acq' 'fix' 'cue' 'mem' 'tar_acq_inv' 'tar_hold_inv' 'tar_acq' 'tar_hold' 'reward' 'ITI'});
%         a.pnames = pnames';
%         a.times = times';
%         
%         if length(periods(l).duration) == 10
%             
%             a.dur = periods(l).duration';
%             sum(periods(l).duration((end-3):(end-1)))
%             
%         elseif periods(l).states(end) == 99
%             continue;
%         else
%             w = length(periods(l).states);
%             pnames = [pnames(1:(w-1)) 'ITI'];
%             a.pnames = pnames';
%             times = [times(1:(w-1)) times(end)];
%             a.times = times';
%             a.dur = periods(l).duration';
%         end
%         
%         struct2table(a)
%         pause on
%         pause;
%     end
%     
% end
% 
% %%
% if 0
% load('Y:\MRI\Human\fMRI-reach-decision\Pilot\behavioral data\IGKA\shuffled_conditions\shuffled_conditions_IGKA_presented.mat')
% 
% pre_order = [present.comb_del];
% pre_order = pre_order(1:length(trial));
% 
% dat.pre_order = pre_order;
% [dat.effector dat.choice dat.correct_target categorical(dat.delay) dat.pre_order]
% 
% 
%     %%
%     figure; %2 reaction times
%     g(1,1) = gramm('x', dat.value,'column',dat.effector,'color',dat.run,'subset',logical(dat.success));
%     g(1,1).stat_density();
%     g(1,1).set_names('x','dat / s','Color','','row','','column','','linestyle','target selected');
%     
%     
%     g(2,1) = gramm('x', dat.target_selected, 'y', dat.value,'column',dat.effector,'color',dat.run,'subset',logical(dat.success));
%     g(2,1).geom_point('dodge', 0.8);
%     g(2,1).set_names('x','target selected','y','dat/s','Color','','row','','column','');
%     
%     g.set_title({'reaction time, successfull only, N = ' (sum(dat.success))});
%     g.draw;
%     %g.export('file_name',['RTs_' trial(1).fileinfo.name(1:4) '_' trial(1).path(61:70)],'export_path', runpath(1:59));
% end    
%%
% function circle(x,y,r)
% %x and y are the coordinates of the center of the circle
% %r is the radius of the circle
% %0.01 is the angle step, bigger values will draw the circle faster but
% %you might notice imperfections (not very smooth)
% ang=0:0.01:2*pi; 
% xp=r*cos(ang);
% yp=r*sin(ang);
% plot(x+xp,y+yp,'LineStyle',':','Color','k');
