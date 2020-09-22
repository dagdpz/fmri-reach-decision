function frd_pipeline1_automized
% those done already: CLSC,DAGU, ELRH, OLPE, (EVBO)

clear all

%%
% load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\protocols_v2.mat');
% % throwaway = strcmp('OLPE',{prot.name}) | ...
% %     strcmp('ELRH',{prot.name}) |...
% %     strcmp('CLSC',{prot.name}) |...
% %     strcmp('DAGU',{prot.name}) |...
% %     strcmp('CLSC',{prot.name}) |...
% %     strcmp('EVBO',{prot.name}) |...
% %     strcmp('NORE',{prot.name}) |...
% %     strcmp('LORU',{prot.name}) |...
% %     strcmp('ANEL',{prot.name}) ;
% 
% % uncomment for completed subjects
% % throwaway = ~strcmp('CAST',{prot.name})& ...
% %       ~strcmp('EVBO',{prot.name}) &...    
% %       ~strcmp('JAGE',{prot.name}) &...    
% %       ~strcmp('LIKU',{prot.name}) &...    
% %       ~strcmp('LEKU',{prot.name}) &...  
% %       ~strcmp('LIKU',{prot.name}) &...
% %       ~strcmp('LORU',{prot.name}) &...
% %       ~strcmp('MABA',{prot.name}) &...
% %       ~strcmp('MABL',{prot.name}) &...
% %       ~strcmp('MARO',{prot.name}) &...
% %       ~strcmp('PASC',{prot.name});
% 
% throwaway = strcmp('JOOD',{prot.name});
% 
% prot(~throwaway) = [];
% 
% runpath = 'D:\MRI\Human\fMRI-reach-decision\Experiment\TAL';
%%
load('D:\MRI\Human\fMRI-reach-decision\test_subject\JOOD_protocol.mat');
throwaway = strcmp('JOOD',{prot.name});

prot(~throwaway) = [];

runpath = 'D:\MRI\Human\fMRI-reach-decision\test_subject';


%%
save('D:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath') % has to be hard coded, so below as well

for i = 1:length(prot)
    
    sessions = length(prot(i).session);
    
    for k = 1:sessions
                
        for m = 1 : length(prot(i).session(k).epi) 
            
            runpath_beh = [runpath filesep ... % Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\CLSC\20200114\CLSC_2020-01-14_07.mat
                'behavioral_data' filesep ...
                prot(i).name filesep ...
                prot(i).session(k).date filesep ...
                prot(i).session(k).epi(m).mat_file ];
            
            runpath_mri = [runpath filesep ... % Y:\MRI\Human\fMRI-reach-decision\Experiment\CLSC\20200114
                prot(i).name filesep ...
                prot(i).session(k).date];
            
            if ~(exist([runpath_mri filesep prot(i).session(k).epi(m).mat_file],'file') == 2) % if it is not there already
                copyfile(runpath_beh,[runpath_mri filesep])
            end
            
        end
        
%     ne_pl_process_one_session_3TUMG_part1(...
%         'Y:\MRI\Human\fMRI-reach-decision\Pilot\MAPA\20190802',...    
%         'hum_14406\dicom',...
%         [8 11 14 19 24], ...
%         6,...
%         'MAPA',...
%         'Human_reach_decision_pilot',...
%         {'all'});
     
    % for GLM
    ne_pl_process_one_session_3TUMG_part1(...
        [runpath filesep prot(i).name filesep prot(i).session(k).date],... % session folder
        [prot(i).session(k).hum filesep 'dicom'],...                       % hum_nummer
        [prot(i).session(k).epi.nr1], ...                                  % first number of EPIs
        prot(i).session(k).T1.nr2,...                                      % secpnd number of T1
        prot(i).name,...                                                   % subject name
        'Human_reach_decision',...                                         % (see ne_pl_session_settings.m)
        {'all'},...
        'beh2prt_function_handle',@mat2prt_reach_decision_vardelay_forglm);% respective function handle                                                         
    
    % for AVG
       ne_pl_process_one_session_3TUMG_part1(...
        [runpath filesep prot(i).name filesep prot(i).session(k).date],... % session folder
        [prot(i).session(k).hum filesep 'dicom'],...                       % hum_nummer
        [prot(i).session(k).epi.nr1], ...                                  % first number of EPIs
        prot(i).session(k).T1.nr2,...                                      % secpnd number of T1
        prot(i).name,...                                                   % subject name
        'Human_reach_decision',...                                         % (see ne_pl_session_settings.m)
        {'create_prt'},...                                                 % sth 
        'beh2prt_function_handle',@mat2prt_reach_decision_vardelay_foravg);%
    

    save('D:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat','prot', 'runpath','i','k','m')
    %memory
    %inmem
    
    clear all
    
    load('D:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline.mat')
    %memory
    %inmem
    
    end
end 
%%
% 
%     ne_pl_process_one_session_3TUMG_part1(...
%         [runpath filesep prot(i).name{1} filesep prot(i).session(k).date{1}],... % session folder
%         [prot(i).session(k).hum{1} filesep 'dicom'],...                                         % hum_nummer
%         [prot(i).session(k).epi.nr1], ...                                  % first number of EPIs
%         prot(i).session(k).T1.nr2,...                                      % secpnd number of T1
%         prot(i).name{1},...                                                         % subject name
%         'Human_reach_decision',...                                         % (see ne_pl_session_settings.m)
%         {'all'});       
% 
% ne_pl_process_one_session_3TUMG_part1('Y:\MRI\Human\fMRI-reach-decision\Experiment\CLSC\20200114','hum_14741\dicom', [ 6     9    12    17    20], 15,'CLSC','Human_reach_decision',{'all'});  

