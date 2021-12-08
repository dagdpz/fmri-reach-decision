function frd_pipeline4

clear all

load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\protocols_v2.mat');

runpath = 'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI';

for_GLM = 1;
for_AVG = 1;

% AVG settings, to identify which delay names
center = {'cue', 'mov'};
delay = {'3','6','9','12','15'};
 
%%
session_list = {};
for s = 1:length(prot)
    for d = 1:length(prot(s).session)
        sesh = {[prot(s).name filesep prot(s).session(d).date]};
        session_list = [session_list sesh];
    end
end

%%
if for_GLM
    %% without outlier preds
    
    %     % glm cue centered MDM and GLM
    %     ne_pl_multisession_3TUMG_part2(...
    %         [runpath],...                                   % basedir
    %         session_list,...                                % session_list
    %         '',...                                          % dataset_path
    %         ['Exp_combined_glm_cue'],...                    % dataset_name
    %         '*combined_glm_cue.avg',...                     % avg_name  '*no_outliers_glm_cue.avg',  '*combined_glm_cue.avg'
    %         'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
    %         {'create_mdm','create_glm'},...                 % proc_steps_array
    %         'sdm_pattern',...                               % varargin
    %             '*MCparams.sdm',...
    %         'vtc_pattern',...
    %             '*_tf.vtc',...
    %         'model',...
    %             'mat2prt_reach_decision_vardelay_forglm');
    %
    %     % glm cue centered AVG
    %     ne_pl_multisession_3TUMG_part2(...
    %         [runpath],...                                   % basedir
    %         {prot.name},...                                 % session_list
    %         '',...                                          % dataset_path
    %         ['Exp_combined_glm_cue'],...                    % dataset_name
    %         '*combined_glm_cue.avg',...                     % avg_name  '*no_outliers_glm_cue.avg',  '*combined_glm_cue.avg'
    %         'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
    %         {'create_avg'},...                              % proc_steps_array
    %         'vtc_pattern',...
    %             '*_tf.vtc',...
    %         'model',...
    %             'mat2prt_reach_decision_vardelay_forglm');
    %  %% buffer
    %
    %  save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath','session_list','center','delay','for_GLM','for_AVG')
    %  %memory
    %  %inmem
    %
    %  clear all
    %
    %  load('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat')
    %  %memory
    %  %inmem
    
    %% including outlier preds
    
        % glm cue centered MDM and GLM
        ne_pl_multisession_3TUMG_part2(...
            runpath,...                                     % basedir
            session_list,...                                % session_list
            '',...                                          % dataset_path
            'Exp_combined_no_outliers_glm_cue',...          % dataset_name
            '*no_outliers_glm_cue.avg',...                  % avg_name  '*no_outliers_glm_cue.avg',  '*combined_glm_cue.avg'
            'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
            {'create_mdm','create_glm'},...                 % proc_steps_array
            'sdm_pattern',...                               % varargin
                '*outlier_preds.sdm',...
            'vtc_pattern',...
                '*_tf.vtc',...
            'model',...
                'mat2prt_reach_decision_vardelay_forglm');
    
        % glm cue centered AVG
        ne_pl_multisession_3TUMG_part2(...
            runpath,...                                     % basedir
            {prot.name},...                                 % session_list
            '',...                                          % dataset_path
            'Exp_combined_no_outliers_glm_cue',...          % dataset_name
            '*no_outliers_glm_cue.avg',...                  % avg_name  '*no_outliers_glm_cue.avg',  '*combined_glm_cue.avg'
            'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
            {'create_avg'},...                              % proc_steps_array
            'vtc_pattern',...
                '*_tf.vtc',...
            'model',...
                'mat2prt_reach_decision_vardelay_forglm');
    
            
            
            save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath','session_list','center','delay','for_GLM','for_AVG')
            %memory
            %inmem
            
            clear all
            
            load('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat')
            %memory
            %inmem

end


%% cue and mov centered AVGs per delay

if for_AVG
     for c = 1:length(center)

         for d = 1:length(delay)

             % with outlier volumes
    %          ne_pl_multisession_3TUMG_part2(...
    %              [runpath],...                                   % basedir
    %              {prot.name},...                                 % session_list
    %              '',...                                          % dataset_path
    %              ['Exp_combined_avg_' center{c} '_' delay{d}],...   % dataset_name [prot(i).name '_combined_avg_' center{c} '_' delay{d}]
    %              ['*avg_' center{c} '_' delay{d} '.avg'],...        % avg_name  '*no_outliers_glm_cue.avg',  '*combined_glm_cue.avg'
    %              'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
    %              {'create_avg'},...                              % proc_steps_array
    %              'model',...
    %                 'mat2prt_reach_decision_vardelay_foravg');

             % no outlier volumes
             ne_pl_multisession_3TUMG_part2(...
                 [runpath],...                                   % basedir
                 {prot.name},...                                 % session_list
                 '',...                                          % dataset_path
                 ['Exp_combined_avg_' center{c} '_' delay{d} '_no_outliers'],...    % dataset_name [prot(i).name '_combined_avg_' center{c} '_' delay{d}]
                 ['*avg_' center{c} '_' delay{d} '_no_outliers.avg'],...            % avg_name  '*no_outliers_glm_cue.avg',  '*combined_glm_cue.avg'
                 'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
                 {'create_avg'},...                              % proc_steps_array
                 'model',...
                    'mat2prt_reach_decision_vardelay_foravg');


        save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath','c','d','center','delay','session_list','for_GLM','for_AVG')
        %memory
        %inmem

        clear all

        load('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat')
        %memory
        %inmem

         end
     end
end
