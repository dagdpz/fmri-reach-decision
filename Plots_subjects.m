%% PLots for subjets
clear all
% Plot behavioral analysis across subjects

load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\current_dat_file.mat','dat');

% dat(dat.subj == 'CAST'|...
%     dat.subj == 'EVBO'|...
%     dat.subj == 'JAGE'|...
%     dat.subj == 'LEKU'|...
%     dat.subj == 'LIKU'|...    
%     dat.subj == 'MABA'|...    
%     dat.subj == 'MABL'|...    
%     dat.subj == 'MARO'|...    
%     dat.subj == 'PASC',:) = [];

dat(~dat.subj == 'FARA',:) = [];

dat.unrealRT = dat.RT == -99 | dat.RT>dat.stateRT | dat.RT > 0.8;
alsoweird = (dat.stateRT -dat.RT) > 0.1 & dat.effector == 'saccade';
weirdos = dat(dat.unrealRT |alsoweird ,:);

dat.unrealRT = dat.unrealRT |alsoweird;

dat(dat.unrealRT,:) = [];




% choice
%gCompRT.set_color_options('map',[0.9765, 0.4510, 0.0157; 0.0863, 0.6000, 0.7804],'n_color',2,'n_lightness',1);

% effector
%gCBtime.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
%gAmount.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.3804    0.8902    0.5412; 0.8431, 0.0980, 0.1098;0.9373    0.4745    0.4784],'n_color',2,'n_lightness',2);

% trial_type

dat.trial_type = strcat(cellstr(dat.effector),'_' ,cellstr(dat.choice),'_',cellstr(dat.target_selected));
dat.trial_type_del = strcat(cellstr(dat.effector),'_' ,cellstr(dat.choice),'_',cellstr(dat.target_selected),'_',cellstr(dat.delay));



%% ++++++++++++++++++++++++ RT +++++++++++++++++++++++++++++++
%% RT:density conditions
clear gRTcon
% RT in conditions
figure;
gRTcon = gramm('x',dat.RT,'color',dat.choice,'row',dat.effector,'linestyle',dat.target_selected,'subset', dat.success & ~dat.unrealRT);
% gRTcon(1,1).set_order_options('x',{'3' '6' '9' '12' '15'});
% gDelay.facet_wrap(dat.subj);
gRTcon.stat_density();
gRTcon.axe_property('xlim', [0 0.8]);
gRTcon.set_color_options('map',[0.9765    0.4510    0.0157; 0.0863    0.6000    0.7804],'n_color',2,'n_lightness',1);
gRTcon.set_names('Row','','x','reaction time','LineStyle','','color','');
gRTcon.set_title(['Reaction Time of ' prot(i).name]);
%gRTcon.set_text_options('base_size',12);
gRTcon.fig(dat.subj);
gRTcon.draw();
% gRTcon.export('file_name',['Reaction Time of ' prot(i).name],...
%     'export_path',['Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data' filesep prot(i).name],...
%     'file_type','pdf',...
%     'width',20,'height',12,'units','centimeters')

%% RT: jitterplot + lines for condition comparison in RT
% figure;
% gRTcon = gramm('y',dat.RT,'x',dat.choice,'color',dat.target_selected,'column',dat.effector,'subset', dat.success & ~dat.unrealRT);
% gRTcon.geom_jitter('dodge',0.5);
% gRTcon.set_color_options('lightness',80,'chroma',10);
% gRTcon.set_names('Row','','x','reaction time','LineStyle','','color','');
% gRTcon.set_title('Reaction Time');
% gRTcon.no_legend();
% 
% gRTcon.update();
% gRTcon.stat_summary('geom',{'point', 'errorbar','line'},'dodge',0.5);
% %gRTcon.set_color_options('map',[0.9765    0.4510    0.0157; 0.0863    0.6000    0.7804],'n_color',2,'n_lightness',1);
% gRTcon.set_color_options();
% gRTcon.draw;

%% RT: barplot conditions
figure;
gRTcon = gramm('y',dat.RT,'x',dat.target_selected,'color',dat.choice,'lightness',dat.effector,'subset', dat.success & ~dat.unrealRT);
gRTcon.stat_summary('geom',{'bar', 'black_errorbar'},'setylim',true);
gRTcon.set_names('Row','','x','reaction time','lightness','effector','color','choice');
gRTcon.set_title(['Reaction Time of ' prot(i).name]);
gRTcon.set_color_options('map',[0.9765    0.4510    0.0157; 0.9882    0.6392    0.3529; 0.0863    0.6000    0.7804;0.4078    0.7961    0.9333],'n_color',2,'n_lightness',2,'legend','expand');
gRTcon.set_text_options('base_size',12);
gRTcon.draw();

%% RT: in delays density
clear gRTdel
figure;
gRTdel(1,1) = gramm('x',dat.RT,'color',dat.delay,'row',dat.effector,'subset', dat.success & ~dat.unrealRT);
gRTdel(1,1).set_order_options('color',{'3' '6' '9' '12' '15'});
% gDelay.facet_wrap(dat.subj);
gRTdel(1,1).stat_density();
gRTdel(1,1).axe_property('xlim', [0 0.8]);
gRTdel(1,1).set_names('Row','','x','reaction time','color','delay');
gRTdel(1,1).set_title(['Reaction Time of ' prot(i).name]);
gRTdel(1,1).set_text_options('base_size',12);
gRTdel.draw;

%%
figure;
gRTdel = gramm('y',dat.RT,'x',dat.delay,'column',dat.effector,'subset', dat.success & ~dat.unrealRT);
gRTdel.geom_jitter();
gRTdel.set_color_options('lightness',80,'chroma',0)
gRTdel.set_order_options('x',{'3' '6' '9' '12' '15'},'color',{'3' '6' '9' '12' '15'});
gRTdel.set_names('column','','x','delay','color','delay');
gRTdel.set_title(['Reaction Time per Delay of ' prot(i).name]);
gRTdel.set_text_options('base_size',12);

gRTdel.update('color',dat.delay);
gRTdel.set_color_options();
gRTdel.stat_summary('geom',{'point' 'errorbar'});
gRTdel.set_names('column','','x','delay','color','delay','y','RT');
gRTdel.draw();


%% RT over time
figure;
gRTtime(1,1) = gramm('x',dat.RT,'color',dat.run,'row',dat.effector,'subset',dat.success & ~dat.unrealRT);
gRTtime(1,1).stat_density();
gRTtime(1,1).set_names('Row','','x','reaction time','color','run');
gRTtime(1,1).set_title(['RT by run of ' prot(i).name]);
gRTtime(1,1).set_text_options('base_size',12);

gRTtime(1,2) = gramm('x',dat.RT,'linestyle',dat.session,'color',dat.effector,'row',dat.effector,'subset',dat.success & ~dat.unrealRT);
gRTtime(1,2).stat_density();
gRTtime(1,2).set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
gRTtime(1,2).set_names('Row','','x','reaction time','linestyle','session');
gRTtime(1,2).set_title(['RT by session of ' prot(i).name]);
gRTtime(1,2).set_text_options('base_size',12);

gRTtime.set_title('RT over time');
gRTtime.draw;



%% ++++++++++++++++++++++ Choice Bias ++++++++++++++++++

%cb = (sum(dat.target_selected == 'right') - sum(dat.target_selected == 'left')) / (sum(dat.target_selected == 'right') + sum(dat.target_selected == 'left'));

dat.right_selected_choice = (dat.target_selected == 'right') & (dat.choice == 'choice') & dat.success;
dat.left_selected_choice = (dat.target_selected  == 'left') & (dat.choice == 'choice') & dat.success;


func = @(r,l) 100*((sum(r)-sum(l)) / (sum(r) + sum(l)));

cb = rowfun(func,dat,'InputVariables',{'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'effector', 'session', 'run'},'OutputVariableNames','choice_bias');
cb_sesh = rowfun(func,dat,'InputVariables',{'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'effector', 'session'},'OutputVariableNames','choice_bias');

cb_ges = rowfun(func,dat,'InputVariables',{'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'effector'},'OutputVariableNames','choice_bias');


%% CB: run

clear gCBtime
figure;
gCBtime = gramm('x',cb.run,'y',cb.choice_bias);
gCBtime.stat_glm('distribution', 'normal');
%gCBtime.stat_summary('geom','line')
%gCBtime.stat_summary('geom','point')
gCBtime.facet_grid([],cb.effector)
gCBtime.set_color_options('lightness',80,'chroma',0)%,'chroma_range',[80 40]);
gCBtime.geom_hline('yintercept',0,'style','k--');
gCBtime.set_names('x','run','y','proportion right minus left  in %','column','','linestyle','session');
gCBtime.set_title(['Choice Bias per Run of ' prot(i).name]);
gCBtime.axe_property('Ylim',[-100 100],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
gCBtime.set_text_options('base_size',12);

gCBtime.update('color',cb.effector,'linestyle',cb.session)
gCBtime.geom_line();
gCBtime.geom_point();
gCBtime.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');


gCBtime.draw;
%% CB session
clear gCBtimeR
figure;
gCBtimeR = gramm('x',cb_sesh.session,'y',cb_sesh.choice_bias,'color',cb_sesh.effector,'column',cb_sesh.effector,'label',cb_sesh.GroupCount);
%gcb_seshtime.stat_glm('distribution', 'normal');
%gcb_seshtime.stat_summary('geom','line')
%gcb_seshtime.stat_summary('geom','point')
gCBtimeR.geom_bar();
gCBtimeR.geom_label('VerticalAlignment','middle','HorizontalAlignment','center','BackgroundColor','w','Color','k');
gCBtimeR.set_color_options('lightness',80,'chroma',0)%,'chroma_range',[80 40]);
gCBtimeR.geom_hline('yintercept',0,'style','k--');
gCBtimeR.set_names('x','session','y','% left --------- % right','column','');
gCBtimeR.set_title(['Choice Bias per Session of ' prot(i).name]);
gCBtimeR.axe_property('Ylim',[-60 60],'Ygrid','on','GridColor',[0.5 0.5 0.5]);

%gcb_seshtime.update('color',cb_sesh.effector,'linestyle',cb_sesh.session)

gCBtimeR.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
gCBtimeR.set_text_options('base_size',12);

gCBtimeR.draw;


%% cb overall
clear gCBges
figure;
gCBges = gramm('x',(cb_ges.effector),'y',cb_ges.choice_bias,'label',cb_ges.GroupCount,'color',cb_ges.effector);
gCBges.geom_bar();
gCBges.geom_label('VerticalAlignment','middle','HorizontalAlignment','center','BackgroundColor','w','Color','k');
gCBges.geom_hline('yintercept',0,'style','k--');
gCBges.set_names('x','','y','% left ------------------ % right');
gCBges.set_title(['Choice Bias overall of ' prot(i).name]);
gCBges.axe_property('Ylim',[-60 60])
gCBges.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
gCBges.set_order_options('x',{'reach' 'saccade'});
%gCBges.coord_flip();
gCBges.set_text_options('base_size',12);
gCBges.draw;




%% choice bias per delay
cb_del = rowfun(func,dat,'InputVariables',{'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'success','effector', 'delay'},'OutputVariableNames','choice_bias');

figure;
gCBdel = gramm('x',cb_del.delay,'row',cb_del.effector,'y',cb_del.choice_bias,'color',cb_del.effector,'label',cb_del.GroupCount,'subset',cb_del.success);
gCBdel.geom_bar();
gCBdel.geom_label('VerticalAlignment','middle','HorizontalAlignment','center','BackgroundColor','w','Color','k');
gCBdel.geom_hline('yintercept',0,'style','k--');
gCBdel.set_names('x','delay','row','','Color','','y','% left ---------- % right');
gCBdel.set_title(['Choice Bias per Delay of ' prot(i).name]);
gCBdel.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
%gCBdel.axe_property('Ylim',[0 1])
gCBdel.axe_property('Ylim',[-60 60])
gCBdel.set_order_options('x',{'3' '6' '9' '12' '15'});
gCBdel.set_text_options('base_size',12);
gCBdel.draw;

%%  CB vs. deltaRT
func_RT_rl = @(RT,r,l) mean(RT(r)) - mean(RT(l));
dRT_rl = rowfun(func_RT_rl,dat,'InputVariables',{'RT' 'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'effector','session','run'},'OutputVariableNames','dRT');

figure;
gCBRT = gramm('x',cb.choice_bias,'y',dRT_rl.dRT,'color',cb.effector);
gCBRT.geom_point();
gCBRT.stat_glm();
gCBRT.geom_hline('yintercept',0,'style','k--');
gCBRT.set_names('x','CB % left ------------- % right','row','','y','f(x) = RT(right) - RT(left)');
gCBRT.axe_property('Xlim',[-100 100],'Ylim',[-0.2 0.2])
gCBRT.set_title(['Choice Bias vs. deltaRT per run of ' prot(i).name]);
gCBRT.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1);
gCBRT.set_text_options('base_size',12);
gCBRT.draw();



%% +++++++++++++++++++++++ errors ++++++++++++++++++++++++++++

%% errors and delays

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

figure;
gErrDel(1,1) = gramm('x',err.delay,'y',err.prob_delay);%,'y',err.prob_delay);
gErrDel(1,1).geom_bar();
gErrDel(1,1).set_order_options('x',{'3' '6' '9' '12' '15'});
gErrDel(1,1).set_color_options('chroma',0,'lightness',90)
gErrDel(1,1).set_names('x','all (grey) + erroneous (red) delays','y','probability overall')
gErrDel(1,1).set_title(['relative to all trials of ' prot(i).name])
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
gErrDel(1,2).set_title(['normalized with n per delay of ' prot(i).name])
gErrDel(1,2).set_color_options('chroma',75)

gErrDel.set_text_options('base_size',12);
gErrDel.set_title('erroneous delays')
gErrDel.draw;

%% Error over time

err_time = rowfun(@(x) sum(~x),dat,'InputVariables',{'success'},'GroupingVariable', {'effector', 'session', 'run'},'OutputVariableNames','n_error');
err_time.err_prob = err_time.n_error./err_time.GroupCount * 100;

figure;
gErrTime = gramm('x',err_time.run,'y',err_time.err_prob,'column',err_time.effector);
gErrTime.stat_glm();
gErrTime.set_color_options('lightness',80,'chroma',0)
gErrTime.set_names('x','runs','y','probability errors per run in %','linestyle','Session','column','')
gErrTime.axe_property('Ylim',[0 50],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
gErrTime.set_title(['errors over time of ' prot(i).name])

gErrTime.update('color',err_time.effector, 'linestyle',err_time.session)
gErrTime.geom_line();
gErrTime.geom_point();
gErrTime.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');

gErrTime.set_text_options('base_size',12);
gErrTime.draw;

