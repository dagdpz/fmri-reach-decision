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
trial = trial([trial.bidiff]);
dat = dat(dat.bidiff,:);


% trial = trial((dat.stateRT -dat.RT) > 0.15 & dat.effector == 'saccade');
% dat = dat((dat.stateRT -dat.RT) > 0.15 & dat.effector == 'saccade',:);


%% plot it
save('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\current_wei_file.mat','trial');

close all
frd_browse_and_detect('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\current_wei_file.mat',0,1,1,1,1)



%%
frd_browse_and_detect('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\DAGU\20200120\DAGU_2020-01-20_10.mat',0,1,1,1,1)
%% add problematic cases


% save('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\still_problematic.mat','trial');



%% analyze it
for k = 1:length(trial)
    
    % Aus Trajectorys + Zeit (beide Auflösung: 1000Hz) die states onsets rausholen
    trial(k).states = unique(trial(k).state,'stable')'; % now trial.states includes all states
    
    indi = logical([1 (diff(trial(k).state) ~= 0)']);
    trial(k).states_onset = trial(k).tSample_from_time_start(indi)';
    
    % jeden trial auf 0 zurücksetzen
    trial(k).states_onset            = trial(k).states_onset            - trial(k).tSample_from_time_start(1); % setze die states_onsets auf "Null"(nicht wirklich, da irgendwie nicht wirklich 0)
    trial(k).tSample_from_time_start = trial(k).tSample_from_time_start - trial(k).tSample_from_time_start(1); % setze den Beginn des Trials auf 0
        
end




for k = 1:length(trial)
    if trial(k).effector == 3 && trial(k).completed == 1 %saccades
        
        out = em_saccade_blink_detection(trial(k).tSample_from_time_start,trial(k).x_eye,trial(k).y_eye,...
            'frd_em_custom_settings_humanUMGscanner60Hz.m');
        
        mov_onset = [out.sac_onsets];
        mov_onset = mov_onset(mov_onset > trial(k).states_onset(trial(k).states==9)); % all onsets occuring after Tar_Aqu state
        
        trial(k).tar_aqu = trial(k).states_onset(trial(k).states==9);

        
            if isempty(mov_onset) % if no saccade is detected after onset state 9
                %dat(k,1) = -99;
                trial(k).sac_onsets = [out.sac_onsets];
                trial(k).mov_onset = NaN;
            else
                %dat(k,1) = mov_onset(1) - trial(k).states_onset(trial(k).states==9); % calulate realRT 
                trial(k).sac_onsets = [out.sac_onsets];
                trial(k).mov_onset = mov_onset;
            end
        
    elseif trial(k).effector == 4 && trial(k).completed == 1% reaches
        % Interpolate to remove NaNs
        idx_nonnan = find(~isnan(trial(k).x_hnd));
        
        t = trial(k).tSample_from_time_start(idx_nonnan(1):idx_nonnan(end));
        x_ = trial(k).x_hnd(idx_nonnan(1):idx_nonnan(end));
        y_ = trial(k).y_hnd(idx_nonnan(1):idx_nonnan(end));
        
        x = interp1(t(~isnan(x_)),x_(~isnan(x_)),t);
        y = interp1(t(~isnan(x_)),y_(~isnan(y_)),t);
        
        
        out = em_saccade_blink_detection(t,x,y,...
            'frd_em_custom_settings_humanUMGscannerTouchscreen125Hz.m');
        
        mov_onset = [out.sac_onsets];
        mov_onset = mov_onset(mov_onset > trial(k).states_onset(trial(k).states==9)); % all onsets occuring after Tar_Aqu state
        
        trial(k).tar_aqu = trial(k).states_onset(trial(k).states==9);

        
            if isempty(mov_onset) % if no saccade is detected after onset state 9
                %dat(k,1) = -99;
                trial(k).sac_onsets = [out.sac_onsets];
                trial(k).mov_onset = NaN;
            else
                %dat(k,1) = mov_onset(1) - trial(k).states_onset(trial(k).states==9); % calulate realRT 
                trial(k).sac_onsets = [out.sac_onsets];
                trial(k).mov_onset = mov_onset;
            end
    end

end
