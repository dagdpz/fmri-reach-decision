function frd_pipeline3_automized

clear all

load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\protocols_v2.mat');

throwaway = ~strcmp('CAST',{prot.name})& ...
      ~strcmp('EVBO',{prot.name}) &...    
      ~strcmp('JAGE',{prot.name}) &...    
      ~strcmp('LIKU',{prot.name}) &...    
      ~strcmp('LEKU',{prot.name}) &...  
      ~strcmp('LIKU',{prot.name}) &...
      ~strcmp('LORU',{prot.name}) &...
      ~strcmp('MABA',{prot.name}) &...
      ~strcmp('MABL',{prot.name}) &...
      ~strcmp('MARO',{prot.name}) &...
      ~strcmp('PASC',{prot.name});

%throwaway = ~strcmp('ELRH',{prot.name});

prot(~throwaway) = [];


runpath = 'D:\MRI\Human\fMRI-reach-decision\Experiment\TAL';

save('D:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath')  % has to be hard coded, see below as well


for i = 1:length(prot)
    
    %% glm cue centered
    ne_pl_multisession_3TUMG_part2(...
        [runpath filesep prot(i).name],...              % basedir
        {prot(i).session().date},...                    % session_list
        '',...                                          % dataset_path
        [prot(i).name '_combined_no_outliers_glm_cue'],...          % dataset_name '_combined_no_outliers_glm_cue'
        '*no_outliers.avg',...                           % avg_name '*no_outliers.avg' '*forglm_cue.avg'
        'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
        {'all'},...                                     % proc_steps_array
        'sdm_pattern',...                               % varargin
            '*outlier_preds.sdm',...                    % '*MCparams.sdm'
        'model',...
            'mat2prt_reach_decision_vardelay_forglm');
    
        
    
    %% take care of memory
    save('D:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath','i')
    %memory
    %inmem
    
    clear all
    
    load('D:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat')
    %memory
    %inmem
    
    
end
