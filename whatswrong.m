% Check all plots
cc;

load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\current_dat_file.mat')
load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\current_trial_file.mat')

%% check for weird trials

dat.noRT = dat.RT == -99;
dat.biggerRT = dat.RT>dat.stateRT;
dat.bimax = dat.RT > 0.8;
dat.bidiff = (dat.stateRT -dat.RT) > 0.1 & dat.effector == 'saccade';

dat.unrealRT = dat.noRT | dat.biggerRT | dat.bimax | dat.bidiff;
we_dat = dat(dat.unrealRT,:);

[trial(:).unrealRT] = disperse(dat.unrealRT);


we_tr = trial(dat.unrealRT);

for i = 1:length(we_tr)
    
    we_tr(i).unrealRT = we_dat.unrealRT(i);
    
    we_tr(i).noRT = we_dat.noRT(i);    
    we_tr(i).biggerRT = we_dat.biggerRT(i);
    we_tr(i).bimax = we_dat.bimax(i);
    we_tr(i).bidiff = we_dat.bidiff(i);
 
    
end

    


%% save now all weird saccade files

% save('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\weirdos_trial.mat','we_tr')
% save('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\weirdos_dat.mat','we_dat')
% 

%%
load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\weirdos_trial.mat')
load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\weirdos_dat.mat')

trial = we_tr;
dat = we_dat;

clear we_tr;
clear we_dat;

%% which weirdo trials

%trial = trial([trial.biggerRT]);

% 
  trial = trial((dat.stateRT -dat.RT) > 0.2 & dat.effector == 'saccade');
  dat = dat((dat.stateRT -dat.RT) > 0.2 & dat.effector == 'saccade',:);


%% plot it
save('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\current_wei_file.mat','trial');

close all
frd_browse_and_detect('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\current_wei_file.mat',0,1,1,1,1)

%% compare with duration


figure ('Position', [100 100 800 500],'Name','comparison of both RT measures');
gCompRT = gramm('x',dat.RT,'y',dat.mov_dur,'column',dat.effector,'color',(dat.stateRT-dat.RT) > 0.2, 'subset',dat.success & dat.RT > -98);
%gCompRT.set_color_options('map',[0.9765, 0.4510, 0.0157; 0.0863, 0.6000, 0.7804],'n_color',2,'n_lightness',1);
gCompRT.geom_point();
gCompRT.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1,'legend','merge');
gCompRT.set_text_options('base_size',12);
%gCompRT.set_names('x','state RT','y','trajectory RT','color','','column','');
gCompRT.set_title('comparison of both RT measures');
gCompRT.draw();
 
%%



%%
for k = 1:length(trial)
    
    trial(k).states = unique(trial(k).state,'stable')'; % now trial.states includes all states
    
    indi = logical([1 (diff(trial(k).state) ~= 0)']);
    trial(k).states_onset = trial(k).tSample_from_time_start(indi)';
    
end

%%


% ++++ SACCADES ++++
out = em_saccade_blink_detection(trial(k).tSample_from_time_start,trial(k).x_eye,trial(k).y_eye,...
    'frd_em_custom_settings_humanUMGscanner60Hz.m');%% add problematic cases
mov_onset = [out.sac_onsets];
in = find((mov_onset > trial(k).states_onset(trial(k).states==9)) & ... % all onsets occuring after Tar_Aqu state
    (mov_onset < trial(k).states_onset(trial(k).states==50)));       % all onsets occuring before ITI state
in = in(1);


[dat.RT(k) out.sac_onsets(in) out.sac_dur(in) out.sac_amp(in)]


%% caluclation succesful trials

pay = rowfun(@(x) sum(x)/length(x),dat,'InputVariables',{'success'},'GroupingVariable', {'subj','session'},'OutputVariableNames','perc');
pay.money = zeros(length(pay.perc),1);
pay.money(pay.perc >= 0.84) = 4;
pay.money(pay.perc >= 0.89) = 7;
pay.money(pay.perc >= 0.94) = 10;


tabulate(pay.money)
A = table();
A.pSession(1) = mean(pay.money);
A.pSubject(1) = mean(pay.money)*3;
A.pSessionIfReward(1) = mean(pay.money(pay.perc >=0.85))

gm = rowfun(@sum,pay,'InputVariables',{'money'},'GroupingVariable', {'subj'},'OutputVariableNames','money');

mean(gm.money)



figure;
g = gramm('x',pay.perc,'subset',pay.perc>=0.85)
g.axe_property('XLim',[0.85 1]);
g.stat_bin('nbins',12);
g.draw;

figure;
g = gramm('x',pay.perc)
g.axe_property('XLim',[0.79 0.99]);
g.stat_bin();
g.draw;






