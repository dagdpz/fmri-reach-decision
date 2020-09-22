%% fdr_simulate_presentation_logic

% it needs the mat file from frd_create_condition order
if 1
clear all

% define
put_back = [3 5]; % Put back errors after how many trials [min max]?
performance = 0.90;
run_dur = 12*60; % secs per run
dur_trial = 18; % in secs, WITHOUT DELAY

% preallocate
sim_blocks = table();
x = 1;
time = 0;
run = 1;

load('Y:\MRI\Human\fMRI-reach-decision\Simulation\shuffled_conditions_S01.mat');
present.err_back = zeros(height(present),1);
present.order = [1:height(present)]';
save('Y:\MRI\Human\fMRI-reach-decision\Simulation\shuffled_conditions_S01_changed.mat');
%%

while run < 16
load('Y:\MRI\Human\fMRI-reach-decision\Simulation\shuffled_conditions_S01_changed.mat');

curr_trial  = present(counter,:);  
curr_trial.run = run;
%sim_blocks(counter,:) = present(counter,:);

success = rand(1) > (1 - performance);


if success
    % success
    curr_trial.aborted = false;
    % time
    curr_trial.length = dur_trial + curr_trial.delay;
    time = time +  curr_trial.length;
else 
    % abort
    curr_trial.aborted = true;
    % random time
    curr_trial.length = randperm((dur_trial + curr_trial.delay -2),1) + 2; %two seconds ITI are always there ;
    time = time +  curr_trial.length;
    
    % put error trial back into present
    err_back = randperm(length(put_back(1):put_back(2)),1) - 1 + put_back(1);
    present = [present(1:(counter + err_back - 1),:); ...
               present(counter,:); ...
               present((counter + err_back):end,:)];
           
    present.err_back(counter + err_back) = err_back;       
end



if time > run_dur
    
    curr_trial.aborted = true;
    curr_trial.length =  run_dur - (time - curr_trial.length); % last trial lasts exactly until end of run duration (12*60s)

% this part is commented, because in monkeypsych, errors caused because the
% run is over are not being put back. The reason is, that monkeypsych only
% knows, if the PREVIOUS trial was aborted, so in terms of putting errors
% back it can pnly act on the previous trial. This is not possible, if
% there did not start a next trial after the run is already finished. 
%     if success % if it was a sucessful trial, it was not put back into present yet
%         err_back = randperm(length(put_back(1):put_back(2)),1) - 1 + put_back(1);
%         present = [present(1:(counter + err_back - 1),:); ...
%                    present(counter,:); ...
%                    present((counter + err_back):end,:)];     
%                
%         present.err_back(counter + err_back) = err_back;    
%     end
    
    time = 0;
    run = run + 1;
     
end

% write it down
sim_blocks(counter,:) = curr_trial;
counter = counter +1;

save('Y:\MRI\Human\fMRI-reach-decision\Simulation\shuffled_conditions_S01_changed.mat','present','counter','sim_blocks');


end
end
%% how did putting errors back go - are they replaced further than intended by put_back?

take = sim_blocks.order(1);
order = sim_blocks.order;
err = struct();
k = 1;
where = [];

for i = 2:length(order) % starting from 2 because first trial could not have been a previous error
    
%     if sim_blocks.aborted(i) == 1 && sim_blocks.err_back(i) == 0
%         err(k).real_place = 0;
%         err(k).norm_place = 0;
%         k = k + 1 ;
%     end
%   
    % add next trial
    take = [take; order(i)];
    % see, if that trial has been there already
    where = find(take == order(i));
    
    if length(where) > 1
        err(k).real_place = where(end) - where(end-1);
        err(k).norm_place = sim_blocks.err_back(i);
        err(k).ind_sim_blocks = i;
        k = k + 1 ;
    end
end

err = struct2table(err);

% this tells you, which error trials are being put back further than with
% put_back intended, and by how many trials
[err.ind_sim_blocks(err.real_place > err.norm_place) (err.real_place(err.real_place > err.norm_place)-err.norm_place(err.real_place > err.norm_place))]


%% plots for simulated experiment
% now, errors are taken into account

if 0 % Plotting
    %% same plot logic as above, for comparison, only successful trials
    
    % these plots show, that there are still enough delays and conditions in
    % each block, even when taken performance into consideration
    
    
    % delays of only successful trials
    figure;
    ggSIMb = gramm('x',categorical(sim_blocks.delay),'color',categorical(sim_blocks.run),'subset',~sim_blocks.aborted);
    ggSIMb.stat_bin;
    ggSIMb.set_order_options('x',[3 4 5 1 2],'color',[1 8 9 10 11 12 13 14 15 2 3 4 5 6 7]);
    ggSIMb.set_names('x','Delays','color','simulated blocks');
    ggSIMb.set_title(['Delays in simulated blocks; onyl successful trials; performance = ' num2str(performance) '; error back after ' ...
        num2str(put_back(1)) ' to ' num2str(put_back(2)) ' trials']);
    %ggSIMb.facet_wrap(present.number);
    ggSIMb.draw;
    
    % conditions of only successful trials
    figure;
    ggSIMb2 = gramm('x',categorical(sim_blocks.comb),'color',categorical(sim_blocks.run),'subset',~sim_blocks.aborted);
    ggSIMb2.stat_bin;
    ggSIMb2.set_order_options('x',[1 2 5 6 3 4 7 8],'color',[1 8 9 10 11 12 13 14 15 2 3 4 5 6 7]);
    ggSIMb2.set_names('x','Conditions','color','simulated blocks');
    ggSIMb2.set_title(['Conditions in simulated blocks; only successful trials; performance = ' num2str(performance) '; error back after ' ...
        num2str(put_back(1)) ' to ' num2str(put_back(2)) ' trials']);
    %ggSIMb.facet_wrap(present.number);
    ggSIMb2.draw;
    
    
    % delays scattered in blocks, only successfull trials
    figure;
    ggSIMb3 = gramm('x',categorical(sim_blocks.delay));%,'color',present.comb);
    ggSIMb3.stat_bin;
    ggSIMb3.set_order_options('x',[3 4 5 1 2],'column',[1 8 9 10 11 12 13 14 15 2 3 4 5 6 7]);
    ggSIMb3.set_names('x','Delays','color','conditions','column','');
    ggSIMb3.facet_wrap(categorical(sim_blocks.run));
    ggSIMb3.set_title(['Delays in simulated blocks; only successful trials; performance = ' num2str(performance) '; error back after ' ...
        num2str(put_back(1)) ' to ' num2str(put_back(2)) ' trials']);
    ggSIMb3.draw;
    
    % conditions scattered in blocks, only successfull trials
    figure;
    ggSIMb4 = gramm('x',categorical(sim_blocks.comb),'color',categorical(sim_blocks.choice));
    ggSIMb4.stat_bin;
    ggSIMb4.set_order_options('x',[1 2 5 6 3 4 7 8],'color',[1 2 5 6 3 4 7 8],'column',[1 8 9 10 11 12 13 14 15 2 3 4 5 6 7]);
    ggSIMb4.set_names('x','conditions','color','','column','');
    ggSIMb4.facet_wrap(categorical(sim_blocks.run));
    ggSIMb4.set_title(['Conditions in simulated blocks; only successful trials; performance = ' num2str(performance) '; error back after ' ...
        num2str(put_back(1)) ' to ' num2str(put_back(2)) ' trials']);
    ggSIMb4.draw;
    
    
    %% what are the errors
    figure;
    ggSIMb5(1,1) = gramm('x', categorical(sim_blocks.eff), 'subset', sim_blocks.aborted & strcmp('choi',sim_blocks.choice));
    ggSIMb5(1,1).stat_bin;
    %ggSIMb5(1,1).set_order_options('color',[1 2 5 6 3 4 7 8]);
    ggSIMb5(1,1).set_names('x','effector','color','');
    ggSIMb5(1,1).set_title('choice aborted');
    
    ggSIMb5(1,2) = gramm('x', categorical(sim_blocks.eff), 'color', categorical(sim_blocks.side), 'subset', sim_blocks.aborted & strcmp('instr',sim_blocks.choice));
    ggSIMb5(1,2).stat_bin;
    %ggSIMb5(1,2).set_order_options('color',[1 2 5 6 3 4 7 8]);
    ggSIMb5(1,2).set_names('x','effector','color','');
    ggSIMb5(1,2).set_title('instructed aborted');
    ggSIMb5(1,2).set_color_options('map','brewer2');
    
    ggSIMb5.axe_property('YLim', [0 20]);
    ggSIMb5.set_title(['aborted trals in simulated blocks; performance = ' num2str(performance) '; error back after ' ...
        num2str(put_back(1)) ' to ' num2str(put_back(2)) ' trials']);
    ggSIMb5.draw;
    
    
    
    %% How many trials in each condition
    % these plots show, that even considering choice bias and errors, there are
    % still enough trials in each condition with the randomization method used.
    
    figure;
    ggSIMb1(1,1) = gramm('x',categorical(sim_blocks.eff),'color',categorical(sim_blocks.side),'subset',~sim_blocks.aborted);
    ggSIMb1(1,1).stat_bin;
    ggSIMb1(1,1).set_order_options();
    ggSIMb1(1,1).facet_wrap(sim_blocks.choice);
    ggSIMb1(1,1).set_names('x','effector','color','','column','');
    ggSIMb1(1,1).set_title(['Targets chosen; successful only; performance = ' num2str(performance) '; error back after ' ...
        num2str(put_back(1)) ' to ' num2str(put_back(2)) ' trials']);
    ggSIMb1(1,1).set_color_options('map','brewer2');
    
    ggSIMb1(1,1).draw;
    
%%
err_table = struct2table(err);
ggERR1 = gramm('x', categorical(err_table.norm_place),'color',categorical(err_table.real_place));
ggERR1.stat_bin;
ggERR1.draw;








end






