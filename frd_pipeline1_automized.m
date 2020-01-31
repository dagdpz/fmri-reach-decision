function frd_pipeline1_automized

load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\protocols_exp.mat');

runpath = 'Y:\MRI\Human\fMRI-reach-decision\Experiment';

%subjects = {'CLSC', 'DAGU', 'ELRH', 'EVBO', 'NORE', 'OLPE'};

for i = 1:length(prot)
    
    sessions = length(prot(i).session);
    
    for k = 1:sessions
        
%     ne_pl_process_one_session_3TUMG_part1(...
%         'Y:\MRI\Human\fMRI-reach-decision\Pilot\MAPA\20190802',...    
%         'hum_14406\dicom',...
%         [8 11 14 19 24], ...
%         6,...
%         'MAPA',...
%         'Human_reach_decision_pilot',...
%         {'all'});
        
    ne_pl_process_one_session_3TUMG_part1(...
        [runpath filesep prot(i).name{1} filesep prot(i).session(k).date{1}],... % session folder
        [prot(i).session(k).hum{1} filesep 'dicom'],...                                         % hum_nummer
        [prot(i).session(k).epi.nr1], ...                                  % first number of EPIs
        prot(i).session(k).T1.nr2,...                                      % secpnd number of T1
        prot(i).name{1},...                                                         % subject name
        'Human_reach_decision',...                                         % (see ne_pl_session_settings.m)
        {'all'});                                                          % sth

    end
end 


