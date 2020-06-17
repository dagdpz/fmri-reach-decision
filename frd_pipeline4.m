function frd_pipeline4

clear all

load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\protocols_v2.mat');

throwaway = ~strcmp('CAST',{prot.name})& ...
      ~strcmp('EVBO',{prot.name}) &...    
      ~strcmp('JAGE',{prot.name}) &...    
      ~strcmp('LIKU',{prot.name}) &...    
      ~strcmp('LEKU',{prot.name}) &...  
      ~strcmp('LIKU',{prot.name}) &...
      ~strcmp('MABA',{prot.name}) &...
      ~strcmp('MABL',{prot.name}) &...
      ~strcmp('MARO',{prot.name}) &...
      ~strcmp('PASC',{prot.name});



prot(~throwaway) = [];

session_list = {};
for s = 1:length(prot)
    for d = 1:length(prot(s).session)
    sesh = {[prot(s).name filesep prot(s).session(d).date]};
   session_list = [session_list sesh];
   
    end
end

runpath = 'D:\MRI\Human\fMRI-reach-decision\Experiment\TAL';


    % glm cue centered MDM and GLM
    ne_pl_multisession_3TUMG_part2(...
        [runpath],...                                   % basedir
        session_list,...                                 % session_list
        '',...                                          % dataset_path
        ['Exp_combined_no_outliers_glm_cue'],...        % dataset_name
        '*no_outliers_glm_cue.avg',...               % avg_name  '*no_outliers_glm_cue.avg',  '*combined_glm_cue.avg'
        'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
        {'create_mdm'},...                                     % proc_steps_array
        'sdm_pattern',...                               % varargin
            '*outlier_preds.sdm',...
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
        'model',...
            'mat2prt_reach_decision_vardelay_forglm');        
        
        