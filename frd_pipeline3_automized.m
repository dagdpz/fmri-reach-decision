function frd_pipeline3_automized

clear all
%%
% load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\protocols_v2.mat');
% 
% throwaway = ~strcmp('CAST',{prot.name})& ...
%       ~strcmp('EVBO',{prot.name}) &...    
%       ~strcmp('JAGE',{prot.name}) &...    
%       ~strcmp('LIKU',{prot.name}) &...    
%       ~strcmp('LEKU',{prot.name}) &...  
%       ~strcmp('LIKU',{prot.name}) &...
%       ~strcmp('MABA',{prot.name}) &...
%       ~strcmp('MABL',{prot.name}) &...
%       ~strcmp('MARO',{prot.name}) &...
%       ~strcmp('PASC',{prot.name});
% 
% % throwaway = strcmp('LORU',{prot.name});
% 
% prot(~throwaway) = [];
% 
% runpath = 'D:\MRI\Human\fMRI-reach-decision\Experiment\TAL';
% 
% save('D:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath')  % has to be hard coded, see below as well
%%
load('D:\MRI\Human\fMRI-reach-decision\test_subject\JOOD_protocol.mat');
throwaway = strcmp('JOOD',{prot.name});

prot(~throwaway) = [];

runpath = 'D:\MRI\Human\fMRI-reach-decision\test_subject';
save('D:\MRI\Human\fMRI-reach-decision\test_subject\buffer_for_pipeline.mat','prot', 'runpath')  % has to be hard coded, see below as well





%% glm cue centered
for i = 1:length(prot)
    
    
    ne_pl_multisession_3TUMG_part2(...
        [runpath filesep prot(i).name],...              % basedir
        {prot(i).session().date},...                    % session_list
        '',...                                          % dataset_path
        [prot(i).name '_combined_JOOD_test_glm_cue'],...   % dataset_name (How to call the file) '_combined_no_outliers_glm_cue'
        '*no_outliers.avg',...                           % avg_name '*no_outliers.avg' '*forglm_cue.avg'
        'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
        {'all'},...                                     % proc_steps_array
        'sdm_pattern',...                               % varargin
            '*MCparams.sdm',...                         % '*MCparams.sdm'  '*outlier_preds.sdm'
        'vtc_pattern',...  
            '*preproc.vtc',...
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

%% avg's
% center = {'cue', 'mov'};
% delay = {'3', '6', '9', '12', '15'};
% 
% for i = 1:length(prot)
%     
%     for c = 1:length(center)
%         
%         for d = 1:length(delay)
% 
%     ne_pl_multisession_3TUMG_part2(...
%         [runpath filesep prot(i).name],...              % basedir
%         {prot(i).session().date},...                    % session_list
%         '',...                                          % dataset_path
%         [prot(i).name '_combined_avg_' center{c} '_' delay{d}'],...           % dataset_name '_combined_no_outliers_glm_cue'     (How the file will be called) 
%         ['*foravg_' center{c} '_' delay{d} '.avg'],...  % avg_name    '*no_outliers.avg' '*forglm_cue.avg' (Which avg from each session is being looked for) 
%         'Human_reach_decision',...                      % session_settings_id, (see ne_pl_session_settings.m)
%         {'create_avg'},...                              % proc_steps_array
%         'sdm_pattern',...                               % varargin
%             '*MCparams.sdm',...                         % '*MCparams.sdm' '*outlier_preds.sdm'
%         'model',...
%             'mat2prt_reach_decision_vardelay_foravg');
%     
% 
%     %% take care of memory
%     save('D:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath','i','c','d')
%     %memory
%     %inmem
%     
%     clear all
%     
%     load('D:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat')
%     %memory
%     %inmem
%         end
%     end
%     
% end


