function frd_pipeline2_automized

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
    
    sessions = length(prot(i).session);
    
    for k = 1:sessions
        
%         ne_pl_process_one_session_3TUMG_part2(...
%             'Y:\MRI\Human\fMRI-reach-decision\Pilot\MAPA\20190802',...
%             'MAPA',...
%             'Human_reach_decision',...
%             {'all'},...
%             'prt2avg_script',...
%             'ne_prt2avg_reach_decision_pilot',... % ????????
%             'vmr_pattern',...
%             '.vmr',...
%             'sdm_pattern',...
%             '*_outlier_preds.sdm');
%         
        % for GLM
        ne_pl_process_one_session_3TUMG_part2(...
            [runpath filesep prot(i).name filesep prot(i).session(k).date],...
            [prot(i).name '_' prot(i).session(k).date],...
            'Human_reach_decision',...
            {'exclude_outliers_avg'},...
            'model',...
                'mat2prt_reach_decision_vardelay_forglm',...
            'prt2avg_script',...
                'ne_prt2avg_reach_decision_vardelay_forglm',...
            'vmr_pattern',...
                '.vmr',...
            'sdm_pattern',...
                '*_outlier_preds.sdm');
       
        % for AVG
        ne_pl_process_one_session_3TUMG_part2(...
            [runpath filesep prot(i).name filesep prot(i).session(k).date],...
            [prot(i).name '_' prot(i).session(k).date],...
            'Human_reach_decision',...
            {'create_avg'},...
            'model',...
                'mat2prt_reach_decision_vardelay_foravg',...
            'prt2avg_script',...
                'ne_prt2avg_reach_decision_vardelay_foravg',...
            'vmr_pattern',...
                '.vmr',...
            'sdm_pattern',...
                '*_outlier_preds.sdm');
        
        save('D:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath','i','k')
        %memory
        %inmem
        
        clear all
        
        load('D:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat')
        %memory
        %inmem
        
    end
end



