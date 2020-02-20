%% Plot stuff


load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\current_dat_file.mat','dat');


dat.unrealRT = dat.RT == -99 | dat.RT>dat.stateRT | dat.RT > 0.8;
weirdos = dat(dat.unrealRT,:);

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


%% sanity checks

figure; % stateRT vs. realRT
sRT = gramm('x',dat.stateRT, 'y', dat.RT, 'color', dat.choice, 'subset',~dat.unrealRT & ~('none'==dat.target_selected));
sRT.geom_point();
sRT.facet_grid(dat.effector,dat.target_selected);
sRT.set_names('x','state RT', 'y',' real RT','Column','','Row','','color','');
sRT.set_title('real RT vs. state RT');
sRT.draw;


figure;












% RT AND DELAY
figure;
gDelay=gramm('x',dat.RT,'color',dat.delay,'subset', dat.success & dat.RT > 0 & ~dat.unrealRT);
gDelay.set_order_options('color',{'3' '6' '9' '12' '15'});
%gDelay.facet_wrap(dat.subj);
gDelay.stat_density();
gDelay.axe_property('xlim', [0 0.9])
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

% Instruction VS Effector
figure;
gDelayIns=gramm('x',dat.RT,'color',dat.effector,'linestyle',dat.target_selected,'subset', dat.success & ~dat.unrealRT);
% gDelayIns.set_order_options('x',{'3' '6' '9' '12' '15'});
gDelayIns.facet_grid(dat.choice,[]);
% gDelay.facet_wrap(dat.subj);
gDelayIns.stat_density();
gDelayIns.axe_property('xlim', [0 1]);
gDelayIns.set_names('Column','','x','reaction time');
gDelayIns.set_title('Influence of instruction and effector on reaction time');
gDelayIns.draw();

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