function frd_pipeline3_automized
% wrapper function for First Level Analysis and AVG creation PER SUBJECT using NeuroElf.

% This function is specific to the fmri_reach_decision project.

%%
clear all

load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\protocols_v2.mat');

runpath = 'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI';

for_GLM = 1; % 0
for_AVG = 1; % 0

% AVG settings, to identify which delay names
center = {'cue', 'mov'};
delay = {'3','6','9','12','15'};

%%

save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline','prot', 'runpath','center','delay','for_GLM','for_AVG')  % has to be hard coded, see below as well



%% glm cue centered

if for_GLM
    for i = 1:length(prot)
        
        % no outlier preds
        %     ne_pl_multisession_3TUMG_part2(...
        %         [runpath filesep prot(i).name],...              % basedir
        %         {prot(i).session().date},...                    % session_list
        %         '',...                                          % dataset_path
        %         [prot(i).name '_combined_glm_cue'],...          % dataset_name (How to call the file) '_combined_no_outliers_glm_cue'
        %         '*forglm_cue.avg',...                           % avg_name '*no_outliers.avg' '*forglm_cue.avg'
        %         'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
        %         {'all'},...                                     % proc_steps_array
        %         'sdm_pattern',...                               % varargin
        %             '*MCparams.sdm' ,...                        % '*MCparams.sdm'  '*outlier_preds.sdm'
        %         'vtc_pattern',...
        %             '*_tf.vtc',...
        %         'model',...
        %             'mat2prt_reach_decision_vardelay_forglm');
        
        % including outlier preds
        ne_pl_multisession_3TUMG_part2(...
            [runpath filesep prot(i).name],...              % basedir
            {prot(i).session().date},...                    % session_list
            '',...                                          % dataset_path
            [prot(i).name '_combined_no_outliers_glm_cue'],...   % dataset_name (How to call the file) '_combined_no_outliers_glm_cue'
            '*no_outliers.avg',...                          % avg_name '*no_outliers.avg' '*forglm_cue.avg'
            'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
            {'all'},...                                     % proc_steps_array
            'sdm_pattern',...                               % varargin
                '*outlier_preds.sdm' ,...                  % '*MCparams.sdm'  '*outlier_preds.sdm'
            'vtc_pattern',...
                '*_tf.vtc',...
            'model',...
                'mat2prt_reach_decision_vardelay_forglm');
        
        
        
        
        %% take care of memory
        save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline','prot', 'runpath','i','center','delay','for_GLM','for_AVG')
        %memory
        %inmem
        
        clear all
        
        load('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline')
        %memory
        %inmem
        
        
    end
end


%% avg's

if for_AVG
    for i = 1:length(prot)
        
        for c = 1:length(center)
            
            for d = 1:length(delay)
                
                % not including outlier preds
                %     ne_pl_multisession_3TUMG_part2(...
                %         [runpath filesep prot(i).name],...              % basedir
                %         {prot(i).session().date},...                    % session_list
                %         '',...                                          % dataset_path
                %         [prot(i).name '_combined_avg_' center{c} '_' delay{d}],...    % dataset_name '_combined_no_outliers_glm_cue'     (How the file will be called)
                %         ['*foravg_' center{c} '_' delay{d} '.avg'],...                % avg_name    '*no_outliers.avg' '*forglm_cue.avg' (Which avg from each session is being looked for)
                %         'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
                %         {'create_avg'},...                              % proc_steps_array
                %         'model',...
                %             'mat2prt_reach_decision_vardelay_foravg');
                
                % including outlier preds
                ne_pl_multisession_3TUMG_part2(...
                    [runpath filesep prot(i).name],...              % basedir
                    {prot(i).session().date},...                    % session_list
                    '',...                                          % dataset_path
                    [prot(i).name '_combined_avg_' center{c} '_' delay{d} '_no_outliers'],...   % dataset_name '_combined_no_outliers_glm_cue'     (How the file will be called)
                    ['*foravg_' center{c} '_' delay{d} '_no_outliers.avg'],...                  % avg_name    '*no_outliers.avg' '*forglm_cue.avg' (Which avg from each session is being looked for)
                    'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
                    {'create_avg'},...                              % proc_steps_array
                    'model',...
                        'mat2prt_reach_decision_vardelay_foravg');
                
                %% take care of memory
                save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath','i','c','d','center','delay','for_GLM','for_AVG')
                %memory
                %inmem
                
                clear all
                
                load('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat')
                %memory
                %inmem
                
            end
        end
    end
end


