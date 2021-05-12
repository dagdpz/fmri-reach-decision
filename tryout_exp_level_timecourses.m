% tryout_exp_level_timecourses

era_files =...
{'Y:\MRI\Human\fMRI-reach-decision\Experiment\testground\test averaging era subjects\ANEL\mat2prt_reach_decision_vardelay_foravg\ANEL_era_cue_12_lh_no_outliers.mat',...
 'Y:\MRI\Human\fMRI-reach-decision\Experiment\testground\test averaging era subjects\ANRE\mat2prt_reach_decision_vardelay_foravg\ANRE_era_cue_12_lh_no_outliers.mat'};


%%
   pdfs = findfiles('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\plots','*per_delay_subplots.pdf');
    append_pdfs('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\Exp_per_delay_subplots_combined.pdf',pdfs);
    
    %%
    
       pdfs = findfiles('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\plots','*averaged_subplots.pdf');
    append_pdfs('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\Exp_averaged_subplots_combined.pdf',pdfs);