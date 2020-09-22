%% Set up the initialization function, e.g., initialize_vars.m
%  This function should specify the directories that contain all necessary data files.
%  It should specify naming conventions for functional and anatomical subfolders.
%  It should also specify exceptions to the naming conventions in a subfunction called run_exceptions.
%  Note that once you've set up this script once, you should be able to use it for any new batch scripts. 
% This way, if you need to make any changes to the paths, etc, you can do it just once.




function [b] = initialize_vars(path, subjects,i)

% SPM info
b.spmDir = fileparts(which('spm'));         % path to SPM installation (automatic)
% Directory information
dataDir = path ; %'Y:\MRI\Human\fMRI-reach-decision\Experiment\testground';
b.curSubj = subjects{i};
b.dataDir = strcat(dataDir,filesep, b.curSubj,filesep);  % make data directory subject-specific
b.funcRuns = {'run01' 'run02' 'run03' };       % folders containing functional images
b.anatT1 = 'anat';                        % folder containing T1 structural
b.AllRuns = 12; % number of all runs for one subejct
end


