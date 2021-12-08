function frd_plots_subjectlevel(subj_id)
%% plot subject level
% Plot behavioral analysis across subjects
subj_id = categorical(subj_id);
disp(subj_id)


load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\current_dat_file.mat','dat');

dat(dat.subj_id ~= subj_id,:) = [];
name = char(dat.subj(1));
disp(name)

% excluding criteria
dat.unrealRT = dat.RT == -99 | dat.RT > 0.8 | (dat.RT < 0.2 & dat.effector == 'saccade');
weirdos = dat(dat.unrealRT,:);
dat(dat.unrealRT,:) = [];
dat = dat(dat.success,:);

% choice
%gCompRT.set_color_options('map',[0.9765, 0.4510, 0.0157; 0.0863, 0.6000, 0.7804],'n_color',2,'n_lightness',1);

% effector
%gCBtime.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
%gAmount.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.3804    0.8902    0.5412; 0.8431, 0.0980, 0.1098;0.9373    0.4745    0.4784],'n_color',2,'n_lightness',2);

% trial_type

dat.trial_type = strcat(cellstr(dat.effector),'_' ,cellstr(dat.choice),'_',cellstr(dat.target_selected));
dat.trial_type_del = strcat(cellstr(dat.effector),'_' ,cellstr(dat.choice),'_',cellstr(dat.target_selected),'_',cellstr(dat.delay));


%% Amount of Trials

figure ('Position', [100 100 800 500],'Name',['Amount of trials per delay - ' name]);
gAmount = gramm('y',dat.success,'x',dat.choice,'color',dat.effector,'lightness',dat.target_selected,'subset',dat.target_selected ~= 'none' & dat.success);
gAmount.stat_bin();
gAmount.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.3804    0.8902    0.5412; 0.8431, 0.0980, 0.1098;0.9373    0.4745    0.4784],'n_color',2,'n_lightness',2);
gAmount.set_names('x','','color','','lightness','');
gAmount.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5]);
gAmount.set_title(['Amount of trials ' name]);
gAmount.set_text_options('base_size',12);
gAmount.geom_hline('yintercept',20,'style','k--');
gAmount.draw; 

figure ('Position', [100 100 1600 1000],'Name',['Amount of trials per delay - ' name]);
gAmount = gramm('y',dat.success,'x',dat.choice,'color',dat.effector,'lightness',dat.target_selected,'subset',dat.target_selected ~= 'none' & dat.success);
gAmount.stat_bin();
gAmount.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.3804    0.8902    0.5412; 0.8431, 0.0980, 0.1098;0.9373    0.4745    0.4784],'n_color',2,'n_lightness',2);
gAmount.set_names('x','','color','','lightness','','column','delay');
gAmount.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5]);
gAmount.set_title(['Amount of trials per delay - ' name]);
gAmount.set_text_options('base_size',12);
gAmount.facet_wrap(dat.delay,'ncols',3);
gAmount.set_order_options('column',{'3' '6' '9' '12' '15'});
gAmount.geom_hline('yintercept',20,'style','k--');
gAmount.draw; 


%% ++++++++++++++++++++++++ RT +++++++++++++++++++++++++++++++
%% RT: density conditions
clear gRTcon
% RT in conditions
figure ('Position', [100 100 900 600],'Name',['density RT of ' name]);
gRTcon = gramm('x',dat.RT,'color',dat.choice,'linestyle',dat.target_selected,'row',dat.effector,'subset', dat.success & ~dat.unrealRT);
% gRTcon(1,1).set_order_options('x',{'3' '6' '9' '12' '15'});
% gDelay.facet_wrap(dat.subj);
gRTcon.stat_density();
gRTcon.axe_property('xlim', [0 0.8]);
gRTcon.set_color_options('map',[0.9765, 0.4510, 0.0157; 0.0863, 0.6000, 0.7804],'n_color',2,'n_lightness',1);
gRTcon.set_names('Row','','x','reaction time','LineStyle','','color','');
gRTcon.set_title(['density RT ' name]);
%gRTcon.set_text_options('base_size',12);
%gRTcon.facet_wrap(dat.subj,'ncols',5)
%gRTcon.fig(dat.subj);
gRTcon.draw();

% gRTcon.export('file_name',['RT_' name],...
%     'export_path',current_folder,...
%     'file_type',current_file_type);
%%

% %% RT: jitterplot + lines for condition comparison in RT
% 
% % figure;
% % gRTcon = gramm('y',dat.RT,'x',dat.choice,'color',dat.target_selected,'column',dat.effector,'subset', dat.success & ~dat.unrealRT);
% % gRTcon.geom_jitter('dodge',0.5);
% % gRTcon.set_color_options('lightness',80,'chroma',10);
% % gRTcon.set_names('Row','','x','reaction time','LineStyle','','color','');
% % gRTcon.set_title('Reaction Time');
% % gRTcon.no_legend();
% % 
% % gRTcon.update();
% % gRTcon.stat_summary('geom',{'point', 'errorbar','line'},'dodge',0.5);
% % %gRTcon.set_color_options('map',[0.9765    0.4510    0.0157; 0.0863    0.6000    0.7804],'n_color',2,'n_lightness',1);
% % gRTcon.set_color_options();
% % gRTcon.draw;

%% RT: barplot conditions
clear gRTcon
figure ('Position', [100 100 900 600],'Name',['mean RT  of ' name]);
gRTcon = gramm('y',dat.RT,'x',dat.target_selected,'color',dat.choice,'lightness',dat.effector,'subset', dat.success & ~dat.unrealRT);
gRTcon.stat_summary('geom',{'bar', 'black_errorbar'},'setylim',true);
gRTcon.set_names('Row','','x','reaction time','lightness','effector','color','choice');
gRTcon.set_title(['mean RT of ' name]);
gRTcon.set_color_options('map',[0.9765    0.4510    0.0157; 0.9882    0.6392    0.3529; 0.0863    0.6000    0.7804;0.4078    0.7961    0.9333],'n_color',2,'n_lightness',2,'legend','expand');
gRTcon.set_text_options('base_size',12);
gRTcon.draw();

%% RT: in delays density
clear gRTdel
figure ('Position', [100 100 900 600],'Name',['density RT per delay of ' name]);
gRTdel(1,1) = gramm('x',dat.RT,'color',dat.delay,'subset', dat.success & ~dat.unrealRT);
gRTdel(1,1).set_order_options('color',{'3' '6' '9' '12' '15'});
% gDelay.facet_wrap(dat.subj);
gRTdel(1,1).stat_density();
gRTdel(1,1).axe_property('xlim', [0 0.8]);
gRTdel(1,1).set_names('Row','','x','reaction time','color','delay');
gRTdel(1,1).set_title(['density RT per delay of ' name]);
gRTdel(1,1).set_text_options('base_size',12);
gRTdel.draw;

%% RT per Delay
clear gRTdel
figure ('Position', [100 100 900 600],'Name',['RT per Delay of ' name]);
gRTdel = gramm('y',dat.RT,'x',dat.delay,'subset', dat.success & ~dat.unrealRT);
gRTdel.geom_jitter();
gRTdel.set_color_options('lightness',80,'chroma',0);
gRTdel.set_order_options('x',{'3' '6' '9' '12' '15'},'color',{'3' '6' '9' '12' '15'});
gRTdel.set_names('column','','x','delay','color','delay');
gRTdel.set_title(['RT per Delay of ' name]);
gRTdel.set_text_options('base_size',12);

gRTdel.update('color',dat.delay);
gRTdel.set_color_options();
gRTdel.stat_summary('geom',{'point' 'errorbar'});
gRTdel.set_names('column','','x','delay','color','delay','y','RT');
gRTdel.draw();

%% RT per delay main effects
clear gRTdel
figure ('Position', [100 100 1600 1000],'Name',['RT HF of ' name]);
gRTdel(1,1) = gramm('y',dat.RT,'x',dat.delay,'color',dat.effector,'subset', dat.success & ~dat.unrealRT);
gRTdel(1,1).stat_summary('geom',{'line', 'point', 'errorbar'});
%gRTdel(1,1).geom_jitter();
%gRTdel(1,1).set_color_options('lightness',80,'chroma',0)
gRTdel(1,1).set_order_options('x',{'3' '6' '9' '12' '15'});
gRTdel(1,1).set_title(['per effector']);
gRTdel(1,1).set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.3804    0.8902    0.5412; 0.8431, 0.0980, 0.1098;0.9373    0.4745    0.4784],'n_color',2,'n_lightness',2);
%gRTdel(1,1).set_text_options('base_size',12);
gRTdel(1,1).set_names('column','','x','delay','color','','y','RT');


gRTdel(1,2) = gramm('y',dat.RT,'x',dat.delay,'color',dat.choice,'subset', dat.success & ~dat.unrealRT);
gRTdel(1,2).stat_summary('geom',{'line', 'point', 'errorbar'});
%gRTdel(1,2).geom_jitter();
%gRTdel(1,2).set_color_options('lightness',80,'chroma',0)
gRTdel(1,2).set_order_options('x',{'3' '6' '9' '12' '15'});
gRTdel(1,2).set_title(['per choice']);
gRTdel(1,2).set_color_options('map',[0.9765, 0.4510, 0.0157; 0.0863, 0.6000, 0.7804],'n_color',2,'n_lightness',1);
%gRTdel(1,2).set_text_options('base_size',12);
gRTdel(1,2).set_names('column','','x','delay','color','','y','RT');


gRTdel(1,3) = gramm('y',dat.RT,'x',dat.delay,'color',dat.target_selected,'subset', dat.success & ~dat.unrealRT);
gRTdel(1,3).stat_summary('geom',{'line', 'point', 'errorbar'});
gRTdel(1,3).set_order_options('x',{'3' '6' '9' '12' '15'});
gRTdel(1,3).set_names('column','','x','delay','color','');
gRTdel(1,3).set_title(['per side']);
gRTdel(1,3).set_names('column','','x','delay','color','','y','RT');

gRTdel.axe_property('Ylim',[0.2 0.6],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
gRTdel.set_title(['RT of ' name]);
gRTdel.draw();
%% RT per side first order interaction
clear gRTdel
figure ('Position', [100 100 1600 1000],'Name',['RT of ' name]);
gRTdel(1,1) = gramm('y',dat.RT,'x',dat.delay,'color',dat.target_selected,'subset', dat.success & ~dat.unrealRT & dat.effector == 'reach');
gRTdel(1,1).stat_summary('geom',{'line', 'point', 'errorbar'});
gRTdel(1,1).set_order_options('x',{'3' '6' '9' '12' '15'});
gRTdel(1,1).set_names('column','','x','delay','color','');
gRTdel(1,1).set_title(['for reach']);
gRTdel(1,1).set_names('column','','x','delay','color','','y','RT');

gRTdel(1,2) = gramm('y',dat.RT,'x',dat.delay,'color',dat.target_selected,'subset', dat.success & ~dat.unrealRT & dat.effector == 'saccade');
gRTdel(1,2).stat_summary('geom',{'line', 'point', 'errorbar'});
gRTdel(1,2).set_order_options('x',{'3' '6' '9' '12' '15'});
gRTdel(1,2).set_names('column','','x','delay','color','');
gRTdel(1,2).set_title(['for saccade']);
gRTdel(1,2).set_names('column','','x','delay','color','','y','RT');

gRTdel.axe_property('Ylim',[0.2 0.6],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
gRTdel.set_title(['RT per side of ' name]);
gRTdel.draw();

%% RT per side first order interaction

clear gRTdel
figure ('Position', [100 100 1600 1000],'Name',['RT of ' name]);
gRTdel(1,1) = gramm('y',dat.RT,'x',dat.delay,'color',dat.choice,'subset', dat.success & ~dat.unrealRT & dat.effector == 'reach');
gRTdel(1,1).stat_summary('geom',{'line', 'point', 'errorbar'});
%gRTdel(1,1).geom_jitter();
%gRTdel(1,1).set_color_options('lightness',80,'chroma',0)
gRTdel(1,1).set_order_options('x',{'3' '6' '9' '12' '15'});
gRTdel(1,1).set_title(['for reach']);
gRTdel(1,1).set_color_options('map',[0.9765, 0.4510, 0.0157; 0.0863, 0.6000, 0.7804],'n_color',2,'n_lightness',1);
gRTdel(1,1).set_text_options('base_size',12);
gRTdel(1,1).set_names('column','','x','delay','color','','y','RT');


gRTdel(1,2) = gramm('y',dat.RT,'x',dat.delay,'color',dat.choice,'subset', dat.success & ~dat.unrealRT & dat.effector == 'saccade');
gRTdel(1,2).stat_summary('geom',{'line', 'point', 'errorbar'});
%gRTdel(1,2).geom_jitter();
%gRTdel(1,2).set_color_options('lightness',80,'chroma',0)
gRTdel(1,2).set_order_options('x',{'3' '6' '9' '12' '15'});
gRTdel(1,2).set_title(['for saccade']);
gRTdel(1,2).set_color_options('map',[0.9765, 0.4510, 0.0157; 0.0863, 0.6000, 0.7804],'n_color',2,'n_lightness',1);
gRTdel(1,2).set_text_options('base_size',12);
gRTdel(1,2).set_names('column','','x','delay','color','','y','RT');



gRTdel.axe_property('Ylim',[0.2 0.6],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
gRTdel.set_title(['RT choice vs. instructed of ' name]);
gRTdel.draw();


%% 3 way interaction 1
clear gRTdel
figure ('Position', [100 100 1600 1000],'Name',['RT of ' name]);
gRTdel(1,1) = gramm('y',dat.RT,'x',dat.delay,'color',dat.target_selected,'row',dat.effector,'column',dat.choice,'subset', dat.success & ~dat.unrealRT);
gRTdel(1,1).stat_summary('geom',{'line', 'point', 'errorbar'});
gRTdel(1,1).set_order_options('x',{'3' '6' '9' '12' '15'});
gRTdel(1,1).set_names('column','','x','delay','color','');
gRTdel(1,1).set_title(['for reach']);
gRTdel(1,1).set_names('column','','x','delay','color','','y','RT','row','','column','');


gRTdel.axe_property('Ylim',[0.2 0.6],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
gRTdel.set_title(['RT 3-way per side for ' name]);
gRTdel.draw();

%% 3 way interaction 2

clear gRTdel
figure ('Position', [100 100 1600 1000],'Name',['RT of ' name]);
gRTdel(1,1) = gramm('y',dat.RT,'x',dat.delay,'color',dat.choice,'row',dat.effector,'column',dat.target_selected,'subset', dat.success & ~dat.unrealRT);
gRTdel(1,1).stat_summary('geom',{'line', 'point', 'errorbar'});
%gRTdel(1,1).geom_jitter();
%gRTdel(1,1).set_color_options('lightness',80,'chroma',0)
gRTdel(1,1).set_order_options('x',{'3' '6' '9' '12' '15'});
gRTdel(1,1).set_title(['per choice']);
gRTdel(1,1).set_color_options('map',[0.9765, 0.4510, 0.0157; 0.0863, 0.6000, 0.7804],'n_color',2,'n_lightness',1);
%gRTdel(1,1).set_text_options('base_size',12);
gRTdel(1,1).set_names('column','','x','delay','color','','y','RT');

gRTdel.axe_property('Ylim',[0.2 0.6],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
gRTdel.set_title(['RT 3-way choi vs. instr for ' name]);
gRTdel.draw();

%% RT over time
clear gRTtime
figure ('Position', [100 100 1600 1000],'Name',['RT over time of ' name]);
gRTtime(1,1) = gramm('x',dat.RT,'color',dat.run,'row',dat.effector,'subset',dat.success & ~dat.unrealRT);
gRTtime(1,1).stat_density();
gRTtime(1,1).set_names('row','','x','reaction time','color','run');
gRTtime(1,1).set_title(['by run']);
gRTtime(1,1).set_text_options('base_size',12);

gRTtime(1,2) = gramm('x',dat.RT,'linestyle',dat.session,'color',dat.effector,'row',dat.effector,'subset',dat.success & ~dat.unrealRT);
gRTtime(1,2).stat_density();
gRTtime(1,2).set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
gRTtime(1,2).set_names('Row','','x','reaction time','linestyle','session');
gRTtime(1,2).set_title(['by session']);
gRTtime(1,2).set_text_options('base_size',12);

gRTtime.set_title(['RT over time of ' name]);
gRTtime.draw;



%% ++++++++++++++++++++++ Choice Bias ++++++++++++++++++

%cb = (sum(dat.target_selected == 'right') - sum(dat.target_selected == 'left')) / (sum(dat.target_selected == 'right') + sum(dat.target_selected == 'left'));

dat.right_selected_choice = (dat.target_selected == 'right') & (dat.choice == 'choice') & dat.success;
dat.left_selected_choice = (dat.target_selected  == 'left') & (dat.choice == 'choice') & dat.success;


func = @(r,l) 100*( (sum(r)) / (sum(r|l)) );

cb = rowfun(func,dat,'InputVariables',{'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'effector', 'session', 'run'},'OutputVariableNames','choice_bias');
cb_sesh = rowfun(func,dat,'InputVariables',{'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'effector', 'session'},'OutputVariableNames','choice_bias');

cb_ges = rowfun(func,dat,'InputVariables',{'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'effector'},'OutputVariableNames','choice_bias');


%% CB: run

clear gCBtime
figure ('Position', [100 100 900 600],'Name',['Choice Bias per run of ' name]);
gCBtime = gramm('x',cb.run,'y',cb.choice_bias);
gCBtime.stat_glm('distribution', 'normal');
%gCBtime.stat_summary('geom','line')
%gCBtime.stat_summary('geom','point')
gCBtime.facet_grid([],cb.effector);
gCBtime.set_color_options('lightness',80,'chroma',0);%,'chroma_range',[80 40]);
gCBtime.geom_hline('yintercept',50,'style','k--');
gCBtime.set_names('x','run','y','proportion right choices in %','column','','linestyle','session');
gCBtime.set_title(['Choice Bias per run of ' name]);
gCBtime.axe_property('Ylim',[0 100],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
gCBtime.set_text_options('base_size',12);

gCBtime.update('color',cb.effector,'linestyle',cb.session);
gCBtime.geom_line();
gCBtime.geom_point();
gCBtime.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');


gCBtime.draw;
%% CB session
clear gCBtimeR
figure ('Position', [100 100 900 600],'Name',['Choice Bias per session of ' name]);
gCBtimeR = gramm('x',cb_sesh.session,'y',cb_sesh.choice_bias,'color',cb_sesh.effector,'column',cb_sesh.effector,'label',cb_sesh.GroupCount);
%gcb_seshtime.stat_glm('distribution', 'normal');
%gcb_seshtime.stat_summary('geom','line')
%gcb_seshtime.stat_summary('geom','point')
gCBtimeR.geom_bar();
gCBtimeR.geom_label('VerticalAlignment','middle','HorizontalAlignment','center','BackgroundColor','w','Color','k');
gCBtimeR.set_color_options('lightness',80,'chroma',0);%,'chroma_range',[80 40]);
gCBtimeR.geom_hline('yintercept',50,'style','k--');
gCBtimeR.set_names('x','session','y','% right choices','column','');
gCBtimeR.set_title(['Choice Bias per session of ' name]);
gCBtimeR.axe_property('Ylim',[0 100],'Ygrid','on','GridColor',[0.5 0.5 0.5]);

%gcb_seshtime.update('color',cb_sesh.effector,'linestyle',cb_sesh.session)

gCBtimeR.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
gCBtimeR.set_text_options('base_size',12);

gCBtimeR.draw;


%% cb overall
clear gCBges
figure ('Position', [100 100 900 600],'Name',['Choice Bias overall of ' name]);
gCBges = gramm('x',(cb_ges.effector),'y',cb_ges.choice_bias,'label',cb_ges.GroupCount,'color',cb_ges.effector);
gCBges.geom_bar();
gCBges.geom_label('VerticalAlignment','middle','HorizontalAlignment','center','BackgroundColor','w','Color','k');
gCBges.geom_hline('yintercept',50,'style','k--');
gCBges.set_names('x','','y','% right choices');
gCBges.set_title(['Choice Bias overall of ' name]);
gCBges.axe_property('Ylim',[0 100]);
gCBges.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
gCBges.set_order_options('x',{'reach' 'saccade'});
%gCBges.coord_flip();
gCBges.set_text_options('base_size',12);
gCBges.draw;




%% choice bias per delay
cb_del = rowfun(func,dat,'InputVariables',{'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'success','effector', 'delay'},'OutputVariableNames','choice_bias');

clear gCBdel
figure ('Position', [100 100 900 600],'Name',['Choice Bias per delay of ' name]);
gCBdel = gramm('x',cb_del.delay,'row',cb_del.effector,'y',cb_del.choice_bias,'color',cb_del.effector,'label',cb_del.GroupCount,'subset',cb_del.success);
gCBdel.geom_bar();
gCBdel.geom_label('VerticalAlignment','middle','HorizontalAlignment','center','BackgroundColor','w','Color','k');
gCBdel.geom_hline('yintercept',50,'style','k--');
gCBdel.set_names('x','delay','row','','Color','','y','% right choices');
gCBdel.set_title(['Choice Bias per delay of ' name]);
gCBdel.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
%gCBdel.axe_property('Ylim',[0 1])
gCBdel.axe_property('Ylim',[0 100]);
gCBdel.set_order_options('x',{'3' '6' '9' '12' '15'});
gCBdel.set_text_options('base_size',12);
gCBdel.draw;

%%  CB vs. deltaRT per run in session
func_RT_rl = @(RT,r,l) mean(RT(r)) - mean(RT(l));
dRT_rl = rowfun(func_RT_rl,dat,'InputVariables',{'RT' 'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'effector','session','run'},'OutputVariableNames','dRT');

clear gCBRT
figure ('Position', [100 100 900 600],'Name',['Choice Bias vs. dRT per run in session of ' name]);
gCBRT = gramm('x',cb.choice_bias,'y',dRT_rl.dRT,'color',cb.effector);
gCBRT.geom_point();
gCBRT.stat_glm();
gCBRT.geom_hline('yintercept',0,'style','k--');
gCBRT.set_names('x','% right choices','row','','y','f(x) = RT(right) - RT(left)','color','');
gCBRT.axe_property('Xlim',[0 100],'Ylim',[-0.2 0.2]);
gCBRT.set_title(['Choice Bias vs. dRT per run in session of ' name]);
gCBRT.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1);
gCBRT.set_text_options('base_size',12);
gCBRT.draw();


%% +++++++++++++++++++++++ errors ++++++++++++++++++++++++++++

% %% errors and delays
% 
% % Delay Errors relative to all
% err = table();
% err.delay = (unique(dat.delay));
% err.prob_err = NaN(length(err.delay),1);
% err.prob_delay = NaN(length(err.delay),1);
% 
% for i = 1:length(err.delay)
%  
%     err.prob_err(i)   = sum(~dat.success(dat.delay == err.delay(i))) / length(dat.delay) * 100;
%     err.prob_delay(i) = sum(dat.delay == err.delay(i))               / length(dat.delay) * 100;
% end
% 
% % Delay Errors relativ normalized
% 
% err_del = rowfun(@(s) sum(~s),dat,'InputVariables',{'success'},'GroupingVariable', {'delay'},'OutputVariableNames','err_per_del');
% err_del.err_normalized = err_del.err_per_del ./ err_del.GroupCount * 100;
% 
% % errors in delays
% clear gErrDel
% 
% figure;
% gErrDel(1,1) = gramm('x',err.delay,'y',err.prob_delay);%,'y',err.prob_delay);
% gErrDel(1,1).geom_bar();
% gErrDel(1,1).set_order_options('x',{'3' '6' '9' '12' '15'});
% gErrDel(1,1).set_color_options('chroma',0,'lightness',90)
% gErrDel(1,1).set_names('x','all (grey) + erroneous (red) delays','y','probability overall')
% gErrDel(1,1).set_title(['relative to all trials of ' name])
% gErrDel(1,1).axe_property('Ylim',[0 10],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
% 
% gErrDel(1,1).update('y',err.prob_err);
% gErrDel(1,1).geom_bar();
% 
% gErrDel(1,1).set_color_options('chroma',75)
% 
% 
% gErrDel(1,2) = gramm('x',err_del.delay,'y',err_del.err_normalized);
% gErrDel(1,2).geom_line();
% gErrDel(1,2).geom_point();
% gErrDel(1,2).set_order_options('x',{'3' '6' '9' '12' '15'});
% %gErrDel(1,2).set_color_options('chroma',0,'lightness',90)
% gErrDel(1,2).geom_hline('yintercept',mean(err_del.err_normalized),'style','k:');
% gErrDel(1,2).axe_property('Ylim',[0 25]);
% 
% gErrDel(1,2).set_names('x','erroneous delays','y','probability per group')
% gErrDel(1,2).set_title(['normalized with n per delay of ' name])
% gErrDel(1,2).set_color_options('chroma',75)
% 
% gErrDel.set_text_options('base_size',12);
% gErrDel.set_title('erroneous delays')
% gErrDel.draw;
% 
% %% Error over time
% 
% err_time = rowfun(@(x) sum(~x),dat,'InputVariables',{'success'},'GroupingVariable', {'effector', 'session', 'run'},'OutputVariableNames','n_error');
% err_time.err_prob = err_time.n_error./err_time.GroupCount * 100;
% 
% figure;
% gErrTime = gramm('x',err_time.run,'y',err_time.err_prob,'column',err_time.effector);
% gErrTime.stat_glm();
% gErrTime.set_color_options('lightness',80,'chroma',0)
% gErrTime.set_names('x','runs','y','probability errors per run in %','linestyle','Session','column','')
% gErrTime.axe_property('Ylim',[0 50],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
% gErrTime.set_title(['errors over time of ' name])
% 
% gErrTime.update('color',err_time.effector, 'linestyle',err_time.session)
% gErrTime.geom_line();
% gErrTime.geom_point();
% gErrTime.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
% 
% gErrTime.set_text_options('base_size',12);
% gErrTime.draw;
% 
