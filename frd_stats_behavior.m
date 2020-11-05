clear all
load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\current_dat_file.mat','dat');


% excluding criteria
dat.unrealRT = dat.RT == -99 | dat.RT > 0.8 | (dat.RT < 0.2 & dat.effector == 'saccade');
weirdos = dat(dat.unrealRT,:);

dat = dat(dat.success,:);
dat = dat(~dat.unrealRT,:);
dat.target_selected = removecats(dat.target_selected);


%%

lme = fitlme(dat,'RT ~ effector*choice*target_selected + (effector*choice*target_selected|subj) + (num_delay|subj)');

glme = fitglme(dat,'RT ~ effector*choice*target_selected + (effector*choice*target_selected|subj) + (num_delay|subj)','Distribution','InverseGaussian');
%%

lme_effects = fitlme(dat,'RT ~ effector*choice*target_selected + (effector*choice*target_selected|subj) + (num_delay|subj)','DummyVarCoding','effects');
