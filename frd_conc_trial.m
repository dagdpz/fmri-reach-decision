function [trial, analysis_level] = frd_conc_trial(runpath)

%% Which analysis level are we doing? run, session, subject or whole epxeriment?

endout=regexp(runpath,filesep,'split');

% run
if length(endout{end}) == 22 % Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\CLSC\20200114\CLSC_2020-01-14_07.mat
    analysis_level = 'run';
    su.name = endout{end-2};
    se.name = endout{end-1};
    fi.name = endout{end};
    
% session
elseif length(endout{end}) == 8 || length(endout{end}) == 10 %Y:\Personal\Peter\Data\pilot\PENE\20190606
    analysis_level = 'session'; 
    su.name = endout{end-1};
    se.name = endout{end};

% subject
elseif length(endout{end}) == 4 % Y:\Personal\Peter\Data\pilot\PENE
    analysis_level = 'subject';
    su.name = endout{end};

% whole experiment
elseif strcmp('behavioral_data', endout{end}) % Y:\MRI\Human\fMRI-reach-decision\Pilot\behavioral_data
    analysis_level = 'experiment';
end

    
%% here it runs through all subfolders and concatenates matfiles


if strcmp('experiment',analysis_level)
    su = dir(runpath);
    su = su(~ismember({su.name},{'.' '..'}));
end

for u = 1:length(su) % loop over subjects
    
    if strcmp('experiment',analysis_level) %analysis_level == 'experiment'
        runpath_su = [runpath filesep su(u).name];
    else
        runpath_su = runpath;
    end
    
    if strcmp('experiment',analysis_level) || strcmp('subject',analysis_level)
        se = dir(runpath_su);
        se = se(~ismember({se.name},{'.' '..' 'last_eyecal.mat' 'shuffled_conditions' }));
    end
    
    for s = 1:length(se) % loop over sessions
        
        if strcmp('experiment',analysis_level) || strcmp('subject',analysis_level)
            runpath_se = [runpath_su filesep se(s).name];
        else
            runpath_se=runpath_su;
        end
        
        %How many files are there?
        if strcmp('experiment',analysis_level) || strcmp('subject',analysis_level) || strcmp('session',analysis_level)
            fi  = dir([runpath_se filesep '*.mat']);
            fi = fi(~ismember({fi.name},{'.' '..'}));
        end
        
        for i = 1:length(fi) % loop over files
            
            %here it loads each file into the temp variable, adds the
            %respective RUN number, SESSION number, SUBJECT name (also path and
            %file name) and attaches it to tempges
            
            if strcmp('experiment',analysis_level) || strcmp('subject',analysis_level) || strcmp('session',analysis_level)
                runpath_fi = [runpath_se filesep fi(i).name];
            else
                runpath_fi = runpath_se;
            end
            
            temp = load(runpath_fi);     % load first file
            
            [temp.trial(:).run] = deal(i);                    % add RUN number
            [temp.trial(:).session] = deal(s);                % add SESSION number
            [temp.trial(:).subj] = deal(fi(i).name(1:4));     % add SUBJECT name
            [temp.trial(:).file_name] = deal(fi(i).name);     % add file name
            [temp.trial(:).path] = deal(runpath_fi);          % add path name
            
            
            if ~isfield(temp.trial,'CueAuditiv')
                [temp.trial.CueAuditiv] = deal(0);
                temp.trial = rmfield(temp.trial,'condition');
            end
            
            
            if i == 1 && s == 1 && u == 1
                trial = temp.trial;
            else
                trial = [trial temp.trial];
            end
            
        end % loop over files
    end %loop sessions
end % loop subjects

    



