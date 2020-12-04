%% [out,stat]=ne_plot_era_onefile_avg(fname,era_settings_id,avg_path,varargin)
% ne_plot_era_onefile_avg('CU_FEF_r.dat','Curius_microstim_20131129-now','20130814-20131009_eb.avg');



% 
% [out,stat]=ne_plot_era_onefile_avg('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\ANEL\mat2prt_reach_decision_vardelay_foravg\ANEL_test.mat',...
%     'Human_reach_decision',...
%     'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\ANEL\20200130\mat2prt_reach_decision_vardelay_foravg\ne_prt2avg_reach_decision_vardelay_foravg_cue_12_no_outliers.avg')
% 
% 
% [out,stat]=ne_plot_era_onefile_avg(...
%     'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\ANEL\mat2prt_reach_decision_vardelay_foravg\ANEL_delay12_6a_left.dat',...
%     'Human_reach_decision',...
%     'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\ANEL\mat2prt_reach_decision_vardelay_foravg\ANEL_combined_avg_cue_12_no_outliers.avg')


%% MDM


[era] = ne_era_mdm('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\mat2prt_reach_decision_vardelay_forglm\test\test_r_tal.voi',...
    'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\ANEL\mat2prt_reach_decision_vardelay_foravg\ANEL_combined_avg_cue_12_no_outliers.avg',...
    'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\ANEL\mat2prt_reach_decision_vardelay_forglm\ANEL_combined_no_outliers_glm_cue.mdm',...
    'Human_reach_decision',...
    'tc_interpolate',100);


save('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\ANEL\mat2prt_reach_decision_vardelay_foravg\ANEL_test_delay12.mat','era')
%% plot

% [era, anova, settings, compare] = ne_plot_era_action_selection_humans_ADAPTED(...
%     'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\mat2prt_reach_decision_vardelay_forglm\test\test_r_tal.voi',...
%     'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\ANEL\mat2prt_reach_decision_vardelay_foravg\ANEL_combined_avg_cue_12_no_outliers.avg', ...
%     'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\ANEL\mat2prt_reach_decision_vardelay_forglm\ANEL_combined_no_outliers_glm_cue.mdm',...
%     'Human_reach_decision',...
%     {'.png'},... %save figure
%     'load_mat','Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\ANEL\mat2prt_reach_decision_vardelay_foravg\ANEL_test_delay12.mat')

%% 
test_ges = table();
for i = 1:8
    test = table();
    test.data = squeeze(era.mean(1,i,:));
    test.ind = repmat(i,151,1);
    test.time = era.timeaxis';
    test_ges = [test_ges; test];
    
end

graph = gramm('x',test_ges.time,'y',test_ges.data,'color',test_ges.ind);
graph.geom_point();
graph.draw;














