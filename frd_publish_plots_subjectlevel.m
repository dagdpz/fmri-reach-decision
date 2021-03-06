function frd_publish_plots_subjectlevel
%% function to publish subject level plots

current_file_type = 'html';  %'html' (default) | 'doc' | 'latex' | 'ppt' | 'xml' | 'pdf'
runpath = 'Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data';



load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\current_dat_file.mat','dat');

sus = unique(dat.subj_id);

sus = sus (3);

for i = 1:length(sus) 
    
    current_subject_id = char(sus(i));
    current_subject    = char(unique(dat.subj(dat.subj_id == current_subject_id)));
    current_folder     = [runpath filesep current_subject filesep 'stats'];

    if ~exist (current_folder)
        mkdir(current_folder)
    end
    
    options                 = struct();
    options.format          = current_file_type;
    options.outputDir       = current_folder;
    options.codeToEvaluate  = ['subj_id =' current_subject_id '; frd_plots_subjectlevel(subj_id)'];
    %options.figureSnapMethod = 'entireFigureWindow';
    options.showCode        = false;

    
    publish('frd_plots_subjectlevel',options);
    
    close all
end


