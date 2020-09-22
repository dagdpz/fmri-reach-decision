%% Plot behavioral analysis across subjects
% Here are only completed data sets (N = 11)
clear all
load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\current_dat_file.mat','dat');


% excluding criteria
dat.unrealRT = dat.RT == -99 | dat.RT > 0.8 | (dat.RT < 0.2 & dat.effector == 'saccade');
weirdos = dat(dat.unrealRT,:);

dat = dat(dat.success,:);
dat = dat(~dat.unrealRT,:);
dat.target_selected = removecats(dat.target_selected);

% choice
%gCompRT.set_color_options('map',[0.9765, 0.4510, 0.0157; 0.0863, 0.6000, 0.7804],'n_color',2,'n_lightness',1);

% effector
%gCBtime.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
%gAmount.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.3804    0.8902    0.5412; 0.8431, 0.0980, 0.1098;0.9373    0.4745    0.4784],'n_color',2,'n_lightness',2);


% trial_type

dat.trial_type = categorical(strcat(cellstr(dat.effector),'_' ,cellstr(dat.choice),'_',cellstr(dat.target_selected)));
dat.trial_type_del = categorical(strcat(cellstr(dat.effector),'_' ,cellstr(dat.choice),'_',cellstr(dat.target_selected),'_',cellstr(dat.delay))); 

%save('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\current_dat_file.mat','dat','weirdos');

%% Sanity Check: state RT vs. trajectory RT
% problematic RTs are excluded (N = 142, remaining: N = 4014)
% * no RT detected
% * stateRT - RT > 0.1
% * stateRT < RT 
% * RT > 0.8


figure ('Position', [100 100 800 500],'Name','comparison of both RT measures');
gCompRT = gramm('x',dat.stateRT,'y',dat.RT,'column',dat.effector,'color',dat.effector , 'subset',dat.success & dat.RT > -98);
gCompRT.geom_point();
gCompRT.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
gCompRT.set_text_options('base_size',12);
gCompRT.set_names('x','state RT','y','trajectory RT','color','','column','');
gCompRT.set_title('comparison of both RT measures');
gCompRT.draw();


%% Amount of Trials overall
% on average we expect 40% for instructed and 60% for choice trials

figure ('Position', [100 100 800 500],'Name','How many trials p. condition?');
gAmount = gramm('y',dat.success,'x',dat.choice,'color',dat.effector,'lightness',dat.target_selected,'subset',dat.target_selected ~= 'none' & dat.success);
gAmount.stat_bin('normalization','probability');
gAmount.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.3804    0.8902    0.5412; 0.8431, 0.0980, 0.1098;0.9373    0.4745    0.4784],'n_color',2,'n_lightness',2);
gAmount.set_names('x','target selected','color','','lightness','');
gAmount.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5]);
gAmount.set_title('How many correct trials p. condition?');
gAmount.set_text_options('base_size',12);
gAmount.draw; 


figure ('Position', [100 100 1600 1000],'Name','How many trials p. condition p. subject?');
gAmount2 = gramm('y',dat.success,'x',dat.choice,'color',dat.effector,'lightness',dat.target_selected,'subset',dat.target_selected ~= 'none' & dat.success);
gAmount2.stat_bin();
gAmount2.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.3804    0.8902    0.5412; 0.8431, 0.0980, 0.1098;0.9373    0.4745    0.4784],'n_color',2,'n_lightness',2);
gAmount2.set_names('x','target selected','color','','column','','lightness','');
gAmount2.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5]);
gAmount2.set_title('How many correct trials p. condition p. subject?');
gAmount2.set_text_options('base_size',12);
gAmount2.facet_wrap(dat.subj,'ncols',5);
gAmount2.draw; 

%% Amount of Trials: delay 3

avgAmount = rowfun(@sum,dat,'InputVariables',{'success'},'GroupingVariable', {'subj','trial_type','delay'},'OutputVariableNames','avgAmount');

clear gAmount_del3
figure ('Position', [100 100 1600 1000],'Name','Amount of trials for delay 3');
gAmount_del3 = gramm('y',avgAmount.avgAmount,'x',avgAmount.subj,'color',avgAmount.subj,'subset',avgAmount.delay =='3');
gAmount_del3.geom_bar();

%gAmount_del3.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.3804    0.8902    0.5412; 0.8431, 0.0980, 0.1098;0.9373    0.4745    0.4784],'n_color',2,'n_lightness',2);
gAmount_del3.set_names('x','','color','','column','');
gAmount_del3.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5],'XTickLabel',[]);
gAmount_del3.set_title('Amount of trials for delay 3');
%gAmount_del3.set_text_options('base_size',12);
%gAmount_del3.set_order_options('x',{'3' '6' '9' '12' '15'});
gAmount_del3.facet_wrap(avgAmount.trial_type,'ncols',4);
gAmount_del3.draw; 

%% Amount of Trials: delay 6

clear gAmount_del6
figure ('Position', [100 100 1600 1000],'Name','Amount of trials for delay 6');
gAmount_del6 = gramm('y',avgAmount.avgAmount,'x',avgAmount.subj,'color',avgAmount.subj,'subset',avgAmount.delay =='6');
gAmount_del6.geom_bar();

%gAmount_del6.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.3804    0.8902    0.5412; 0.8431, 0.0980, 0.1098;0.9373    0.4745    0.4784],'n_color',2,'n_lightness',2);
gAmount_del6.set_names('x','','color','','column','');
gAmount_del6.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5],'XTickLabel',[]);
gAmount_del6.set_title('Amount of trials for delay 6');
%gAmount_del6.set_text_options('base_size',12);
%gAmount_del6.set_order_options('x',{'3' '6' '9' '12' '15'});
gAmount_del6.facet_wrap(avgAmount.trial_type,'ncols',4);

gAmount_del6.draw; 

%% Amount of Trials: delay 9

clear gAmount_del9
figure ('Position', [100 100 1600 1000],'Name','Amount of trials for delay 9');
gAmount_del9 = gramm('y',avgAmount.avgAmount,'x',avgAmount.subj,'color',avgAmount.subj,'subset',avgAmount.delay =='9');
gAmount_del9.geom_bar();

%gAmount_del9.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.3804    0.8902    0.5412; 0.8431, 0.0980, 0.1098;0.9373    0.4745    0.4784],'n_color',2,'n_lightness',2);
gAmount_del9.set_names('x','','color','','column','');
gAmount_del9.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5],'XTickLabel',[]);
gAmount_del9.set_title('Amount of trials for delay 9');
%gAmount_del9.set_text_options('base_size',12);
%gAmount_del9.set_order_options('x',{'3' '6' '9' '12' '15'});
gAmount_del9.facet_wrap(avgAmount.trial_type,'ncols',4);

gAmount_del9.draw; 

%% Amount of Trials: delay 12

clear gAmount_del12
figure ('Position', [100 100 1600 1000],'Name','Amount of trials for delay 15');
gAmount_del12 = gramm('y',avgAmount.avgAmount,'x',avgAmount.subj,'color',avgAmount.subj,'subset',avgAmount.delay =='15');
gAmount_del12.geom_bar();

%gAmount_del12.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.3804    0.8902    0.5412; 0.8431, 0.0980, 0.1098;0.9373    0.4745    0.4784],'n_color',2,'n_lightness',2);
gAmount_del12.set_names('x','','color','','column','');
gAmount_del12.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5],'XTickLabel',[]);
gAmount_del12.set_title('Amount of trials for delay 15');
%gAmount_del12.set_text_options('base_size',12);
%gAmount_del12.set_order_options('x',{'3' '6' '9' '12' '15'});
gAmount_del12.facet_wrap(avgAmount.trial_type,'ncols',4);

gAmount_del12.draw; 

%% Amount of Trials: delay 15

clear gAmount_del125
figure ('Position', [100 100 1600 1000],'Name','Amount of trials for delay 12');
gAmount_del125 = gramm('y',avgAmount.avgAmount,'x',avgAmount.subj,'color',avgAmount.subj,'subset',avgAmount.delay =='12');
gAmount_del125.geom_bar();
%gAmount_del125.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.3804    0.8902    0.5412; 0.8431, 0.0980, 0.1098;0.9373    0.4745    0.4784],'n_color',2,'n_lightness',2);
gAmount_del125.set_names('x','','color','','column','');
gAmount_del125.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5],'XTickLabel',[]);
gAmount_del125.set_title('Amount of trials for delay 12');
%gAmount_del125.set_text_options('base_size',12);
%gAmount_del125.set_order_options('x',{'3' '6' '9' '12' '15'});
gAmount_del125.facet_wrap(avgAmount.trial_type,'ncols',4);

gAmount_del125.draw; 

%% Amount of Trials overall

figure ('Position', [100 100 1300 600],'Name','Amount of trials overall');
gAmount_overall = gramm('y',dat.success,'x',dat.subj);
gAmount_overall.stat_bin();
%gAmount_overall.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.3804    0.8902    0.5412; 0.8431, 0.0980, 0.1098;0.9373    0.4745    0.4784],'n_color',2,'n_lightness',2);
gAmount_overall.set_names('x','','color','','column','');
gAmount_overall.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5],'ylim',[300 430]);
gAmount_overall.set_title('Amount of trials overall');
%gAmount_overall.set_text_options('base_size',12);
%gAmount_overall.set_order_options('x',{'3' '6' '9' '12' '15'});
%gAmount_overall.facet_wrap(avgAmount.trial_type,'ncols',4);

gAmount_overall.draw; 


%% REACTION TIME
%% Reaction Times per Condition
% Fig "mean Reaction Time": errorbars are 95% standard errors of the mean
% Fig "mean RT p. subject": errorbars are 95% standard deviations of mean p. condition

clear gRTcon;
% RT in conditions
figure ('Position', [100 100 900 600],'Name','Reaction Time density p. condition');
gRTcond = gramm('x',dat.RT,'color',dat.choice,'row',dat.effector,'linestyle',dat.target_selected,'subset', dat.success & ~dat.unrealRT);
% gRTcond(1,1).set_order_options('x',{'3' '6' '9' '12' '15'});
% gDelay.facet_wrap(dat.subj);
gRTcond.stat_density();
gRTcond.axe_property('xlim', [0 0.8]);
gRTcond.set_color_options('map',[0.9765    0.4510    0.0157; 0.0863    0.6000    0.7804],'n_color',2,'n_lightness',1);
gRTcond.set_names('Row','','x','reaction time','LineStyle','','color','');
gRTcond.set_title('Reaction Time p. condition');
gRTcond.set_text_options('base_size',12);
gRTcond.draw();


rt_con = rowfun(@mean,dat,'InputVariables',{'RT'},'GroupingVariable', {'effector','choice','target_selected','subj','success','unrealRT'},'OutputVariableNames','RT');

figure ('Position', [100 100 900 600],'Name','mean Reaction Time p. condition');
gRTcon = gramm('y',rt_con.RT,'x',rt_con.target_selected,'color',rt_con.choice,'lightness',rt_con.effector,'subset', rt_con.success & ~rt_con.unrealRT);
gRTcon.stat_summary('geom',{'bar', 'black_errorbar'},'setylim',true);
gRTcon.set_names('Row','','x','reaction time','lightness','effector','color','choice','y','RT');
gRTcon.set_title('mean Reaction Time');
gRTcon.set_color_options('map',[0.9765    0.4510    0.0157; 0.9882    0.6392    0.3529; 0.0863    0.6000    0.7804;0.4078    0.7961    0.9333],'n_color',2,'n_lightness',2,'legend','expand');
gRTcon.set_text_options('base_size',12);
gRTcon.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5]);
gRTcon.draw();

figure ('Position', [100 100 1600 1000],'Name','mean Reaction Time p. condition p .subject');
gRTcon2 = gramm('y',dat.RT,'x',dat.target_selected,'color',dat.choice,'lightness',dat.effector,'subset', dat.success & ~dat.unrealRT);
gRTcon2.stat_summary('geom',{'bar', 'black_errorbar'},'setylim',true);
gRTcon2.set_names('column','','x','reaction time','lightness','effector','color','choice','y','RT');
gRTcon2.set_title('mean Reaction Time p .subject');
gRTcon2.set_color_options('map',[0.9765    0.4510    0.0157; 0.9882    0.6392    0.3529; 0.0863    0.6000    0.7804;0.4078    0.7961    0.9333],'n_color',2,'n_lightness',2,'legend','expand');
%gRTcon2.set_text_options('base_size',12);
gRTcon2.facet_wrap(dat.subj,'ncols',5);
gRTcon2.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5],'ylim',[0.25 0.45]);
gRTcon2.draw();



%% Reaction Times per Delays
% all figures: errorbars are 95% standard error of the mean

clear gRTdel;
figure ('Position', [100 100 1800 1000]);
gRTdel(1,1) = gramm('x',dat.RT,'color',dat.delay,'subset', dat.success & ~dat.unrealRT);
gRTdel(1,1).set_order_options('color',{'3' '6' '9' '12' '15'});
% gDelay.facet_wrap(dat.subj);
gRTdel(1,1).stat_density();
gRTdel(1,1).axe_property('xlim', [0 0.8]);
gRTdel(1,1).set_names('Row','','x','reaction time','color','delay');
gRTdel(1,1).set_title('density');
gRTdel(1,1).set_text_options('base_size',12);


rt_del = rowfun(@mean,dat,'InputVariables',{'RT'},'GroupingVariable', {'delay','subj','success','unrealRT'},'OutputVariableNames','RT');

gRTdel(1,2) = gramm('y',rt_del.RT,'x',rt_del.delay,'group',rt_del.subj,'subset', rt_del.success & ~rt_del.unrealRT);
gRTdel(1,2).geom_point();
gRTdel(1,2).geom_line();
gRTdel(1,2).set_color_options('lightness',80,'chroma',0);
gRTdel(1,2).set_order_options('x',{'3' '6' '9' '12' '15'});
gRTdel(1,2).set_names('column','','x','delay','color','delay');
gRTdel(1,2).set_title('means');
gRTdel(1,2).set_text_options('base_size',12);


gRTdel(1,2).update('color',rt_del.delay,'group','');
gRTdel(1,2).set_color_options();
gRTdel(1,2).stat_summary('geom',{'point' 'line' 'errorbar'});
gRTdel(1,2).set_names('column','','x','delay','color','delay','y','reaction time');
gRTdel(1,2).no_legend();
gRTdel(1,2).set_order_options('x',{'3' '6' '9' '12' '15'},'color',{'3' '6' '9' '12' '15'});

gRTdel.set_title('reaction times p. delay');
gRTdel.draw();

% right figure: errorbars are 95% standard error of the mean

%% ORDERED SUBJECTS
% overall
clear gRTdelSu;
rt_del_sub = rowfun(@mean,dat,'InputVariables',{'RT'},'GroupingVariable', {'subj','success','unrealRT','delay'},'OutputVariableNames','RT');
rt_del_sub = rt_del_sub(rt_del_sub.success & rt_del_sub.delay == '12',:);
rt_del_sub.order = [1:height(rt_del_sub)]';
rt_del_sub = sortrows(rt_del_sub,{'RT'},{'ascend'});

figure ('Position', [100 100 1800 1000]);
gRTdelSu(1,2) = gramm('y',rt_del.RT,'x',rt_del.delay,'color',rt_del.subj,'subset', rt_del.success & ~rt_del.unrealRT);
gRTdelSu(1,2).geom_point();
gRTdelSu(1,2).geom_line();
gRTdelSu(1,2).set_order_options('x',{'3' '6' '9' '12' '15'},'color',rt_del_sub.order);
gRTdelSu(1,2).set_names('column','','x','delay','color','','y','RT');
gRTdelSu(1,2).set_title('Are subjects stable in their RT across delays? Ordered within delay 12');
gRTdelSu(1,2).draw;

%% per effector

% what data to take
rt_del_sub_con = rowfun(@mean,dat,'InputVariables',{'RT'},'GroupingVariable', {'subj','success','unrealRT','effector','delay'},'OutputVariableNames','RT');
rt_del_sub_con = rt_del_sub_con(rt_del_sub_con.success,:);
rt_del_sub_con.con = categorical(strcat(cellstr(rt_del_sub_con.effector)));


% How to sort
sort_subj = rt_del_sub_con;
sort_subj = sort_subj(sort_subj.success & sort_subj.delay == '12' & sort_subj.con =='reach',:);
sort_subj.order = [1:height(sort_subj)]';
sort_subj = sortrows(sort_subj,{'RT'},{'ascend'});
 
clear gRTdelSu;
figure ('Position', [100 100 1800 1000]);
gRTdelSu(1,2) = gramm('y',rt_del_sub_con.RT,'x',rt_del_sub_con.delay,'column',rt_del_sub_con.effector,'color',rt_del_sub_con.subj,'subset', rt_del_sub_con.success & ~rt_del_sub_con.unrealRT);
gRTdelSu(1,2).geom_point();
gRTdelSu(1,2).geom_line();
gRTdelSu(1,2).set_order_options('x',{'3' '6' '9' '12' '15'},'color',sort_subj.order);
gRTdelSu(1,2).set_names('column','','x','delay','color','','y','RT');
gRTdelSu(1,2).set_title('Ordered within reach, delay 12');
gRTdelSu(1,2).draw;

%% only reach
% per effector and side

% what data to take
rt_del_sub_con = rowfun(@mean,dat,'InputVariables',{'RT'},'GroupingVariable', {'subj','success','unrealRT','effector','delay','target_selected'},'OutputVariableNames','RT');
rt_del_sub_con = rt_del_sub_con(rt_del_sub_con.success & rt_del_sub_con.effector == 'reach',:);
%rt_del_sub_con.con = categorical(strcat(cellstr(rt_del_sub_con.effector),'_' ,cellstr(rt_del_sub_con.target_selected)));

% How to sort
sort_subj = rt_del_sub_con;
sort_subj = sort_subj(sort_subj.success & sort_subj.delay == '12' & sort_subj.target_selected =='left',:);
sort_subj.order = [1:height(sort_subj)]';
sort_subj = sortrows(sort_subj,{'RT'},{'ascend'});
 
clear gRTdelSu;
figure ('Position', [100 100 1800 1000]);
gRTdelSu(1,2) = gramm('y',rt_del_sub_con.RT,'x',rt_del_sub_con.delay,'column',rt_del_sub_con.target_selected,'color',rt_del_sub_con.subj,'subset', rt_del_sub_con.success & ~rt_del_sub_con.unrealRT);
gRTdelSu(1,2).geom_point();
gRTdelSu(1,2).geom_line();
gRTdelSu(1,2).set_order_options('x',{'3' '6' '9' '12' '15'},'color',sort_subj.order);
gRTdelSu(1,2).set_names('column','','x','delay','color','','y','RT');
gRTdelSu(1,2).set_title('Only reaches; ordered within left, delay 12');
gRTdelSu(1,2).draw;

%% only saccade
% per effector and side

% what data to take
rt_del_sub_con = rowfun(@mean,dat,'InputVariables',{'RT'},'GroupingVariable', {'subj','success','unrealRT','effector','delay','target_selected'},'OutputVariableNames','RT');
rt_del_sub_con = rt_del_sub_con(rt_del_sub_con.success & rt_del_sub_con.effector == 'saccade',:);
%rt_del_sub_con.con = categorical(strcat(cellstr(rt_del_sub_con.effector),'_' ,cellstr(rt_del_sub_con.target_selected)));

% How to sort
sort_subj = rt_del_sub_con;
sort_subj = sort_subj(sort_subj.success & sort_subj.delay == '12' & sort_subj.target_selected =='left',:);
sort_subj.order = [1:height(sort_subj)]';
sort_subj = sortrows(sort_subj,{'RT'},{'ascend'});
 
clear gRTdelSu;
figure ('Position', [100 100 1800 1000]);
gRTdelSu(1,2) = gramm('y',rt_del_sub_con.RT,'x',rt_del_sub_con.delay,'column',rt_del_sub_con.target_selected,'color',rt_del_sub_con.subj,'subset', rt_del_sub_con.success & ~rt_del_sub_con.unrealRT);
gRTdelSu(1,2).geom_point();
gRTdelSu(1,2).geom_line();
gRTdelSu(1,2).set_order_options('x',{'3' '6' '9' '12' '15'},'color',sort_subj.order);
gRTdelSu(1,2).set_names('column','','x','delay','color','','y','RT');
gRTdelSu(1,2).set_title('Only saccades; ordered within left, delay 12');
gRTdelSu(1,2).draw;


%% only saccade
% per effector and side

% what data to take
rt_del_sub_con = rowfun(@mean,dat,'InputVariables',{'RT'},'GroupingVariable', {'subj','success','unrealRT','effector','delay','target_selected'},'OutputVariableNames','RT');
rt_del_sub_con = rt_del_sub_con(rt_del_sub_con.success,:);
rt_del_sub_con.con = categorical(strcat(cellstr(rt_del_sub_con.effector),'_' ,cellstr(rt_del_sub_con.target_selected)));

% How to sort
sort_subj = rt_del_sub_con;
sort_subj = sort_subj(sort_subj.success & sort_subj.delay == '12' & sort_subj.con =='reach_right',:);
sort_subj.order = [1:height(sort_subj)]';
sort_subj = sortrows(sort_subj,{'RT'},{'ascend'});
 
clear gRTdelSu;
figure ('Position', [100 100 1800 1000]);
gRTdelSu(1,2) = gramm('y',rt_del_sub_con.RT,'x',rt_del_sub_con.delay,'row',rt_del_sub_con.effector,'column',rt_del_sub_con.target_selected,'color',rt_del_sub_con.subj,'subset', rt_del_sub_con.success & ~rt_del_sub_con.unrealRT);
gRTdelSu(1,2).geom_point();
gRTdelSu(1,2).geom_line();
gRTdelSu(1,2).set_order_options('x',{'3' '6' '9' '12' '15'},'color',sort_subj.order);
gRTdelSu(1,2).set_names('column','','x','delay','color','','y','RT','row','');
gRTdelSu(1,2).set_title('ordered within reach_right, delay 12');
gRTdelSu(1,2).draw;




%% TEST TEST TEST 

% % what data to take
% rt_del_sub_con = rowfun(@mean,dat,'InputVariables',{'RT'},'GroupingVariable', {'subj','success','unrealRT','effector', 'choice', 'target_selected','delay'},'OutputVariableNames','RT');
% rt_del_sub_con = rt_del_sub_con(rt_del_sub_con.success,:);
% rt_del_sub_con.con = categorical(strcat(cellstr(rt_del_sub_con.effector),'_' ,cellstr(rt_del_sub_con.choice),'_',cellstr(rt_del_sub_con.target_selected)));
% 
% 
% % How to sort
% sort_subj = rt_del_sub_con;
% sort_subj = sort_subj(sort_subj.success & sort_subj.delay == '9' & sort_subj.con =='reach_choice_left',:);
% sort_subj.order = [1:height(sort_subj)]';
% sort_subj = sortrows(sort_subj,{'RT'},{'ascend'});
%  
% clear gRTdelSu;
% figure ('Position', [100 100 1800 1000]);
% gRTdelSu(1,2) = gramm('y',rt_del_sub_con.RT,'x',rt_del_sub_con.delay,'color',rt_del_sub_con.subj,'subset', rt_del_sub_con.success & ~rt_del_sub_con.unrealRT);
% gRTdelSu(1,2).geom_point();
% gRTdelSu(1,2).geom_line();
% gRTdelSu(1,2).facet_wrap(rt_del_sub_con.con);
% gRTdelSu(1,2).set_order_options('x',{'3' '6' '9' '12' '15'},'color',sort_subj.order);
% gRTdelSu(1,2).draw;


%%
rt_del_con = rowfun(@mean,dat,'InputVariables',{'RT'},'GroupingVariable', {'effector','choice','target_selected','delay','subj','success','unrealRT'},'OutputVariableNames','RT');

figure ('Position', [100 100 900 600]);
gRTdelcon = gramm('y',rt_del_con.RT,'x',rt_del_con.delay,'column',rt_del_con.effector,'linestyle',rt_del_con.target_selected,'color',rt_del_con.choice,'subset', rt_del_con.success & ~rt_del_con.unrealRT);
gRTdelcon.stat_summary('geom',{'line' 'errorbar'},'setylim',true);
gRTdelcon.set_color_options('map',[0.9765, 0.4510, 0.0157; 0.0863, 0.6000, 0.7804],'n_color',2,'n_lightness',1);
gRTdelcon.set_order_options('x',{'3' '6' '9' '12' '15'});
gRTdelcon.set_names('column','','x','delay','color','delay');
gRTdelcon.set_title('mean per delay');
gRTdelcon.set_text_options('base_size',12);
gRTdelcon.set_names('column','','x','delay','color','','y','reaction time','linestyle','');
gRTdelcon.set_title('reaction time for REACH and SACCADE');
gRTdelcon.draw();

% errorbars are 95% standard errors of the mean

figure ('Position', [100 100 900 600]);
gRTdelcon = gramm('y',rt_del_con.RT,'x',rt_del_con.delay,'color',rt_del_con.effector,'linestyle',rt_del_con.target_selected,'column',rt_del_con.choice,'subset', rt_del_con.success & ~rt_del_con.unrealRT);
gRTdelcon.stat_summary('geom',{'line' 'errorbar'},'setylim',true);
gRTdelcon.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1);
gRTdelcon.set_order_options('x',{'3' '6' '9' '12' '15'});
gRTdelcon.set_names('column','','x','delay','color','delay');
gRTdelcon.set_title('mean per delay');
gRTdelcon.set_text_options('base_size',12);
gRTdelcon.set_names('column','','x','delay','color','','y','reaction time','linestyle','');
gRTdelcon.set_title('reaction time for CHOICE and INSTRUCTED');
gRTdelcon.draw();

% errorbars are 95% standard errors of the mean
%%

figure ('Position', [100 100 900 600]);
gRTdelcon = gramm('y',rt_del_con.RT,'x',rt_del_con.delay,'color',rt_del_con.effector,'linestyle',rt_del_con.choice,'column',rt_del_con.target_selected,'subset', rt_del_con.success & ~rt_del_con.unrealRT);
gRTdelcon.stat_summary('geom',{'line' 'errorbar'},'setylim',true);
gRTdelcon.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1);
gRTdelcon.set_order_options('x',{'3' '6' '9' '12' '15'});
gRTdelcon.set_names('column','','x','delay','color','delay');
gRTdelcon.set_title('mean per delay');
gRTdelcon.set_text_options('base_size',12);
gRTdelcon.set_names('column','','x','delay','color','','y','reaction time','linestyle','');
gRTdelcon.set_title('reaction time for LEFT and RIGHT');
gRTdelcon.draw();

%%
%%
% subject: random slope / delay: random slope
glme_SubSl_DelSl = fitglme(dat_cl,'RT ~ effector * choice * target_selected + (effector * choice * target_selected|subj) + (effector * choice * target_selected|num_delay)','Distribution','InverseGaussian');
% subject: random intercept / delay: random slope
glme_SubIn_DelSl = fitglme(dat_cl,'RT ~ effector * choice * target_selected   +                                 (1|subj) + (effector * choice * target_selected|num_delay)','Distribution','InverseGaussian');
% subject: random slope / delay: random intercept
glme_SubSl_DelIn = fitglme(dat,'RT ~ effector * choice * target_selected + (effector * choice * target_selected|subj) +                                   (1|num_delay)','Distribution','InverseGaussian');
% subject: random intercept / delay: random intercept
glme_SubIn_DelIn = fitglme(dat,'RT ~ effector * choice * target_selected   +                                 (1|subj) +                                   (1|num_delay)','Distribution','InverseGaussian');



%% Stats RT having DELAY as RANDOM effect
load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\stats.mat');

%% Model 1: glme_SubSl_DelSl = fitglme(dat_cl,'RT ~ effector * choice * target_selected + (effector * choice * target_selected|subj) + (effector * choice * target_selected|num_delay)','Distribution','InverseGaussian');
glme_SubSl_DelSl.anova
glme_SubSl_DelSl.Rsquared

%% Model 2.1: glme_SubIn_DelSl = fitglme(dat_cl,'RT ~ effector * choice * target_selected   +                                 (1|subj) + (effector * choice * target_selected|num_delay)','Distribution','InverseGaussian');
glme_SubIn_DelSl.anova
glme_SubIn_DelSl.Rsquared

compare(glme_SubIn_DelSl,glme_SubSl_DelSl,'CheckNesting',true)
%  The small p-value indicates that compare rejects the null hypothesis
%  that the response vector was generated by the fixed-effects-only model FEglme, in favor of the alternative that the response vector was generated by the mixed-effects model glme.

%% Model 2.2: glme_SubSl_DelIn = fitglme(dat_cl,'RT ~ effector * choice * target_selected + (effector * choice * target_selected|subj) +                                   (1|num_delay)','Distribution','InverseGaussian');
glme_SubSl_DelIn.anova
glme_SubSl_DelIn.Rsquared

compare(glme_SubSl_DelIn,glme_SubSl_DelSl,'CheckNesting',true)

%% Model 3: glme_SubIn_DelIn = fitglme(dat_cl,'RT ~ effector * choice * target_selected   +                                 (1|subj) +                                   (1|num_delay)','Distribution','InverseGaussian');
glme_SubIn_DelIn.anova
glme_SubIn_DelIn.Rsquared

compare(glme_SubIn_DelIn,glme_SubSl_DelIn,'CheckNesting',true)



%% Reaction Time over time

figure ('Position', [100 100 1600 1000]);
gRTtime(1,1) = gramm('x',dat.RT,'color',dat.run,'row',dat.effector,'subset',dat.success & ~dat.unrealRT);
gRTtime(1,1).stat_density();
gRTtime(1,1).set_names('Row','','x','reaction time','color','run');
gRTtime(1,1).set_title('RT by run');
gRTtime(1,1).set_text_options('base_size',12);

gRTtime(1,2) = gramm('x',dat.RT,'linestyle',dat.session,'color',dat.effector,'row',dat.effector,'subset',dat.success & ~dat.unrealRT);
gRTtime(1,2).stat_density();
gRTtime(1,2).set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
gRTtime(1,2).set_names('Row','','x','reaction time','linestyle','session');
gRTtime(1,2).set_title('RT by session');
gRTtime(1,2).set_text_options('base_size',12);

gRTtime.set_title('reaction time over time');
gRTtime.draw;


%% CHOICE BIAS
%% Choice Bias over Time

%cb = (sum(dat.target_selected == 'right') - sum(dat.target_selected == 'left')) / (sum(dat.target_selected == 'right') + sum(dat.target_selected == 'left'));

dat.right_selected_choice = (dat.target_selected == 'right') & (dat.choice == 'choice') & dat.success;
dat.left_selected_choice = (dat.target_selected  == 'left') & (dat.choice == 'choice') & dat.success;


func = @(r,l) 100*( (sum(r)) / (sum(r|l)) );


cb_all = rowfun(func,dat,'InputVariables',{'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'effector','session','run','subj'},'OutputVariableNames','choice_bias');

%% CB per run
% grey lines are linear models per subject
% shaded area are 95% standard errors of the mean

clear gCBtime
figure ('Position', [100 100 1200 700]);
gCBtime = gramm('x',cb_all.run,'y',cb_all.choice_bias,'group',cb_all.subj);
gCBtime.stat_glm('geom', {'line'});
%gCBtime.stat_summary('geom','line')
%gCBtime.stat_summary('geom','point')
gCBtime.facet_grid([],cb_all.effector);
gCBtime.set_color_options('lightness',80,'chroma',0);%,'chroma_range',[80 40]);
gCBtime.geom_hline('yintercept',50,'style','k--');
gCBtime.set_names('x','run','y','proportion right choices in %','column','','linestyle','session');
gCBtime.set_title({'Choice Bias per run'});
gCBtime.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5]);
gCBtime.set_text_options('base_size',12);

gCBtime.update('color',cb_all.effector,'group','');
gCBtime.stat_glm();
gCBtime.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');

gCBtime.draw;


%% CB per Session 
% grey lines are linear models per subject
% shaded area are 95% standard errors of the mean

cb_sesh_all = rowfun(func,dat,'InputVariables',{'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'effector', 'session','subj'},'OutputVariableNames','choice_bias');

clear gCBtimeR
figure ('Position', [100 100 1600 1000]);
gCBtimeR(1,1) = gramm('x',cb_sesh_all.session,'y',cb_sesh_all.choice_bias,'color',cb_sesh_all.effector,'column',cb_sesh_all.effector,'group',cb_sesh_all.subj);
%gcb_seshtime.stat_glm('distribution', 'normal');
gCBtimeR(1,1).geom_point();
gCBtimeR(1,1).geom_line();
%gcb_seshtime.stat_summary('geom',)
%gCBtimeR(1,1).geom_label('VerticalAlignment','middle','HorizontalAlignment','center','BackgroundColor','w','Color','k');
gCBtimeR(1,1).set_color_options('lightness',80,'chroma',0)%,'chroma_range',[80 40]);
gCBtimeR(1,1).geom_hline('yintercept',50,'style','k--');
gCBtimeR(1,1).set_names('x','session','y','% right choices','column','');
gCBtimeR(1,1).set_title({'Choice Bias per Session'});
gCBtimeR(1,1).axe_property('Ylim',[0 100],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
gCBtimeR(1,1).set_text_options('base_size',12);
gCBtimeR(1,1).no_legend();

gCBtimeR(1,1).update('color',cb_sesh_all.effector,'group','');
gCBtimeR(1,1).stat_summary('geom',{'point','line','errorbar'});
gCBtimeR(1,1).set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');



gCBtimeR(2,1) = gramm('x',cb_sesh_all.session,'y',cb_sesh_all.choice_bias,'color',cb_sesh_all.effector,'column',cb_sesh_all.effector,'group',cb_sesh_all.subj);
%gcb_seshtime.stat_glm('distribution', 'normal');
gCBtimeR(2,1).stat_glm('geom','line');
%gcb_seshtime.stat_summary('geom',)
%gCBtimeR(2,1).geom_label('VerticalAlignment','middle','HorizontalAlignment','center','BackgroundColor','w','Color','k');
gCBtimeR(2,1).set_color_options('lightness',80,'chroma',0);%,'chroma_range',[80 40]);
gCBtimeR(2,1).geom_hline('yintercept',50,'style','k--');
gCBtimeR(2,1).set_names('x','session','y','% right choices','column','');
%gCBtimeR(2,1).set_title({'Choice Bias per Session'});
gCBtimeR(2,1).axe_property('Ylim',[0 100],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
gCBtimeR(2,1).set_text_options('base_size',12);
gCBtimeR(2,1).no_legend();

gCBtimeR(2,1).update('color',cb_sesh_all.effector,'group','');
%gCBtimeR(2,1).stat_summary('geom',{'point','line','errorbar'});
gCBtimeR(2,1).stat_glm();
gCBtimeR(2,1).set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');


gCBtimeR.draw;



%%
clear gCBtimeR2
figure ('Position', [100 100 1600 1000]);
gCBtimeR2 = gramm('x',cb_sesh_all.effector,'y',cb_sesh_all.choice_bias,'label',cb_sesh_all.GroupCount,'linestyle',cb_sesh_all.session);
gCBtimeR2.geom_point();
gCBtimeR2.geom_line();
gCBtimeR2.set_title('choice biases p. subject p. session');
gCBtimeR2.facet_wrap(cb_sesh_all.subj,'ncols',5);
%gCBtimeR2.geom_bar();
gCBtimeR2.geom_hline('yintercept',50,'style','k--');
gCBtimeR2.set_names('x','','y','% right choices','linestyle','session','column','');
gCBtimeR2.set_order_options('x',{'reach' 'saccade'});
gCBtimeR2.set_text_options('base_size',12);
gCBtimeR2.axe_property('Ylim',[0 100],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
gCBtimeR2.set_color_options('map',[0.9765    0.4510    0.0157; 0.9882    0.6392    0.3529; 0.0863    0.6000    0.7804;0.4078    0.7961    0.9333],'n_color',2,'n_lightness',2,'legend','merge');

gCBtimeR2.draw;



%% Choice Bias overall

cb_ges_all = rowfun(func,dat,'InputVariables',{'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'effector','subj'},'OutputVariableNames','choice_bias');

clear gCBges
figure ('Position', [100 100 900 600]);
gCBges = gramm('x',cb_ges_all.effector,'y',cb_ges_all.choice_bias-50,'label',cb_ges_all.GroupCount,'group',cb_ges_all.subj);
gCBges.geom_jitter();
%gCBges.geom_bar();
%gCBges.geom_label('VerticalAlignment','middle','HorizontalAlignment','center','BackgroundColor','w','Color','k');
gCBges.geom_hline('yintercept',0,'style','k--');
gCBges.set_names('x','','y','% left ------------ % right');
gCBges.set_title('mean Choice Bias overall');
gCBges.set_order_options('x',{'reach' 'saccade'});
gCBges.set_text_options('base_size',12);
%gCBges.axe_property('Ylim',[-40 40])
gCBges.set_color_options('chroma',0,'lightness',40);

gCBges.update('color',cb_ges_all.effector,'group','');
gCBges.stat_summary('geom',{'bar','black_errorbar'});
gCBges.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');

gCBges.draw;

% grey points are means per subject
% errorbars are 95% standard errors of the mean
%% stats
cb_ges_all.norm_cb = cb_ges_all.choice_bias -50 ;

lcb_sl = fitlme(cb_ges_all,'norm_cb ~ effector + (effector|subj)');
lcb_in = fitlme(cb_ges_all,'norm_cb ~ effector + (1|subj)');

compare(lcb_in,lcb_sl,'CheckNesting',true)

lcb_in
lcb_in.anova
lcb_in.Rsquared

%%
cb_ges_all = rowfun(func,dat,'InputVariables',{'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'effector','subj'},'OutputVariableNames','choice_bias');
cb_ges_all.cb_right = cb_ges_all.choice_bias > 50; 
cb_ges_all.cat = cell(length(cb_ges_all.subj),1);

uni_su = unique(cb_ges_all.subj);
for i = 1:length(uni_su)
   wh = cb_ges_all(cb_ges_all.subj == uni_su(i),:);
   if wh.cb_right(1) == wh.cb_right(2)
       cb_ges_all.cat(cb_ges_all.subj == uni_su(i)) = {'same'};
   else
       cb_ges_all.cat(cb_ges_all.subj == uni_su(i)) = {'different'};
    
   end
    
end

clear gCBges
figure ('Position', [10 10 1700 1100]);
gCBges = gramm('x',cb_ges_all.effector,'y',(cb_ges_all.choice_bias-50),'color',cb_ges_all.effector);
gCBges.facet_wrap(cb_ges_all.subj,'ncols',5);
gCBges.geom_bar;
gCBges.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
gCBges.geom_hline('yintercept',0,'style','k--');
gCBges.set_names('x','','y','% left ------------ % right','column','');
gCBges.set_title('mean Choice Bias overall p. subject');
gCBges.set_order_options('x',{'reach' 'saccade'});
gCBges.set_text_options('base_size',12);
gCBges.axe_property('Ylim',[-40 40],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
gCBges.draw;


cb_ges_all.number_subj = repmat(1:(height(cb_ges_all))/2,1,2)';
order = sortrows(cb_ges_all,{'effector','choice_bias'},{'descend','ascend'});


clear gCBges2
figure ('Position', [10 10 1500 700]);
gCBges2 = gramm('x',(cb_ges_all.subj),'y',(cb_ges_all.choice_bias-50)*2,'row',cb_ges_all.effector,'color',cb_ges_all.effector);
%gCBges2.facet_wrap(cb_ges_all.subj,'ncols',5);
gCBges2.geom_bar;
gCBges2.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
gCBges2.geom_hline('yintercept',0,'style','k--');
gCBges2.set_names('x','','y','% left ------------ % right','row','');
gCBges2.set_title('mean Choice Bias p. subject ordered');
gCBges2.set_order_options('x',order.number_subj(1:(height(cb_ges_all))/2),'row',[2 1]);
gCBges2.set_text_options('base_size',12);
%gCBges2.axe_property('Ylim',[-40 40],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
gCBges2.draw;
%%

order_same = cb_ges_all(strcmp(order2.cat,'same'),:);
order_different = cb_ges_all(strcmp(order2.cat,'different'),:);

orderorder_same = sortrows(order_same,{'effector','choice_bias'},{'descend','ascend'});
order_different = sortrows(order_different,{'effector','choice_bias'},{'descend','ascend'});




clear gCBges3
figure ('Position', [10 10 1500 700]);
gCBges3(1,1) = gramm('x',(order2_same.subj),'y',(order2_same.choice_bias-50)*2,'row',order2_same.effector,'color',order2_same.effector,'subset',strcmp(order2_same.cat,'same'));
%gCBges3(1,1).facet_wrap(cb_ges_all.subj,'ncols',5);
gCBges3(1,1).geom_bar;
gCBges3(1,1).set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
gCBges3(1,1).geom_hline('yintercept',0,'style','k--');
gCBges3(1,1).set_names('x','','y','% left ------------ % right','row','');
gCBges3(1,1).set_title('different side');
gCBges3(1,1).set_order_options('x',order2_same.number_subj(1:(height(order2_same))/2),'row',[2 1]);
gCBges3(1,1).set_text_options('base_size',12);
%gCBges2.axe_property('Ylim',[-40 40],'Ygrid','on','GridColor',[0.5 0.5 0.5]);

gCBges3(1,2) = gramm('x',(order2_different.subj),'y',order2_different.choice_bias-50,'row',order2_different.effector,'color',order2_different.effector,'subset',strcmp(order2_different.cat,'different'));
%gCBges3(1,2).facet_wrap(cb_ges_all.subj,'ncols',5);
gCBges3(1,2).geom_bar;
gCBges3(1,2).set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
gCBges3(1,2).geom_hline('yintercept',0,'style','k--');
gCBges3(1,2).set_names('x','','y','% left ------------ % right','row','');
gCBges3(1,2).set_title('same side');
gCBges3(1,2).set_order_options('x',order2_different.number_subj(1:(height(order2_different))/2),'row',[2 1]);
gCBges3(1,2).set_text_options('base_size',12);
gCBges3(1,2).axe_property('Ylim',[-40 40],'Ygrid','on','GridColor',[0.5 0.5 0.5]);

gCBges3.set_title('mean Choice Bias p. subject ordered');
gCBges3.draw;


%% Choice Bias per delay

cb_del = rowfun(func,dat,'InputVariables',{'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'success','effector', 'delay','subj'},'OutputVariableNames','choice_bias');

figure ('Position', [100 100 900 700]);
gCBdel = gramm('x',cb_del.delay,'row',cb_del.effector,'y',cb_del.choice_bias,'color',cb_del.effector,'subset',cb_del.success);
gCBdel.stat_summary('geom',{'point','line', 'errorbar'});
gCBdel.geom_hline('yintercept',50,'style','k--');
gCBdel.set_names('x','delay','row','','Color','','y','% right choices');
gCBdel.set_title('mean Choice Bias p. delay');
gCBdel.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
%gCBdel.axe_property('Ylim',[0 1])
gCBdel.axe_property('Ylim',[0 100],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
gCBdel.set_order_options('x',{'3' '6' '9' '12' '15'});
gCBdel.set_text_options('base_size',12);
gCBdel.draw;

% errorbars are 95% standard errors of the mean

figure ('Position', [100 100 1600 1000]);
gCBdel = gramm('x',cb_del.delay,'y',cb_del.choice_bias,'color',cb_del.effector,'subset',cb_del.success);
gCBdel.geom_line();
gCBdel.geom_point();
gCBdel.geom_hline('yintercept',50,'style','k--');
gCBdel.set_names('x','delay','row','','Color','','y','% right choices','column','');
gCBdel.set_title('mean Choice Bias p. delay p. subject');
gCBdel.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1);
%gCBdel.axe_property('Ylim',[0 1])
gCBdel.axe_property('Ylim',[0 100],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
gCBdel.set_order_options('x',{'3' '6' '9' '12' '15'});
gCBdel.set_text_options('base_size',12);
gCBdel.facet_wrap(cb_del.subj,'ncols',5);
gCBdel.draw;



%% CHOICE BIAS VS. REACTION TIME
%%  Choice Bias vs. Reaction Time
% errorbars are 95% standard errors of the mean
% markers are subjects

func_RT_rl = @(RT,r,l,u) mean(RT(r & ~u)) - mean(RT(l & ~u));
dRT = rowfun(func_RT_rl,dat,'InputVariables',{'RT' 'right_selected_choice' 'left_selected_choice' 'unrealRT'},'GroupingVariable', {'effector','subj'},'OutputVariableNames','dRT');

figure ('Position', [100 100 900 600]);
gCBRT = gramm('x',cb_ges_all.choice_bias,'y',dRT.dRT,'color',cb_ges_all.effector);
gCBRT.stat_glm();
gCBRT.geom_hline('yintercept',0,'style','k--');
gCBRT.set_names('x','% right choices','row','','y','f(x) = meanRT(right) - meanRT(left)');
gCBRT.axe_property('Xlim',[0 100],'Ylim',[-0.1 0.1])
gCBRT.set_title('Choice Bias vs. deltaRT');
gCBRT.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1);
gCBRT.set_text_options('base_size',12);

gCBRT.update('marker',cb_ges_all.subj);
gCBRT.geom_point();
gCBRT.no_legend();
gCBRT.draw();

% errorbars are 95% standard errors of the mean
% markers are subjects


%% Choice Bias vs. Reaction Time per Delay

dRT_del = rowfun(func_RT_rl,dat,'InputVariables',{'RT' 'right_selected_choice' 'left_selected_choice' 'unrealRT'},'GroupingVariable', {'success' 'effector','subj','delay'},'OutputVariableNames','dRT');
dRT_del = dRT_del(dRT_del.success,:);

cbRT_del = cb_del(cb_del.success,:);

figure ('Position', [100 100 900 600]);
gCBRT_del = gramm('x',cbRT_del.choice_bias,'y',dRT_del.dRT,'color',cbRT_del.effector);
gCBRT_del.facet_wrap(cbRT_del.delay,'ncols',3);
gCBRT_del.stat_glm();
gCBRT_del.geom_point();
gCBRT_del.no_legend();
gCBRT_del.geom_hline('yintercept',0,'style','k--');
gCBRT_del.set_names('x','CB % left ------------- % right','column','delay','y','f(x) = meanRT(right) - meanRT(left)');
gCBRT_del.axe_property('Xlim',[0 100],'Ylim',[-0.2 0.2])
gCBRT_del.set_title('Choice Bias vs. deltaRT p. delay');
gCBRT_del.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1);
gCBRT_del.set_text_options('base_size',12);
gCBRT_del.set_order_options('column',{'3' '6' '9' '12' '15'});

gCBRT_del.draw();


figure ('Position', [100 100 900 600]);
gCBRT_del2 = gramm('x',cbRT_del.choice_bias,'y',dRT_del.dRT,'color',cbRT_del.effector);
%gCBRT_del2.facet_wrap(cbRT_del.delay,'ncols',3);
gCBRT_del2.stat_glm();
gCBRT_del2.geom_hline('yintercept',0,'style','k--');
gCBRT_del2.set_names('x','CB % left ------------- % right','row','','y','f(x) = meanRT(right) - meanRT(left)','marker','');
gCBRT_del2.axe_property('Xlim',[0 100],'Ylim',[-0.2 0.2])
gCBRT_del2.set_title('Choice Bias vs. deltaRT p. subject');
gCBRT_del2.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1);
gCBRT_del2.set_text_options('base_size',12);
gCBRT_del2.set_order_options('marker',{'3' '6' '9' '12' '15'});

gCBRT_del2.update('marker',cbRT_del.delay);
gCBRT_del2.geom_point();
gCBRT_del2.draw();

%% stats: lmecb = fitlme(cb_ges_all,'dRT ~ choice_bias * effector + (1|subj)');

cb_ges_all.dRT = dRT.dRT;

lmecb = fitlme(cb_ges_all,'dRT ~ choice_bias * effector + (effector|subj)');
lmecb2 = fitlme(cb_ges_all,'dRT ~ choice_bias * effector + (1|subj)');

compare(lmecb2,lmecb)

lmecb2
lmecb2.anova
lmecb2.Rsquared

close all;
return;
%% Errors

% ATTENTION: This analysis is across all trials, regardless of different
% amount of trials per subject

% Delay Errors relative to all
err = table();
err.delay = (unique(dat.delay));
err.prob_err = NaN(length(err.delay),1);
err.prob_delay = NaN(length(err.delay),1);

for i = 1:length(err.delay)
 
    err.prob_err(i)   = sum(~dat.success(dat.delay == err.delay(i))) / length(dat.delay) * 100;
    err.prob_delay(i) = sum(dat.delay == err.delay(i))               / length(dat.delay) * 100;
end

% Delay Errors relativ normalized

err_del = rowfun(@(s) sum(~s),dat,'InputVariables',{'success'},'GroupingVariable', {'delay'},'OutputVariableNames','err_per_del');
err_del.err_normalized = err_del.err_per_del ./ err_del.GroupCount * 100;

% errors in delays
clear gErrDel

figure ('Position', [100 100 1600 1000]);
gErrDel(1,1) = gramm('x',err.delay,'y',err.prob_delay);%,'y',err.prob_delay);
gErrDel(1,1).geom_bar();
gErrDel(1,1).set_order_options('x',{'3' '6' '9' '12' '15'});
gErrDel(1,1).set_color_options('chroma',0,'lightness',90)
gErrDel(1,1).set_names('x','all (grey) + erroneous (red) delays','y','probability overall')
gErrDel(1,1).set_title('relative to all trials')
gErrDel(1,1).axe_property('Ylim',[0 35],'Ygrid','on','GridColor',[0.5 0.5 0.5]);

gErrDel(1,1).update('y',err.prob_err);
gErrDel(1,1).geom_bar();

gErrDel(1,1).set_color_options('chroma',75)


gErrDel(1,2) = gramm('x',err_del.delay,'y',err_del.err_normalized);
gErrDel(1,2).geom_line();
gErrDel(1,2).geom_point();
gErrDel(1,2).set_order_options('x',{'3' '6' '9' '12' '15'});
%gErrDel(1,2).set_color_options('chroma',0,'lightness',90)
gErrDel(1,2).geom_hline('yintercept',mean(err_del.err_normalized),'style','k:');
gErrDel(1,2).axe_property('Ylim',[0 25]);

gErrDel(1,2).set_names('x','erroneous delays','y','probability per group')
gErrDel(1,2).set_title('normalized with n per delay')
gErrDel(1,2).set_color_options('chroma',75)

gErrDel.set_text_options('base_size',12);
gErrDel.set_title('erroneous delays')
gErrDel.draw;

%% Error over time

% err_time = rowfun(@(x) sum(~x),dat,'InputVariables',{'success'},'GroupingVariable', {'effector', 'session', 'run'},'OutputVariableNames','n_error');
% err_time.err_prob = err_time.n_error./err_time.GroupCount * 100;
% 
% figure;
% gErrTime = gramm('x',err_time.run,'y',err_time.err_prob,'column',err_time.effector);
% gErrTime.stat_glm();
% gErrTime.set_color_options('lightness',80,'chroma',0)
% gErrTime.set_names('x','runs','y','probability errors per run in %','linestyle','Session','column','')
% gErrTime.axe_property('Ylim',[0 50],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
% gErrTime.set_title('errors over time')
% 
% gErrTime.update('color',err_time.effector, 'linestyle',err_time.session)
% gErrTime.geom_line();
% gErrTime.geom_point();
% gErrTime.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
% 
% gErrTime.set_text_options('base_size',12);
% gErrTime.draw;




%% **************************** STATS group wise **************************************

dat_cl = dat(~dat.unrealRT & dat.success,:);

dat_cl.target_selected = removecats(dat_cl.target_selected);

%%
% subject: random slope / delay: random slope
glme_SubSl_DelSl = fitglme(dat,'RT ~ effector * choice * target_selected + (effector * choice * target_selected|subj) + (effector * choice * target_selected|num_delay)','Distribution','InverseGaussian');
% subject: random intercept / delay: random slope
glme_SubIn_DelSl = fitglme(dat,'RT ~ effector * choice * target_selected   +                                 (1|subj) + (effector * choice * target_selected|num_delay)','Distribution','InverseGaussian');
% subject: random slope / delay: random intercept
glme_SubSl_DelIn = fitglme(dat,'RT ~ effector * choice * target_selected + (effector * choice * target_selected|subj) +                                   (1|num_delay)','Distribution','InverseGaussian');
% subject: random intercept / delay: random intercept
glme_SubIn_DelIn = fitglme(dat,'RT ~ effector * choice * target_selected   +                                 (1|subj) +                                   (1|num_delay)','Distribution','InverseGaussian');
%%
test_sac = fitglme(dat_cl(dat_cl.effector == 'saccade',:),'RT ~  choice * target_selected + (num_delay|subj)','Distribution','InverseGaussian');
test_reach = fitglme(dat_cl(dat_cl.effector == 'reach',:),'RT ~  choice * target_selected + (num_delay|subj)','Distribution','InverseGaussian');

compare(glme_SubEFFE_DelSl,glme_SubSl_DelSl)



glme3 = fitglme(dat_cl,'RT ~ effector * choice * target_selected * num_delay + (effector * choice  *target_selected|subj) ','Distribution','InverseGaussian');

glme3_2 = fitglme(dat_cl,'RT ~ effector * choice * target_selected * num_delay + (1|subj) ','Distribution','InverseGaussian');

%%

%save('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\stats.mat','glme_SubSl_DelSl','glme_SubIn_DelSl','glme_SubSl_DelIn','glme_SubIn_DelIn','glme_SubIn_DelIn');
%%
msel = fitglme (dat_cl,'target_selected ~ num_delay + (1|subj)','Distribution','Binomial');



%% stats choice bias

glme_SubEFFE_DelSl_1 = fitglme(dat_cl,'RT ~ effector * choice * target_selected + (effector*num_delay*target_selected*choice|subj) + (1|num_delay)','Distribution','InverseGaussian');
glme_SubEFFE_DelSl = fitglme(dat_cl,'RT ~ effector * choice * target_selected + (effector*num_delay*target_selected|subj) + (1|num_delay)','Distribution','InverseGaussian');
glme_SubEFFE_DelSl2 = fitglme(dat_cl,'RT ~ effector * choice * target_selected + (effector*num_delay|subj) + (1|num_delay)','Distribution','InverseGaussian');
glme_SubEFFE_DelSl3 = fitglme(dat_cl,'RT ~ effector * choice * target_selected + (effector*num_delay*choice|subj) + (1|num_delay)','Distribution','InverseGaussian');

compare(glme_SubEFFE_DelSl2,glme_SubEFFE_DelSl3)


%load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\stats.mat');



