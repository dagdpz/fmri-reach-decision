function frd_pipeline4

clear all

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
% 
% 
% 
% prot(throwaway) = [];

session_list = {};
for s = 1:length(prot)
    for d = 1:length(prot(s).session)
    sesh = {[prot(s).name filesep prot(s).session(d).date]};
   session_list = [session_list sesh];
   
    end
end

runpath = 'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI';

%% without outlier preds


    % glm cue centered MDM and GLM
    ne_pl_multisession_3TUMG_part2(...
        [runpath],...                                   % basedir
        session_list,...                                 % session_list
        '',...                                          % dataset_path
        ['Exp_combined_glm_cue'],...                   % dataset_name
        '*combined_glm_cue.avg',...               % avg_name  '*no_outliers_glm_cue.avg',  '*combined_glm_cue.avg'
        'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
        {'create_mdm','create_glm'},...                                     % proc_steps_array
        'sdm_pattern',...                               % varargin
            '*MCparams.sdm',...
        'vtc_pattern',...  
            '*_tf.vtc',...    
        'model',...
            'mat2prt_reach_decision_vardelay_forglm');
        
    % glm cue centered AVG
    ne_pl_multisession_3TUMG_part2(...
        [runpath],...                                   % basedir
        {prot.name},...                                 % session_list
        '',...                                          % dataset_path
        ['Exp_combined_no_outliers_glm_cue'],...        % dataset_name
        '*combined_glm_cue.avg',...               % avg_name  '*no_outliers_glm_cue.avg',  '*combined_glm_cue.avg'
        'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
        {'create_avg'},...                                     % proc_steps_array
        'sdm_pattern',...                               % varargin
            '*MCparams.sdm',...
        'vtc_pattern',...  
            '*_tf.vtc',...      
        'model',...
            'mat2prt_reach_decision_vardelay_forglm');  
 %% buffer
 
 save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath','session_list')
 %memory
 %inmem
 
 clear all
 
 load('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat')
 %memory
 %inmem
 
 %% cue and mov centered AVGs per delay

 center = {'cue', 'mov'};
 delay = {'3','6','9','12','15'};
 

 for c = 1:length(center)
     
     for d = 1:length(delay)
         
         % AVG
         ne_pl_multisession_3TUMG_part2(...
             [runpath],...                                   % basedir
             {prot.name},...                                % session_list
             '',...                                          % dataset_path
             ['Exp_combined_avg_' center{c} '_' delay{d}],...        % dataset_name [prot(i).name '_combined_avg_' center{c} '_' delay{d}]
             ['*avg_' center{c} '_' delay{d} '.avg'],...               % avg_name  '*no_outliers_glm_cue.avg',  '*combined_glm_cue.avg'
             'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
             {'create_avg'},...                                     % proc_steps_array
             'sdm_pattern',...                               % varargin
                '*MCparams.sdm',...
             'model',...
                'mat2prt_reach_decision_vardelay_foravg');

                
    save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath','c','d','center','delay','session_list')
    %memory
    %inmem
    
    clear all
    
    load('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat')
    %memory
    %inmem
         
     end
 end
 
 
 %%
 %%
 %%
 %%
%% buffer
 
 save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath','session_list')
 %memory
 %inmem
 
 clear all
 
 load('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat')
 %memory
 %inmem
 
 %% INCLUDING OUTLIER PREDS
 
    % glm cue centered MDM and GLM
    ne_pl_multisession_3TUMG_part2(...
        [runpath],...                                   % basedir
        session_list,...                                 % session_list
        '',...                                          % dataset_path
        ['Exp_combined_no_outliers_glm_cue'],...        % dataset_name
        '*no_outliers_glm_cue.avg',...               % avg_name  '*no_outliers_glm_cue.avg',  '*combined_glm_cue.avg'
        'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
        {'create_mdm','create_glm'},...                                     % proc_steps_array
        'sdm_pattern',...                               % varargin
            '*outlier_preds.sdm',...
        'vtc_pattern',...  
            '*_tf.vtc',...
        'model',...
            'mat2prt_reach_decision_vardelay_forglm');
        
    % glm cue centered AVG
    ne_pl_multisession_3TUMG_part2(...
        [runpath],...                                   % basedir
        {prot.name},...                                 % session_list
        '',...                                          % dataset_path
        ['Exp_combined_no_outliers_glm_cue'],...        % dataset_name
        '*no_outliers_glm_cue.avg',...               % avg_name  '*no_outliers_glm_cue.avg',  '*combined_glm_cue.avg'
        'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
        {'create_avg'},...                                     % proc_steps_array
        'sdm_pattern',...                               % varargin
            '*outlier_preds.sdm',...
        'vtc_pattern',...  
            '*_tf.vtc',...    
        'model',...
            'mat2prt_reach_decision_vardelay_forglm');  
        
 %%  cue and mov centered AVGs per delay

 center = {'cue', 'mov'};
 delay = {'3','6','9','12','15'};
 

 for c = 1:length(center)
     
     for d = 1:length(delay)
         
         % AVG
         ne_pl_multisession_3TUMG_part2(...
             [runpath],...                                   % basedir
             {prot.name},...                                % session_list
             '',...                                          % dataset_path
             ['Exp_combined_avg_' center{c} '_' delay{d} '_no_outliers'],...        % dataset_name [prot(i).name '_combined_avg_' center{c} '_' delay{d}]
             ['*avg_' center{c} '_' delay{d} '_no_outliers.avg'],...               % avg_name  '*no_outliers_glm_cue.avg',  '*combined_glm_cue.avg'
             'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
             {'create_avg'},...                                     % proc_steps_array
             'sdm_pattern',...                               % varargin
                '*outlier_preds.sdm',...
             'model',...
                'mat2prt_reach_decision_vardelay_foravg');

                
    save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath','c','d','center','delay','session_list')
    %memory
    %inmem
    
    clear all
    
    load('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat')
    %memory
    %inmem
         
     end
 end