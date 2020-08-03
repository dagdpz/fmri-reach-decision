function testi
%% function to publish subject level plots

current_file_type = 'html';  %'html' (default) | 'doc' | 'latex' | 'ppt' | 'xml' | 'pdf'
runpath = 'Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data';



load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\current_dat_file.mat','dat');

sus = unique(dat.subj);

sus = sus (1:2);

for i = 1:length(sus) 
    
    current_folder = [runpath filesep char(sus(i)) filesep 'stats'];

    if ~exist (current_folder)
        mkdir(current_folder)
    end
    
    options                 = struct();
    options.format          = current_file_type;
    options.outputDir       = current_folder;
    options.codeToEvaluate  = 'frd_plots_subjectlevel(current_subject)';
    %options.figureSnapMethod = 'entireFigureWindow';
    options.showCode        = false;

    
    publish('frd_plots_subjectlevel',options);
end


