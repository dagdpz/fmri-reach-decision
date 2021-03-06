function frd_pipeline3_automized

clear all
%
load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\protocols_v2.mat');

% throwaway = ~strcmp('ANEL',{prot.name})& ...
%       ~strcmp('CLSC',{prot.name}) &...    
%       ~strcmp('DAGU',{prot.name}) &...    
%       ~strcmp('ELRH',{prot.name}) &...    
%       ~strcmp('FARA',{prot.name}) &...  
%       ~strcmp('JAKU',{prot.name}) &...
%       ~strcmp('JOOD',{prot.name}) &...
%       ~strcmp('LORU',{prot.name}) &...
%       ~strcmp('NORE',{prot.name}) &...
%       ~strcmp('OLPE',{prot.name});

% throwaway = ~strcmp('OLPE',{prot.name});
% 
% prot(throwaway) = [];

runpath = 'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI';


%% test 
% load('D:\MRI\Human\fMRI-reach-decision\test_subject\JOOD_protocol.mat');
% throwaway = strcmp('JOODcorr',{prot.name});
% 
% prot(~throwaway) = [];
% 
% runpath = 'D:\MRI\Human\fMRI-reach-decisiontest_subject';
%%

save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline','prot', 'runpath')  % has to be hard coded, see below as well




% %% NO OUTLIER PREDS
%  %% glm cue centered
% for i = 1:length(prot)
%     
%     % no outlier preds
%     ne_pl_multisession_3TUMG_part2(...
%         [runpath filesep prot(i).name],...              % basedir
%         {prot(i).session().date},...                    % session_list
%         '',...                                          % dataset_path
%         [prot(i).name '_combined_glm_cue'],...   % dataset_name (How to call the file) '_combined_no_outliers_glm_cue'
%         '*forglm_cue.avg',...                               % avg_name '*no_outliers.avg' '*forglm_cue.avg'
%         'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
%         {'all'},...                                     % proc_steps_array
%         'sdm_pattern',...                               % varargin
%             '*MCparams.sdm' ,...                        % '*MCparams.sdm'  '*outlier_preds.sdm'
%         'vtc_pattern',...  
%             '*_tf.vtc',...
%         'model',...
%             'mat2prt_reach_decision_vardelay_forglm');
%   
% %     % including outlier preds
% %     ne_pl_multisession_3TUMG_part2(...
% %         [runpath filesep prot(i).name],...              % basedir
% %         {prot(i).session().date},...                    % session_list
% %         '',...                                          % dataset_path
% %         [prot(i).name '_combined_no_outliers_glm_cue'],...   % dataset_name (How to call the file) '_combined_no_outliers_glm_cue'
% %         '*no_outliers.avg',...                           % avg_name '*no_outliers.avg' '*forglm_cue.avg'
% %         'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
% %         {'all'},...                                     % proc_steps_array
% %         'sdm_pattern',...                               % varargin
% %              '*outlier_preds.sdm' ,...                        % '*MCparams.sdm'  '*outlier_preds.sdm'
% %         'vtc_pattern',...  
% %             '*_tf.vtc',...
% %         'model',...
% %             'mat2prt_reach_decision_vardelay_forglm');
%         
%         
%         
%     
%     %% take care of memory
%     save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline','prot', 'runpath','i')
%     %memory
%     %inmem
%     
%     clear all
%     
%     load('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline')
%     %memory
%     %inmem
%     
%     
% end

%% avg's
center = {'cue', 'mov'};
delay = {'3','6','9','12','15'};


for i = 1:length(prot)
    
    for c = 1:length(center)
        
        for d = 1:length(delay)
    
    % not including outlier preds        
    ne_pl_multisession_3TUMG_part2(...
        [runpath filesep prot(i).name],...              % basedir
        {prot(i).session().date},...                    % session_list
        '',...                                          % dataset_path
        [prot(i).name '_combined_avg_' center{c} '_' delay{d}],...           % dataset_name '_combined_no_outliers_glm_cue'     (How the file will be called) 
        ['*foravg_' center{c} '_' delay{d} '.avg'],...  % avg_name    '*no_outliers.avg' '*forglm_cue.avg' (Which avg from each session is being looked for) 
        'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
        {'create_avg'},...                              % proc_steps_array
        'sdm_pattern',...                               % varargin
            '*MCparams.sdm',...                         % '*MCparams.sdm' '*outlier_preds.sdm'
        'model',...
            'mat2prt_reach_decision_vardelay_foravg');

%     % including outlier preds        
%     ne_pl_multisession_3TUMG_part2(...
%         [runpath filesep prot(i).name],...              % basedir
%         {prot(i).session().date},...                    % session_list
%         '',...                                          % dataset_path
%         [prot(i).name '_combined_avg_' center{c} '_' delay{d} '_no_outliers'],...           % dataset_name '_combined_no_outliers_glm_cue'     (How the file will be called) 
%         ['*foravg_' center{c} '_' delay{d} '_no_outliers.avg'],...  % avg_name    '*no_outliers.avg' '*forglm_cue.avg' (Which avg from each session is being looked for) 
%         'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
%         {'create_avg'},...                              % proc_steps_array
%         'sdm_pattern',...                               % varargin
%             '*outlier_preds.sdm',...                         % '*MCparams.sdm' '*outlier_preds.sdm'
%         'model',...
%             'mat2prt_reach_decision_vardelay_foravg');

    %% take care of memory
    save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath','i','c','d','center','delay')
    %memory
    %inmem
    
    clear all
    
    load('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat')
    %memory
    %inmem
    
        end
    end
end


% %% WITH OUTLIER PREDS
% %%  %% glm cue centered
% for i = 1:length(prot)
% %     
% %     % no outlier preds
% %     ne_pl_multisession_3TUMG_part2(...
% %         [runpath filesep prot(i).name],...              % basedir
% %         {prot(i).session().date},...                    % session_list
% %         '',...                                          % dataset_path
% %         [prot(i).name '_combined_glm_cue'],...   % dataset_name (How to call the file) '_combined_no_outliers_glm_cue'
% %         '*forglm_cue.avg',...                               % avg_name '*no_outliers.avg' '*forglm_cue.avg'
% %         'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
% %         {'all'},...                                     % proc_steps_array
% %         'sdm_pattern',...                               % varargin
% %             '*MCparams.sdm' ,...                        % '*MCparams.sdm'  '*outlier_preds.sdm'
% %         'vtc_pattern',...  
% %             '*_tf.vtc',...
% %         'model',...
% %             'mat2prt_reach_decision_vardelay_forglm');
%   
%     % including outlier preds
%     ne_pl_multisession_3TUMG_part2(...
%         [runpath filesep prot(i).name],...              % basedir
%         {prot(i).session().date},...                    % session_list
%         '',...                                          % dataset_path
%         [prot(i).name '_combined_no_outliers_glm_cue'],...   % dataset_name (How to call the file) '_combined_no_outliers_glm_cue'
%         '*no_outliers.avg',...                           % avg_name '*no_outliers.avg' '*forglm_cue.avg'
%         'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
%         {'all'},...                                     % proc_steps_array
%         'sdm_pattern',...                               % varargin
%              '*outlier_preds.sdm' ,...                        % '*MCparams.sdm'  '*outlier_preds.sdm'
%         'vtc_pattern',...  
%             '*_tf.vtc',...
%         'model',...
%             'mat2prt_reach_decision_vardelay_forglm');
%         
%         
%         
%     
%     %% take care of memory
%     save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline','prot', 'runpath','i')
%     %memory
%     %inmem
%     
%     clear all
%     
%     load('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline')
%     %memory
%     %inmem
%     
%     
% end

%% avg's
center = {'cue', 'mov'};
delay = {'3','6','9','12','15'};


for i = 1:length(prot)
    
    for c = 1:length(center)
        
        for d = 1:length(delay)
    
%     % not including outlier preds        
%     ne_pl_multisession_3TUMG_part2(...
%         [runpath filesep prot(i).name],...              % basedir
%         {prot(i).session().date},...                    % session_list
%         '',...                                          % dataset_path
%         [prot(i).name '_combined_avg_' center{c} '_' delay{d}],...           % dataset_name '_combined_no_outliers_glm_cue'     (How the file will be called) 
%         ['*foravg_' center{c} '_' delay{d} '.avg'],...  % avg_name    '*no_outliers.avg' '*forglm_cue.avg' (Which avg from each session is being looked for) 
%         'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
%         {'create_avg'},...                              % proc_steps_array
%         'sdm_pattern',...                               % varargin
%             '*MCparams.sdm',...                         % '*MCparams.sdm' '*outlier_preds.sdm'
%         'model',...
%             'mat2prt_reach_decision_vardelay_foravg');

    % including outlier preds        
    ne_pl_multisession_3TUMG_part2(...
        [runpath filesep prot(i).name],...              % basedir
        {prot(i).session().date},...                    % session_list
        '',...                                          % dataset_path
        [prot(i).name '_combined_avg_' center{c} '_' delay{d} '_no_outliers'],...           % dataset_name '_combined_no_outliers_glm_cue'     (How the file will be called) 
        ['*foravg_' center{c} '_' delay{d} '_no_outliers.avg'],...  % avg_name    '*no_outliers.avg' '*forglm_cue.avg' (Which avg from each session is being looked for) 
        'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
        {'create_avg'},...                              % proc_steps_array
        'sdm_pattern',...                               % varargin
            '*outlier_preds.sdm',...                         % '*MCparams.sdm' '*outlier_preds.sdm'
        'model',...
            'mat2prt_reach_decision_vardelay_foravg');

    %% take care of memory
    save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath','i','c','d','center','delay')
    %memory
    %inmem
    
    clear all
    
    load('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat')
    %memory
    %inmem
    
        end
    end
end


