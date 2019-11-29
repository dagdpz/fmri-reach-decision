%% Generation of Conditions for Subjects

clear all;

% Following conditions have to be met:
% - A) all Conditions equally often presented
%       --> 20 "conditions", so can be in blocks of
        

% - B) all Conditions have equally distributed Delays
%       --> not possible: within a session
%       --> necessary: within all sessions (15 runs)

% - C) Delays occur nicely in a run (a few short ones at least)
%       --> define a finite number of trials "per run" (20 trials?)

del = [3 6 9 12 15];
%del_Freq = [0.075 0.15 0.25 0.275 0.25]; % probability for 1 trial
del_Freq_v2 = [0.05 0.15 0.25 0.30 0.25]; % n = 20 --> 1     3     5     6     5
del_occ = [1 3 5 6 5];

n_cond = (2+3)*2*2; % in order of occurence: instructed, choice, left/right, eye/hand
n_all = n_cond*20;

% to make it fit into absolute numbers, there need to be 20 trials, for the
% freqs specified above. That results in 20 necessary trials * 20 condition
% trials. That means, it would be nice, if 400 trials fit within all sessions.

% idea: two independet generators:
% A: for conditions, consecutively in blocks of 40 (fullfills A)
% B: for delays, given the freqs in blocks of 20 (fullfills C)

% Test at the end: Does it fullfill the requirements (meaning: does it
% fullfill B) --> take from N = 400 Pool?)

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


if 0
%% enjoy eggs - plots with ATRIFICAL blocks


figure;
test = gramm('x',categorical(present.delay),'color',categorical(present.number));
test.stat_bin;
test.set_order_options('x',[3 4 5 1 2],'color',[1 12 14 15 16 17 18 19 20 2 3 4 5 6 7 8 9 10 11 13]);
test.set_names('x','Delays','color','artificial blocks');
test.set_title('Every delay occurs equally often in every artifical block.');
%test.facet_wrap(present.number);
test.draw;

figure;
test2 = gramm('x',categorical(present.comb),'color',categorical(present.number));
test2.stat_bin;
test2.set_order_options('x',[1 2 5 6 3 4 7 8],'color',[1 12 14 15 16 17 18 19 20 2 3 4 5 6 7 8 9 10 11 13]);
test2.set_names('x','Delays','color','artificial blocks');
test2.set_title('Every choice/instructed condition occurs equally often in every artifical block.');
%test.facet_wrap(present.number);
test2.draw;

figure;
test3 = gramm('x',categorical(present.delay),'color',present.comb);
test3.stat_bin;
test3.set_order_options('x',[3 4 5 1 2],'color',[1 2 5 6 3 4 7 8]);
test3.set_names('x','Delays','color','conditions');
test3.set_title('Within all 400 trials, each choice/instructed condition occurs equally often for each delay');
%test3.facet_wrap(present.choice);
test3.draw;

figure;
test4 = gramm('x',categorical(present.delay),'color',present.comb);
test4.stat_bin;
test4.set_order_options('x',[3 4 5 1 2],'color',[1 2 5 6 3 4 7 8],'column',[1 12 14 15 16 17 18 19 20 2 3 4 5 6 7 8 9 10 11 13]);
test4.set_names('x','Delays','color','conditions','column','');
test4.facet_wrap(categorical(present.number));
test4.set_title('Each condition-delay combination CANNOT occur equally often in one artifical block');
test4.draw;

%% enjoy real eggs - plots with REAL blocks

figure;
test = gramm('x',categorical(present.delay),'color',categorical(present.real_block));
test.stat_bin;
test.set_order_options('x',[3 4 5 1 2],'color',[1 9 10 11 12 13 14 15 16 2 3 4 5 6 7 8]);
test.set_names('x','Delays','color','artificial blocks');
test.set_title('Distribution of Delays in real blocks of N = 25 ');
%test.facet_wrap(present.number);
test.draw;

figure;
test2 = gramm('x',categorical(present.comb),'color',categorical(present.real_block));
test2.stat_bin;
test2.set_order_options('x',[1 2 5 6 3 4 7 8],'color',[1 9 10 11 12 13 14 15 16 2 3 4 5 6 7 8]);
test2.set_names('x','Delays','color','artificial blocks');
test2.set_title('Distribution of Conditions in real blocks of N = 25 ');
%test.facet_wrap(present.number);
test2.draw;

figure;
test4 = gramm('x',categorical(present.delay))%,'color',present.comb);
test4.stat_bin;
test4.set_order_options('x',[3 4 5 1 2],'color',[1 2 5 6 3 4 7 8],'column',[1 9 10 11 12 13 14 15 16 2 3 4 5 6 7 8]);
test4.set_names('x','Delays','color','conditions','column','');
test4.facet_wrap(categorical(present.real_block));
test4.set_title('Distribution of Delays in real blocks of N = 25');
test4.draw;

figure;
test4 = gramm('x',categorical(present.comb),'color',categorical(present.choice));
test4.stat_bin;
test4.set_order_options('x',[1 2 5 6 3 4 7 8],'color',[1 2 5 6 3 4 7 8],'column',[1 9 10 11 12 13 14 15 16 2 3 4 5 6 7 8]);
test4.set_names('x','conditions','color','','column','');
test4.facet_wrap(categorical(present.real_block));
test4.set_title('Distributino of Conditions in real blocks of N = 25');
test4.draw;




%% plots with REAL sessions

figure;
test = gramm('x',categorical(present.delay),'color',categorical(present.real_session));
test.stat_bin;
test.set_order_options('x',[3 4 5 1 2]);%;,'color',[1 9 10 11 12 13 14 15 16 2 3 4 5 6 7 8]);
test.set_names('x','Delays','color','artificial blocks');
test.set_title('Distribution of Delays in real blocks of N = 125 (block 4: N = 25)');
%test.facet_wrap(present.number);
test.draw;

figure;
test2 = gramm('x',categorical(present.comb),'color',categorical(present.real_session));
test2.stat_bin;
test2.set_order_options('x',[1 2 5 6 3 4 7 8]);
test2.set_names('x','Delays','color','artificial blocks');
test2.set_title('Distribution of Conditions in real sessions of N = 125 (block 4: N = 25) ');
%test.facet_wrap(present.number);
test2.draw;

figure;
test4 = gramm('x',categorical(present.delay))%,'color',present.comb);
test4.stat_bin;
test4.set_order_options('x',[3 4 5 1 2],'color',[1 2 5 6 3 4 7 8]);
test4.set_names('x','Delays','color','conditions','column','');
test4.facet_wrap(categorical(present.real_session));
test4.set_title('Distribution of Delays in real sessions of N = 125 (block 4: N = 25)');
test4.draw;

figure;
test4 = gramm('x',categorical(present.comb),'color',categorical(present.choice));
test4.stat_bin;
test4.set_order_options('x',[1 2 5 6 3 4 7 8],'color',[1 2 5 6 3 4 7 8]);
test4.set_names('x','conditions','color','','column','');
test4.facet_wrap(categorical(present.real_session));
test4.set_title('Distribution of Conditions in real blocks of N = 125 (block 4: N = 25)');
test4.draw;

%%
end
%             % get successive CONDITION from cond_block filter in condis
%             
%             
%             % preallocate
%             which_cond_delay = 0;
%             p = 0;
%             
%             % scramble eggs at the beginning of each artifical block
%             if i == 1
%                 delays = delays_ordered(randperm(length(delays_ordered)),randperm(length(delays_ordered)));
%             end
%             
%             
%             % WRONG run through randomOrder_delay and find one, where there still is
%             % a possible match with current condition
%             todo_delay = find(~done_delay);
%             randomOrder_delay = randperm(numel(todo_delay));
%             %
%             while sum(which_cond_delay) < 1 % if it is empty still
%                 
%                 % go one step further in randomOrder_delay
%                 p = p + 1;
%                 
%                 % get random delay out ouf randomOrder at place p
%                 which_delay = delay_all(todo_delay(randomOrder_delay(p)));
%                 
%                 % select that delay in condis
%                 select_delay = which_delay == condis.delay;
%                 
%                 % filter out all posibilities from condis with respective
%                 % cond and delay, if they are not done yet
%                 which_cond_delay = select_cond & select_delay & ~condis.done; %logical
%             end
%         end
%         % which of the del_block conditions is done? mark it in done_delay
%         done_delay(todo_delay(randomOrder_delay(p))) = 1;
%         
%         delay_all(done_delay)
%         
%         % select a single condi specifyed by which_cond_delay
%         todo_condis = find(which_cond_delay); % get indices of selected conditions
%         which_condi = todo_condis(1);
%         
%         % which of the condi is done? mark is in condis
%         condis.done(which_condi) = 1;
%         
%         % put selected condi in presentation condis
%         art_block = [art_block; condis(which_condi,:)];
%     end
%     
% 
%   
%     
% end
% 
% 
% % % draw one trial which has not been successfully executed
% % todo = find(~done); % indices of what trials are left over (--> find gives you those indicies where the variable is not zero)
% % randomOrder = randperm(numel(todo));
% % do = todo(randomOrder(1));
% % 
% % 
% % % execute trial with 80% success
% % success = rand(1)>0.2;
% % done(do) = success;
% % 
% % % report trial
% % 
% % fprintf('trialnumber: %i\ttrial presented: %i\tsuccess: %i\n',t, do, success)
% % 
% % 
% % end
% 
% % How to continue best:
% % in einem ersten schritt:
% % vektor mit 20 delays nehmen --> 20 zufällige bedingungen mit genau den delays aus der großen liste auswählen
% % die aus der liste streichen,
% % wiederholen
% %
% % danach einbauen --> irgendwie bedingungen balancen
% %
% 
% 
% % 2 laufende Prozesse im Hintergrund:
% % Delays im 20er block abarbeiten
% % conditions im 40er block abarbeiten



% 
% 
% 
