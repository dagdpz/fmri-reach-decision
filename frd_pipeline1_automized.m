function frd_pipeline1_automized
% wrapper function for preprocessing using NeuroElf.

% This function is specific to the fmri_reach_decision project.

%%
clear all

load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\protocols_v2.mat');

runpath = 'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI';
runpath_behavioral = 'Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data';

for_GLM = 1;
for_AVG = 1;

%%
save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline','prot', 'runpath','runpath_behavioral','for_GLM','for_AVG') % has to be hard coded, see below as well

for i = 1:length(prot)
    
    sessions = length(prot(i).session);
    
    for k = 1:sessions
        
        for m = 1 : length(prot(i).session(k).epi)
            
            %% copy behavioral files to MRI folder if not there already
            runpath_beh = [runpath_behavioral filesep ... % Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\CLSC\20200114\CLSC_2020-01-14_07.mat
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
        
        %% calculate
        % example input
        %     ne_pl_process_one_session_3TUMG_part1(...
        %         'Y:\MRI\Human\fMRI-reach-decision\Pilot\MAPA\20190802',...
        %         'hum_14406\dicom',...
        %         [8 11 14 19 24], ...
        %         6,...
        %         'MAPA',...
        %         'Human_reach_decision_pilot',...
        %         {'all'},...
        %         'beh2prt_function_handle',@mat2prt_reach_decision_vardelay_forglm);% respective function handle
        
        % for GLM
        if for_GLM
            ne_pl_process_one_session_3TUMG_part1(...
                [runpath filesep prot(i).name filesep prot(i).session(k).date],... % session folder
                [prot(i).session(k).hum filesep 'dicom'],...                       % hum_nummer
                [prot(i).session(k).epi.nr1], ...                                  % first number of EPIs
                prot(i).session(k).T1.nr2,...                                      % secpnd number of T1
                prot(i).name,...                                                   % subject name
                'Human_reach_decision',...                                         % (see ne_pl_session_settings.m)
                {'all'},...
                'beh2prt_function_handle',@mat2prt_reach_decision_vardelay_forglm);% @mat2prt_reach_decision_vardelay_forglm
        end
        
        % for AVG
        if for_AVG
            ne_pl_process_one_session_3TUMG_part1(...
                [runpath filesep prot(i).name filesep prot(i).session(k).date],... % session folder
                [prot(i).session(k).hum filesep 'dicom'],...                       % hum_nummer
                [prot(i).session(k).epi.nr1], ...                                  % first number of EPIs
                prot(i).session(k).T1.nr2,...                                      % secpnd number of T1
                prot(i).name,...                                                   % subject name
                'Human_reach_decision',...                                         % (see ne_pl_session_settings.m)
                {'create_prt'},...                                                 % sth
                'beh2prt_function_handle',@mat2prt_reach_decision_vardelay_foravg);% @mat2prt_reach_decision_vardelay_foravg
        end
        
        save('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline','prot', 'runpath','i','k','m','runpath_behavioral','for_GLM','for_AVG')
        %memory
        %inmem
        
        clear all
        
        load('Y:\MRI\Human\fMRI-reach-decision\Experiment\buffer_for_pipeline')
        %memory
        %inmem
        
    end
end

