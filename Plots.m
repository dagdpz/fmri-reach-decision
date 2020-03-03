%% Plot stuff


load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\current_dat_file.mat','dat');

%dat(dat.subj == 'EVBO'|dat.subj == 'LIKU'|dat.subj == 'MABL'|dat.subj == 'MARO',:) = [];

dat(~(dat.subj == 'ANEL'),:) = [];

dat.unrealRT = dat.RT == -99 | dat.RT>dat.stateRT | dat.RT > 0.8;
alsoweird = (dat.stateRT -dat.RT) > 0.2 & dat.effector == 'saccade';
weirdos = dat(dat.unrealRT |alsoweird ,:);

dat.unrealRT = dat.unrealRT |alsoweird;
%         1566
%         1729
%         2231
%         2294
%         2937
%         3129
%         3819
%         3895
%         3917
%         4009
%         4064
%         4072
%% trial_type

dat.trial_type = strcat(cellstr(dat.effector),'_' ,cellstr(dat.choice),'_',cellstr(dat.target_selected));
dat.trial_type_del = strcat(cellstr(dat.effector),'_' ,cellstr(dat.choice),'_',cellstr(dat.target_selected),'_',cellstr(dat.delay));



%% RT

% RT in conditions
figure;
gRTcon = gramm('x',dat.RT,'color',dat.target_selected,'linestyle',dat.choice,'subset', dat.success & ~dat.unrealRT);
% gRTcon.set_order_options('x',{'3' '6' '9' '12' '15'});
gRTcon.facet_grid(dat.effector,[]);
% gDelay.facet_wrap(dat.subj);
gRTcon.stat_density();
gRTcon.axe_property('xlim', [0 0.8]);
gRTcon.set_color_options('map','brewer2')

gRTcon.set_names('Row','','x','reaction time','LineStyle','');
gRTcon.set_title('Reaction Time');
gRTcon.draw();

% RT in delays

figure;
gRTdel = gramm('x',dat.RT,'color',dat.delay,'subset', dat.success & ~dat.unrealRT);
gRTdel.set_order_options('color',{'3' '6' '9' '12' '15'});
gRTdel.facet_grid(dat.effector,[]);
% gDelay.facet_wrap(dat.subj);
gRTdel.stat_density();
gRTdel.axe_property('xlim', [0 0.8]);
gRTdel.set_names('Row','','x','reaction time','LineStyle','');
gRTdel.set_title('Reaction Time');
gRTdel.draw();

%% Choice Bias
%cb = (sum(dat.target_selected == 'right') - sum(dat.target_selected == 'left')) / (sum(dat.target_selected == 'right') + sum(dat.target_selected == 'left'));

dat.right_selected_choice = (dat.target_selected == 'right') & dat.choice == 'choice';
dat.left_selected_choice = (dat.target_selected  == 'left') & dat.choice == 'choice';


func = @(r,l) 100*((sum(r)-sum(l)) / (sum(r) + sum(l)));

cb = rowfun(func,dat,'InputVariables',{'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'effector', 'session', 'run'},'OutputVariableNames','choice_bias');
cb_ges = rowfun(func,dat,'InputVariables',{'right_selected_choice' 'left_selected_choice'},'GroupingVariable', {'effector'},'OutputVariableNames','choice_bias');


%%
clear gCBtime
figure;
gCBtime = gramm('x',cb.run,'y',cb.choice_bias);
gCBtime.stat_summary('geom','line')
gCBtime.stat_summary('geom','point')
gCBtime.facet_grid([],cb.effector)
gCBtime.set_color_options('lightness',[0])%,'chroma_range',[80 40]);
gCBtime.geom_hline('yintercept',0,'style','k--');
gCBtime.set_names('x','run','y','proportion right - left','column','','color','session');
gCBtime.set_title({'Choice Bias over time'});
gCBtime.axe_property('Ylim',[-100 100]);

gCBtime.update('color',cb.session)
gCBtime.geom_line();
gCBtime.geom_point();
gCBtime.set_color_options('lightness',[65])

gCBtime.draw;

%%
clear gCBges
figure;
gCBges = gramm('x',(cb.effector),'y',cb.choice_bias);
gCBges.stat_summary('geom','bar','setylim',true)
gCBges.geom_hline('yintercept',0,'style','k--');
gCBges.set_names('x','','y','proportion right minus left');
gCBges.set_title('Choice Bias overall');
gCBges.draw;


%% Delay Errors relative to all
err = table();
err.delay = (unique(dat.delay));
err.prob_err = NaN(length(err.delay),1);
err.prob_delay = NaN(length(err.delay),1);

for i = 1:length(err.delay)
 
    err.prob_err(i)   = sum(~dat.success(dat.delay == err.delay(i))) / length(dat.delay);
    err.prob_delay(i) = sum(dat.delay == err.delay(i))               / length(dat.delay);
end

%% Delay Errors relativ normalized

err_del = rowfun(@(s) sum(~s),dat,'InputVariables',{'success'},'GroupingVariable', {'delay'},'OutputVariableNames','err_per_del');
err_del.err_normalized = err_del.err_per_del ./ err_del.GroupCount * 100;
%% WHY NOT USING STAT_BIN????
clear gErrDel

figure;
gErrDel(1,1) = gramm('x',err.delay,'y',err.prob_delay)%,'y',err.prob_delay);
gErrDel(1,1).geom_bar();
gErrDel(1,1).set_order_options('x',{'3' '6' '9' '12' '15'});
gErrDel(1,1).set_color_options('chroma',0,'lightness',90)
gErrDel(1,1).set_names('x','all (grey) + erroneous (red) delays','y','probability overall')
gErrDel(1,1).set_title('relative to all trials')

gErrDel(1,1).update('y',err.prob_err);
gErrDel(1,1).geom_bar();

gErrDel(1,1).set_color_options('chroma',75)



gErrDel(1,2) = gramm('x',err_del.delay,'y',err_del.err_normalized);
gErrDel(1,2).geom_line();
gErrDel(1,2).geom_point();
gErrDel(1,2).set_order_options('x',{'3' '6' '9' '12' '15'});
%gErrDel(1,2).set_color_options('chroma',0,'lightness',90)
gErrDel(1,2).geom_hline('yintercept',mean(err_del.err_normalized),'style','k:');
gErrDel(1,2).axe_property('Ylim',[0 30]);

gErrDel(1,2).set_names('x','erroneous delays','y','probability per group')
gErrDel(1,2).set_title('relative to n per group')
gErrDel(1,2).set_color_options('chroma',75)

gErrDel.set_title('erroneous delays')
gErrDel.draw;

%%
err_time = rowfun(@(x) sum(~x),dat,'InputVariables',{'success'},'GroupingVariable', {'effector', 'session', 'run'},'OutputVariableNames','n_error');
err_time.err_prob = err_time.n_error./err_time.GroupCount;

figure;
gErrTime = gramm('x',err_time.run,'y',err_time.err_prob);
gErrTime.stat_summary();
%gErrTime.stat_bin('geom','bar','normalization','countdensity');
%gErrTime.axe_property('Ylim',[0 0.5])
gErrTime.draw

































%% sanity checks

figure; % stateRT vs. realRT
sRT = gramm('x',dat.stateRT, 'y', dat.RT, 'color', dat.choice, 'subset',~dat.unrealRT & ~('none'==dat.target_selected));
sRT.geom_point();
sRT.facet_grid(dat.effector,dat.target_selected);
sRT.set_names('x','state RT', 'y',' real RT','Column','','Row','','color','');
sRT.set_title('real RT vs. state RT');
sRT.draw;

%%
figure; 
SR = gramm('x',categorical(dat.success))%, 'color', dat.trial_type);
SR.stat_bin('normalization','probability');
SR.facet_wrap(dat.subj);
SR.draw;



%%
figure;

g3(1,1) = gramm('color', dat.target_selected,'x',dat.effector,'row',dat.delay,'column',dat.subj, 'subset',dat.choice == 'choice' & dat.success);
g3(1,1).stat_bin('geom','bar','normalization','probability');
%g3(1,1).facet_wrap(dat.subj);
g3(1,1).set_names('x','','y','proportion in %','Color','','row','','column','');
g3(1,1).set_title({'relative amount of left/right answers in choice trials'});

g3(1,1).draw;
%%


figure; %4 choice bias
g3(1,1) = gramm('x', dat.target_selected, 'subset', dat.target_selected ~= 'none' & dat.choice == 'choice' & dat.success);
g3(1,1).stat_bin('geom','bar','normalization','probability');
g3(1,1).facet_wrap(dat.effector,'ncols',2);
g3(1,1).set_names('x','','y','proportion in %','Color','','row','','column','');
g3(1,1).set_title({'relative amount of left/right answers in choice trials'});

g3(1,2) = gramm('x',categorical(dat.target_selected), 'color', dat.choice, 'subset', dat.target_selected ~= 'none' & dat.success);
g3(1,2).stat_bin('geom','bar','normalization','count');
g3(1,2).facet_wrap(dat.effector,'ncols',2);
g3(1,2).set_names('x','','y','count','Color','','row','','column','');
g3(1,2).set_title({'Is there an equal amount of N in each condition?'});

g3(2,2) = gramm('x',dat.effector, 'color', dat.choice, 'subset', dat.target_selected ~= 'none' & dat.success);
g3(2,2).stat_bin('geom','bar','normalization','count');
g3(2,2).set_names('x','','y','count','Color','','row','','column','');
g3(2,2).set_title({'How many trials in choice vs. instructed?'});

g3.set_title({'Choice Bias for successful trials'})

g3.draw;









%%



% RT AND DELAY
figure;
gDelay=gramm('x',dat.RT,'color',dat.delay,'subset', dat.success & dat.RT > 0 & ~dat.unrealRT);
gDelay.set_order_options('color',{'3' '6' '9' '12' '15'});
gDelay.facet_wrap(dat.trial_type);
gDelay.stat_density();
gDelay.axe_property('xlim', [0.2 0.8])
gDelay.set_names('Column','','x','reaction time');
gDelay.set_title('Influence of delay on reaction time');
gDelay.draw();

% RT AND DELAY ( Saccade VS Reach )
figure;
gDelaySACDE=gramm('x',dat.stateRT,'y',dat.RT,'color', dat.subj,'subset', dat.success & ~dat.unrealRT);
% gDelaySACDE.set_order_options('x',{'3' '6' '9' '12' '15'});
%gDelaySACDE.facet_grid(dat.choice,dat.effector);
gDelaySACDE.facet_wrap(dat.effector);
gDelaySACDE.geom_point;
%gDelaySACDE.axe_property('ylim', [-2.7 0.6]);
gDelaySACDE.set_names('Column','','x','stateRT','y','realRT');
gDelaySACDE.set_title('Influence of effector on reaction time');
gDelaySACDE.draw();


% Right VS Left hand
figure;
gHand=gramm('x',dat.target_selected,'y',dat.RT,'color',dat.effector,'subset', ~('none'==dat.target_selected) & ~dat.unrealRT);
gHand.facet_grid([],dat.choice);
gHand.facet_wrap(dat.subj);
gHand.stat_boxplot();
gHand.set_names('Column','','x','target choice','y','reaction time');
% gHand.axe_property('ylim',[0.2 0.5]);
gHand.set_title('Influence of target choice on reaction time');
gHand.draw();

% EFFECTOR CHOICE 
figure;
gEffector=gramm('x',dat.effector,'y',dat.RT,'subset',dat.choice=='choice' & ~dat.unrealRT);
gEffector.facet_grid([],[]);
gEffector.stat_boxplot();
gEffector.set_names('Column','','x','effector','y','reaction time');
% gEffector.axe_property('ylim',[0.2 0.7]);
gEffector.set_title('Influence of effector choice on reaction time');
gEffector.draw();

% EFFECTOR CHOICE AND INSTRUCTION
figure;
gEffectorChoice=gramm('x',dat.effector,'y',dat.RT,'color',dat.choice,'subset', ~dat.unrealRT);
gEffectorChoice.facet_grid([],[]);
gEffectorChoice.stat_boxplot();
gEffectorChoice.set_names('Column','decision','x','Effector','y','reaction time');
gEffectorChoice.axe_property('ylim',[0.2 0.7]);
gEffectorChoice.set_title('Influence of effector choice and effector on reaction time');
gEffectorChoice.draw();

% Choice bias
figure;
gChoiceBias=gramm('x',dat.target_selected,'subset',dat.choice=='choice' & dat.target_selected~='none' & ~dat.unrealRT & dat.success);
% gChoiceBias.facet_grid([],[]);
gChoiceBias.facet_wrap(dat.effector,'ncols',2);
gChoiceBias.stat_bin('geom','bar','normalization','probability');
gChoiceBias.set_names('x','','y','proportion in %','Color','','row','','column','');
% gChoiceBias.axe_property('ylim',[0 0.7]);
gChoiceBias.set_title('Choice bias');
gChoiceBias.draw();

%     g3(1,1) = gramm('x', dat.target_selected, 'subset', dat.target_selected ~= 'none' & dat.choice == 'choice' & dat.success);
%     g3(1,1).stat_bin('geom','bar','normalization','probability');
%     g3(1,1).facet_wrap(dat.effector,'ncols',2);
%     g3(1,1).set_names('x','','y','proportion in %','Color','','row','','column','');
%     g3(1,1).set_title({'relative amount of left/right answers in choice trials'});



figure;
gChoiceBias=gramm('x',categorical(dat.success),'color',dat.subj);
% gChoiceBias.facet_grid([],[]);
gChoiceBias.facet_wrap(dat.session);
gChoiceBias.stat_bin('normalization','probability');
%gChoiceBias.set_names('x','','y','proportion in %','Color','','row','','column','');
% gChoiceBias.axe_property('ylim',[0 0.7]);
%gChoiceBias.set_title('Choice bias');
gChoiceBias.draw();













% figure;
% gEffector=gramm('x',dat.effector,'y',dat.RT)
% gEffector.facet_grid([],[])
% gEffector.stat_boxplot()
% gEffector.set_names('Column','','x','Effector','y','reaction time')
% gEffector.axe_property('ylim',[0 0.9])
% gEffector.set_title('Influence of effector choice on reaction time')
% gEffector.draw()

% COMPARISON OF ERROR RATE BETWEEN SACCADE & REACH
% gError=gramm('x',dat.target_selected,'y',dat.success,'color',dat.effector)
% gError.facet_grid([],[])
% gError.stat_boxplot()
% gError.set_names('Column','','x','target','y','success')
% gError.axe_property()
% gError.set_title('Error rate saccade vs reach')
% gError.draw()

% figure;
% gDelayChoice=gramm('x',dat.RT,'y',dat.delay,'color', dat.subj,'subset', ~('none'==dat.target_selected) & dat.choice ~= 'instructed')
% gDelayChoice.set_order_options('y',{'3' '6' '9' '12' '15'})
% gDelayChoice.facet_grid(dat.target_selected,dat.effector)
% gDelayChoice.stat_density()
% gDelayChoice.set_names('Column','','x','delay','y','reaction time')
% gDelayChoice.set_title('Influence of choice on reaction time')
% gDelayChoice.draw()

% Instructed VS Choice
% figure;
% gChoice=gramm('x',dat.choice,'y',dat.RT,'subset', ~('none'==dat.target_selected))
% gChoice.facet_grid(dat.target_selected,dat.effector)
% gChoice.stat_boxplot()
% gChoice.set_names('Column','session','x','Decision','y','reaction time')
% gChoice.set_title('Influence of free choice on reaction time')
% gChoice.draw()