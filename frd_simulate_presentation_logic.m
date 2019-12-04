%% fdr_simulate_presentation_logic

% it needs the mat file from frd_create_condition order

clear all

% define
put_back = [2 5]; % Put back errors after how many trials [min max]?
performance = 0.9;
run_dur = 12*60; % secs per run
dur_trial = 18; % in secs, WITHOUT DELAY

% preallocate
sim_blocks = table();
x = 1;
time = 0;
run = 1;
load('Y:\MRI\Human\fMRI-reach-decision\Simulation\shuffled_conditions_S01.mat');
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
    err_back = randperm((put_back(2) - put_back(1)),1) + put_back(1);
    present = [present(1:(counter + err_back - 1),:); ...
               present(counter,:); ...
               present((counter + err_back):end,:)];
end



if time > run_dur
    
    curr_trial.aborted = false;
    curr_trial.length =  run_dur - (time - curr_trial.length); % last trial lasts exactly until end of run duration (12*60s)
    
    if success % if it was a sucessful trial, it was not put back into present yet
        err_back = randperm((put_back(2) - put_back(1)),1) + put_back(1);
        present = [present(1:(counter + err_back - 1),:); ...
                   present(counter,:); ...
                   present((counter + err_back):end,:)];     
    end
    
    time = 0;
    run = run + 1;
     
end

% write it down
sim_blocks(counter,:) = curr_trial;
counter = counter +1;

save('Y:\MRI\Human\fMRI-reach-decision\Simulation\shuffled_conditions_S01_changed.mat','present','counter','sim_blocks');

if run == 16
    break;
end

end


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
    ggSIMb1(1,1) = gramm('x',categorical(sim_blocks.eff),'color',categorical(sim_blocks.target_chosen),'subset',~sim_blocks.aborted);
    ggSIMb1(1,1).stat_bin;
    ggSIMb1(1,1).set_order_options();
    ggSIMb1(1,1).facet_wrap(sim_blocks.choice);
    ggSIMb1(1,1).set_names('x','effector','color','','column','');
    ggSIMb1(1,1).set_title(['Targets chosen; successful only; performance = ' num2str(performance) '; error back after ' ...
        num2str(put_back(1)) ' to ' num2str(put_back(2)) ' trials; choice bias: eye ' num2str(choice_bias_eye) ', hnd ' num2str(choice_bias_hnd)]);
    ggSIMb1(1,1).set_color_options('map','brewer2');
    
    ggSIMb1(1,1).draw;
    
end
