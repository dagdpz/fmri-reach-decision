function frd_move_detailed_voi_plots

if 0
    load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\protocols_v2.mat');
    
    runpath = 'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI';
    
    
    for i = 1:length(prot)
        
        sub = prot(i).name;
        
        ff = findfiles([runpath filesep  sub filesep 'mat2prt_reach_decision_vardelay_foravg'],'*_era_*.mat');
        
        new_folder = [runpath filesep sub filesep 'mat2prt_reach_decision_vardelay_foravg' filesep 'era_detailed'];
        if ~exist(new_folder)
            mkdir(new_folder);
        end
        
        for s = 1:length(ff)
            movefile(ff{s},new_folder)
        end
        
        %%
        pl = findfiles([runpath filesep  sub filesep 'plots'],'*.pdf');
        
        
        new_folder2 = [runpath filesep sub filesep 'plots' filesep 'plots_detailed'];
        if ~exist(new_folder2)
            mkdir(new_folder2);
        end
        
        for k = 1:length(pl)
            movefile(pl{k},new_folder2)
        end
        
    end
    
end

tic
ne_era_frd_wrapper_subject_level_creation_and_plot
toc
ne_era_frd_wrapper_group_level_creation_and_plot
toc


