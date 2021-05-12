function [p,z,SE] = pvalue_from_ci(estimate,lwr,upr)
% lwr and upr ci defined as -2.5 and 97.5 
% https://www.bmj.com/content/343/bmj.d2304

% steps
% 1) calculate the standard error: SE = (u ? l)/(2×1.96)
% 2) calculate the test statistic: z = Est/SE
% 3) calculate the P value2: P = exp(?0.717×z ? 0.416×z^2).
%%

SE = (upr - lwr) / (2*1.96);
z = estimate./SE;
p = exp(-0.717*z - 0.416*z.^2);








%% load subject data 
% load('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\stats\Exp_era_period_diff_choi_instr.mat');
% dd = tt_no_del;
% clear tt_no_del
% %clear tt
% 
% %%
% svoi = table(dd.voi_number,dd.location,dd.voi,dd.voi_short,dd.voi_short_hemi,dd.hemi);
% svoi.Properties.VariableNames = ({'voi_number','location','voi','voi_short','voi_short_hemi','hemi'});
% svoi = unique(svoi);
% 
% sts_ges = table();
% 
% uni_voi_number = unique(dd.voi_number);
% uni_eff = unique(dd.cond);
% uni_period = unique(dd.period);
% 
% for v = 1:length(uni_voi_number)
%     
%     for e = 1:length(uni_eff)
%         
%        for p = 1:length(uni_period)
%            
%            idx = dd.voi_number == uni_voi_number(v) & dd.cond == uni_eff(e) & dd.period == uni_period(p);
%            
%            [h,pv,~,stats] = ttest(dd.diff(idx));
%            
%            sts = table();
%            sts.voi_number = uni_voi_number(v);
%            sts.eff        = uni_eff(e);
%            sts.period     = uni_period(p);
%            sts.h        = h;
%            sts.p_value    = pv;           
%            sts.tstat     = stats.tstat;
%            sts.df    = stats.df;
%            
%             sts_ges = [sts_ges; sts];
%        end
%     end
% end
% 
% clear sts
% %% %%%%%%%%
% tt_ges_1215 = tt(tt.delay == '9',:);
% 
% tt_mean_1215 = rowfun(@mean,tt_ges_1215,'InputVariables',{'diff'},'GroupingVariable', {'subj','voi_number','cond','period'},'OutputVariableNames','diff');
% 
% 
% dd = tt_mean_1215;
% 
% %% %%%%%%%%%%%




