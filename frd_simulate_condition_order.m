%% Generation of Conditions for Subjects

clear all

del = [3 6 9 12 15];
del_Freq_v2 = [0.05 0.15 0.25 0.30 0.25]; % n = 20 --> 1     3     5     6     5
del_occ = [1 3 5 6 5];

n_cond = (2+3)*2*2; % in order of occurence: instructed, choice, left/right, eye/hand
n_all = n_cond*20;

%% Constraints

% I want the following constraints for when and how conditions and delays
% are presented:

% - A) All Conditions should be presented approx equally often within a
%       run, so you avoid a single condition to be repeated 10 times in a row

% - B) Also for delays, you want to avoid for example a 12 sec delay to be
%       repeated 10 times in a row. That means, you would need a relativle small
%       number of total amount of delays (e.g. 20?)

% - C) Each Condition shall be presented equally often within a respective
%       delay


% For the constraints A and B to be true, one must randomize not over all
% trials of all sessions, but distribute the trials "locally" within for
% example 20 or 30 or whatever trials. 
% For the conditions, since you need at least 20 trials to
% get a ratio of 60/40 of the 4 choice and the 4 instructed conditions,
% "locally randomzing" in blocks of 20 is suitable. 

% Now, how many delays should there be at least, in order to be able to
% discriminate the respective frequencies? For example, for 5 different
% delays, if you allow only 5 trials in total (denominator = 5), it is not possible to have
% differently distributed trial frequencies, the frequs would be 0.20 for
% each delay
% If you allow 100 trials (denominator = 100), then the respective frequencies could
% theoretically be very specific, so a high denominator seems best at first glance.
% BUT, in order to fullfill constrain C), you would need 20 conditions times
% 100 delays, so 2000 trials, in order to really make sure, that each
% condition occurs equally often within a specific delay. 
% That means, you would have to aim for a small denominator for delays.

% I chose 20 trials to distribute to the 5 delays to get respective delay
% frequencies, because it fitted nicely to 20 conditions and made my life
% easier. Given the resulting mean delay, a perfect subject would do almost
% 400 trials in 15 runs, so constrain C) is satisfactorily fullfilled. 


%% idea 1: two independet generators:

% Now, lets look at our block of 20 conditions and a block of 20 delays. 
% One could just go ahead, draw a random condition and a random delay out of each block, put 
% them together in a table and mark them as done in the big table of 20*20
% = 400 trials (you need that in order to check for constrain C). 
% But this approach does not work, because it might happen, that e.g. condition
% eye_instr_left would only need a 3 sec- delay, but all
% 3 sec delays are used for other conditions already. 

% In a simpler example, this issue would look like this. Lets say, we have
% conditions a, b and c, as well as delays 10, 10 and 20.
% Now, in order to meet constrain C, you would need at least 3*3 trials:
% a10, a10, a20; b10, b10, b20; and c10, c10, and c20.

% In order to meet constrain A, lets have 3 blocks of 3 trials each, so
% each condition can occur once within a block. The blocks would be: 
% abc, abc ,abc. 
% Now, one would randomly assign delays. Here, we do not have a block of 20
% delays, but of 3 in order to get the respective ratios (10, 10, and 20). 

% The way it was implemented before, was, that you would shuffle the
% indices of delays. (delays: 10 10 20; indices: 1 2 3)

% shuffled indices: 2 1 3
% So condition a gets a delay number 2, b gets delay number 1 and c gets
% number 3:

% a2   a    a
% b1   b    b
% c3   c    c

% Now you take away conditions we have used already from the big matrix: 
% a10,    , a20; 
%    , b10, b20; 
% c10, c10 ,   .

% For the second block you shuffle again the delay indices: 1 2 3
% a2   a1    a
% b1   b2    b
% c3   c3    c

% Now you take away conditions we have used already from the big matrix: 
%    ,    , a20; 
%    ,    , b20; 
% c10, c10 ,???????.

% Now you see, there is no condition c20 left, to mark as done. That means,
% constrain C is violated.
% Translated to the example above, condition c would here be eye_instr_left
% and delay 20 is the 3-sec delay.

% That shows, that the randomization has to be somehow limited. You can see, that
% delay number 3 came up in both shuffles at last number: [2 1 3] and [1 2
% 3]. This caused the error and the violation of constrain C).

%% Idea 2: more elaborate shuffle
% That meams, we need a shuffle, where each delay number is repeated only
% once per position. In each row (block) and each column (condition), each
% delay index occurs only once. In that way, one can make sure to
% distribute all conditions to all delays within the limited scope of 9
% trials.

% 1 2 3
% 2 3 1
% 3 1 2

% This thing is called circular matrix, and can be increased in size, which
% in matlab you do like this for 20 delays: 
% delays_ordered = gallery('circul', 1:20); 

% Now you can shuffle the rows and the columns of that matrix seperately to keep the
% relative relationship of delay numbers (columns) over blocks (rows). Then you take an
% ordered block of 20 conditions, asign row 1 of that matrix,
% shuffle those conditions now with delays attached, put them in the big
% presentation table, and continue with another ordered block of
% conditions, and assign row 2 the of the matrix and continue. 




%% Getting all possible combinations

eff =       {'eye', 'hnd'};
choice =    {'choi', 'choi', 'choi', 'instr', 'instr'};
side =      {'left', 'right'} ;
delay_all = [repmat(del(1),1,del_occ(1)), ...
    repmat(del(2),1,del_occ(2)), ...
    repmat(del(3),1,del_occ(3)), ...
    repmat(del(4),1,del_occ(4)), ...
    repmat(del(5),1,del_occ(5)), ...
    ];

all_condis = length(eff) * length(choice) * length(side) * length(delay_all);

condis = struct();
n = 1;

for e = 1:length(eff)
    for c = 1:length(choice)
        for s = 1:length(side)
            for d = 1:length(delay_all)
                
                
                condis(n).eff = eff{e};
                condis(n).choice = choice{c};
                condis(n).side = side(s);
                condis(n).delay = delay_all(d);
                
                condis(n).comb = [eff{e} '_' choice{c} '_' side{s}];
                
                condis(n).comb_del = [eff{e} '_' choice{c} '_' side{s} '_' num2str(delay_all(d))];
                
                n = n +1;
            end
        end
    end
end

condis = struct2table(condis);
condis.id = [1:400]';

%% getting the condition block 
% one time all conditions (n = 20)

cond_block = struct();

j = 1;

for e = 1:length(eff)
    for c = 1:length(choice)
        for s = 1:length(side)
            
            cond_block(j).eff = eff{e};
            cond_block(j).choice = choice{c};
            cond_block(j).side = side(s);
            
            cond_block(j).comb = [eff{e} '_' choice{c} '_' side{s}];
            j = j +1;
            
        end
    end
end

cond_block = struct2table(cond_block);

%% get eggs

delays_ordered = gallery('circul', 1:length(delay_all)); 



%% prepare eggs

% setup triallist

%triallist = 1:20;

% which condi trials are done?
condis.done = false(height(condis),1);


% preallocate presentation condis + artifical blocks
art_block = table();
present = table();
bn = 0;

while ~all(condis.done)
    
    % delete blocks from before
    art_block = [];
    %done_delay = false(size(delay_all)); 
    
    % scramble egg delays for each block
    delays_scrambled = delays_ordered(randperm(length(delays_ordered)),randperm(length(delays_ordered)));
    
    % loop over rows of delays
    for k = 1:size(delays_scrambled,1)
        
        % add delays to artificial block
        art_block = cond_block;
        art_block.delay = delay_all(delays_scrambled(k,:))';
                

        for i = 1:length(art_block.comb)
            
            art_block.comb_del{i} = [art_block.comb{i} '_' num2str(art_block.delay(i))];
            
            % find ich consecutive condition in art_block and sign it off
            % as done in condi
            select_cond = find(strcmp(art_block.comb_del(i),condis.comb_del) & ~condis.done);
            
            condis.done(select_cond(1)) = 1;
            
        end % loop 
        
        % shuffle art_block, because there still in order of the for loop
        randomOrder_art_block = randperm(numel(art_block.comb));
        art_block = art_block(randomOrder_art_block,:);
    
        % add art_block number
        bn = bn + 1;
        art_block.number = repmat(bn,length(art_block.comb),1);
         
        % put it in big presentation array 
        present = [present; art_block];
        
    end % loop delays
end


%%
real_block = [];

for i = 1:(height(present))/25
    a = ones(25,1)*i;
    real_block = [real_block; a];
end

present.real_block = real_block;
%%
real_session = [repmat(1,125,1);...
                repmat(2,125,1);...
                repmat(3,125,1);...
                repmat(4,25,1)
                ];
            
present.real_session = real_session;


%% 
% Stats:

tabulate(present.choice);
tabulate(present.comb);

%% enjoy eggs - plots with ATRIFICAL block lengths 
%(they exist, because of randomization process)

% use these plots for sanity check, if randomization worked

if 0 % Plotting
%%

% delays
figure;
ggART = gramm('x',categorical(present.delay),'color',categorical(present.number));
ggART.stat_bin;
ggART.set_order_options('x',[3 4 5 1 2],'color',[1 12 14 15 16 17 18 19 20 2 3 4 5 6 7 8 9 10 11 13]);
ggART.set_names('x','Delays','color','artificial blocks');
ggART.set_title('Every delay occurs equally often in every artifical block.');
%ggART.facet_wrap(present.number);
ggART.draw;

% conditions
figure;
ggART2 = gramm('x',categorical(present.comb),'color',categorical(present.number));
ggART2.stat_bin;
ggART2.set_order_options('x',[1 2 5 6 3 4 7 8],'color',[1 12 14 15 16 17 18 19 20 2 3 4 5 6 7 8 9 10 11 13]);
ggART2.set_names('x','Delays','color','artificial blocks');
ggART2.set_title('Every choice/instructed condition occurs equally often in every artifical block.');
%ggART.facet_wrap(present.number);
ggART2.draw;

% delays + conditions
figure;
ggART3 = gramm('x',categorical(present.delay),'color',present.comb);
ggART3.stat_bin;
ggART3.set_order_options('x',[3 4 5 1 2],'color',[1 2 5 6 3 4 7 8]);
ggART3.set_names('x','Delays','color','conditions');
ggART3.set_title('Within all 400 trials, each choice/instructed condition occurs equally often for each delay');
%ggART3.facet_wrap(present.choice);
ggART3.draw;

% delays + conditions scattered in blocks
figure;
ggART4 = gramm('x',categorical(present.delay),'color',present.comb);
ggART4.stat_bin;
ggART4.set_order_options('x',[3 4 5 1 2],'color',[1 2 5 6 3 4 7 8],'column',[1 12 14 15 16 17 18 19 20 2 3 4 5 6 7 8 9 10 11 13]);
ggART4.set_names('x','Delays','color','conditions','column','');
ggART4.facet_wrap(categorical(present.number));
ggART4.set_title('Each condition-delay combination CANNOT occur equally often in one artifical block');
ggART4.draw;

%% enjoy real eggs - plots with REAL block lengths

% these plots prove, that the way the trials are randomized (in artifical
% blocks) also works, if you redistribute them in blocks of expected length

% no errors are taken into acccount here

% delays
figure;
ggREALb = gramm('x',categorical(present.delay),'color',categorical(present.real_block));
ggREALb.stat_bin;
ggREALb.set_order_options('x',[3 4 5 1 2],'color',[1 9 10 11 12 13 14 15 16 2 3 4 5 6 7 8]);
ggREALb.set_names('x','Delays','color','real blocks');
ggREALb.set_title('Distribution of Delays in real blocks of N = 25 ');
%ggREALb.facet_wrap(present.number);
ggREALb.draw;

% conditions
figure;
ggREALb2 = gramm('x',categorical(present.comb),'color',categorical(present.real_block));
ggREALb2.stat_bin;
ggREALb2.set_order_options('x',[1 2 5 6 3 4 7 8],'color',[1 9 10 11 12 13 14 15 16 2 3 4 5 6 7 8]);
ggREALb2.set_names('x','Delays','color','real blocks');
ggREALb2.set_title('Distribution of Conditions in real blocks of N = 25 ');
%ggREALb.facet_wrap(present.number);
ggREALb2.draw;

% delays scattered in blocks
figure;
ggREALb3 = gramm('x',categorical(present.delay))%,'color',present.comb);
ggREALb3.stat_bin;
ggREALb3.set_order_options('x',[3 4 5 1 2],'color',[1 2 5 6 3 4 7 8],'column',[1 9 10 11 12 13 14 15 16 2 3 4 5 6 7 8]);
ggREALb3.set_names('x','Delays','color','conditions','column','');
ggREALb3.facet_wrap(categorical(present.real_block));
ggREALb3.set_title('Distribution of Delays in real blocks of N = 25');
ggREALb3.draw;

% conditions scattered in blocks
figure;
ggREALb4 = gramm('x',categorical(present.comb),'color',categorical(present.choice));
ggREALb4.stat_bin;
ggREALb4.set_order_options('x',[1 2 5 6 3 4 7 8],'color',[1 2 5 6 3 4 7 8],'column',[1 9 10 11 12 13 14 15 16 2 3 4 5 6 7 8]);
ggREALb4.set_names('x','conditions','color','','column','');
ggREALb4.facet_wrap(categorical(present.real_block));
ggREALb4.set_title('Distributino of Conditions in real blocks of N = 25');
ggREALb4.draw;


%% plots with REAL sessions

% these plots prove, that the way the trials are randomized (in artifical
% blocks) also works, if you redistribute them in blocks of expected length
% they are now clustered in sessions

% no errors are taken into acccount here

figure;
ggREALs = gramm('x',categorical(present.delay),'color',categorical(present.real_session));
ggREALs.stat_bin;
ggREALs.set_order_options('x',[3 4 5 1 2]);%;,'color',[1 9 10 11 12 13 14 15 16 2 3 4 5 6 7 8]);
ggREALs.set_names('x','Delays','color','real sessions');
ggREALs.set_title('Distribution of Delays in real sessions of N = 125 (session 4: N = 25)');
%ggREALs.facet_wrap(present.number);
ggREALs.draw;

figure;
ggREALs2 = gramm('x',categorical(present.comb),'color',categorical(present.real_session));
ggREALs2.stat_bin;
ggREALs2.set_order_options('x',[1 2 5 6 3 4 7 8]);
ggREALs2.set_names('x','Delays','color','real sessions');
ggREALs2.set_title('Distribution of Conditions in real sessions of N = 125 (session 4: N = 25) ');
%ggREALs.facet_wrap(present.number);
ggREALs2.draw;

figure;
ggREALs3 = gramm('x',categorical(present.delay))%,'color',present.comb);
ggREALs3.stat_bin;
ggREALs3.set_order_options('x',[3 4 5 1 2],'color',[1 2 5 6 3 4 7 8]);
ggREALs3.set_names('x','Delays','color','conditions','column','');
ggREALs3.facet_wrap(categorical(present.real_session));
ggREALs3.set_title('Distribution of Delays in real sessions of N = 125 (session 4: N = 25)');
ggREALs3.draw;


figure;
ggREALs4 = gramm('x',categorical(present.comb),'color',categorical(present.choice));
ggREALs4.stat_bin;
ggREALs4.set_order_options('x',[1 2 5 6 3 4 7 8],'color',[1 2 5 6 3 4 7 8]);
ggREALs4.set_names('x','conditions','color','','column','');
ggREALs4.facet_wrap(categorical(present.real_session));
ggREALs4.set_title('Distribution of Conditions in real sessions of N = 125 (session 4: N = 25)');
ggREALs4.draw;

%%
end

%% Simulate expected distribution of conditions given performance

% define
performance = 0.9;
dur_trial = 18; % in secs, WITHOUT DELAY
put_back = [2 4]; % Put back errors after how many trials [min max]?
run_dur = 12*60; % secs per run
choice_bias_eye = 0.6;  % proportion of right choices (between 0 and 1)
choice_bias_hnd = 0.4;  % proportion of right choices (between 0 and 1)

% preallocate

sim_blocks = table();
errors = table();
time = 0;
run = 1;
t = 1;
i = 1;
countdown = -1;


while run < 16
    
    countdown = countdown - 1;
    
    % choose, which trial is on (in error or present-list)
    if countdown == 0
        
        curr_trial = errors(1,:);
        errors(1,:) = [];
        
        % was it a previous error?
        curr_trial.prev_error = true;
        
    else
        curr_trial = present(i,:);
        i = i + 1;
        
        % was it a previous error?
        curr_trial.prev_error = false;
    end
    
    
    % check, if successful and set time
    success = rand(1) > (1 - performance);
    
    if success
        % add time
        curr_trial.length = dur_trial + curr_trial.delay;
        time = time +  curr_trial.length;
        
        % add run number
        curr_trial.run = run;
        
        % if aborted
        curr_trial.aborted = false;
        
    else
        % add random time
        curr_trial.length = randperm((dur_trial + curr_trial.delay -2),1) + 2; %two seconds ITI are always there ;
        time = time +  curr_trial.length;
        
        % add run number
        curr_trial.run = run;
        
        % if aborted
        curr_trial.aborted = true;
        
        % add to error list
        errors = [errors; curr_trial];
        
        % set countdown
        countdown = randperm((put_back(2) - put_back(1)),1) + put_back(1);
    end
    
    
    %check if run is over with that time
    if time > run_dur % run is over
        
        curr_trial.aborted = true;
        curr_trial.length = run_dur - (time - curr_trial.length); % trial gets aborted, when run_dur is reached.
        
        
        if success % if it is a success trial, it has not been put in errors yet
            % add to error list
            errors = [errors; curr_trial];
            % set countdown
            countdown = randperm((put_back(2) - put_back(1)),1) + put_back(1);
        end
        
        curr_trial.run_over = true;
        
        time = 0;
        run = run + 1;
        
        if run == 16
            break;
        end
    else
        curr_trial.run_over = false;
        
    end
    
    % choice bias
    
    % instructed
    if strcmp('instr',curr_trial.choice) % all instructed are correctly chosen
        curr_trial.target_chosen = curr_trial.side;
        
    % choice hand
    elseif strcmp('choi',curr_trial.choice) && strcmp('hnd',curr_trial.eff)
        
        target_chosen_choice_hnd = rand(1) < choice_bias_hnd; % 1 if right, 0 if left
        
        if  target_chosen_choice_hnd
            curr_trial.target_chosen = {'right'};
        else
            curr_trial.target_chosen = {'left'};
        end
        
        
    % choice eye
    elseif strcmp('choi',curr_trial.choice) && strcmp('eye',curr_trial.eff)
        
        target_chosen_choice_eye = rand(1) < choice_bias_eye; % 1 if right, 0 if left
        
        if  target_chosen_choice_eye
            curr_trial.target_chosen = {'right'};
        else
            curr_trial.target_chosen = {'left'};
        end
        
    end
    
    
    
    



% write it down in any case
sim_blocks(t,:) = curr_trial;
sim_blocks.run(t) = run;
t = t + 1;

    

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
%%



