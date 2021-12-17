%% t-test early vs. late period

load('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\stats\Exp_era_period_diff_choi_instr.mat');

tt_no_del = rowfun(@nanmean,tt,'InputVariables',{'diff'},'GroupingVariable', {'subj','voi','cond','period'},'OutputVariableNames','diff');


%%
uni_voi = unique(tt_no_del.voi);
uni_eff = unique(tt_no_del.cond);

p_table = table();
for v = 1:length(uni_voi) 
    
   for  e = 1:length(uni_eff)
    
       sel = tt_no_del.voi == uni_voi(v) & tt_no_del.cond ==  uni_eff(e); 
       x = tt_no_del.diff(tt_no_del.period == 'early' & sel);
       y = tt_no_del.diff(tt_no_del.period == 'late' & sel);
      
       [h,p] = ttest(x,y);
       
       temp = table();
       temp.voi = uni_voi(v);
       temp.eff = uni_eff(e);
       temp.h = h;
       temp.p = p;

       p_table = [p_table; temp];
    
   end
end

figure;
plot(p_table.voi(p_table.eff == 'reach'),p_table.p(p_table.eff == 'reach'),'*',...
    p_table.voi(p_table.eff == 'sac'),p_table.p(p_table.eff == 'sac'),'*')
title('P VALUES of early vs. late period (averaged left/right, averaged 9/12/15)');
line([0 25],[0.05 0.05],'Color',[0 0 0],'LineStyle',':');
legend('reach','sac');

