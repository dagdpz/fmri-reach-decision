%% fdr_simulate_presentation_logic

% it needs the mat file from frd_create_condition order

clear all

% define
put_back = [2 5];
performance = 0.9;
% preallocate
sim_blocks = table();
x = 1;
load('Y:\MRI\Human\fMRI-reach-decision\Simulation\shuffled_conditions_S01.mat');
save('Y:\MRI\Human\fMRI-reach-decision\Simulation\shuffled_conditions_S01_changed.mat');
%%

while x == 1
load('Y:\MRI\Human\fMRI-reach-decision\Simulation\shuffled_conditions_S01_changed.mat');

curr_trial  = present(counter,:);  
%sim_blocks(counter,:) = present(counter,:);

success = rand(1) > (1 - performance);

if success

    curr_trial.success = true;
else 

    curr_trial.success = false;
    
    err_back = randperm((put_back(2) - put_back(1)),1) + put_back(1);
    present = [present(1:(counter + err_back - 1),:); ...
               present(counter,:); ...
               present((counter + err_back):end,:)];
end

sim_blocks(counter,:) = curr_trial;
counter = counter +1;

if height(present) < counter
    x = 2;
end

save('Y:\MRI\Human\fMRI-reach-decision\Simulation\shuffled_conditions_S01_changed.mat','present','counter');

end