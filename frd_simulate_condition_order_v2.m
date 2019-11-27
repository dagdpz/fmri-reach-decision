%% Generation of Conditions for Subjects

clear all;


%
% Conditions which have to be met:
% - A) all Conditions equally often presented (best: within a session)
%       --> generate Pool of Conditions for one session (= 5 runs)

% - B) all Conditions have equally distributed Delays
%       --> not possible: within a session
%       --> necessary: within all sessions (15 runs)

% - C) Delays occur nicely in a run (a few short ones at least)
%       --> define a finite number of trials "per run" (40 trials?)

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


while ~all(condis.done)
    
    % delete blocks from before
    art_block = [];
    done_delay = false(size(delay_all)); 
    
    for i = 1:length(cond_block.comb)
        
        % get successive CONDITION from cond_block filter in condis
        select_cond = strcmp(cond_block.comb(i),condis.comb);
        
        % preallocate
        which_cond_delay = 0;
        p = 0;      
       
        % scramble eggs at the beginning of each artifical block
        if i == 1
            delays = delays_ordered(randperm(length(delays_ordered)),randperm(length(delays_ordered)));
        end
        
        
        % WRONG run through randomOrder_delay and find one, where there still is
        % a possible match with current condition
        todo_delay = find(~done_delay);
        randomOrder_delay = randperm(numel(todo_delay)); 
        % 
        while sum(which_cond_delay) < 1 % if it is empty still
            
            % go one step further in randomOrder_delay
            p = p + 1;
            
            % get random delay out ouf randomOrder at place p
            which_delay = delay_all(todo_delay(randomOrder_delay(p)));
            
            % select that delay in condis
            select_delay = which_delay == condis.delay;
            
            % filter out all posibilities from condis with respective
            % cond and delay, if they are not done yet
            which_cond_delay = select_cond & select_delay & ~condis.done; %logical
        end
        
        % which of the del_block conditions is done? mark it in done_delay
        done_delay(todo_delay(randomOrder_delay(p))) = 1;
        
        delay_all(done_delay)
        
        % select a single condi specifyed by which_cond_delay
        todo_condis = find(which_cond_delay); % get indices of selected conditions
        which_condi = todo_condis(1);
        
        % which of the condi is done? mark is in condis
        condis.done(which_condi) = 1;
        
        % put selected condi in presentation condis
        art_block = [art_block; condis(which_condi,:)];
    end
    
    % shuffle art_block, because there still in order of the for loop
    randomOrder_art_block = randperm(numel(art_block.comb));
    art_block = art_block(randomOrder_art_block,:);
    
    %put it in big presentation array 
    
    present = [present; art_block];
  
    
end


% % draw one trial which has not been successfully executed
% todo = find(~done); % indices of what trials are left over (--> find gives you those indicies where the variable is not zero)
% randomOrder = randperm(numel(todo));
% do = todo(randomOrder(1));
% 
% 
% % execute trial with 80% success
% success = rand(1)>0.2;
% done(do) = success;
% 
% % report trial
% 
% fprintf('trialnumber: %i\ttrial presented: %i\tsuccess: %i\n',t, do, success)
% 
% 
% end

% How to continue best:
% in einem ersten schritt:
% vektor mit 20 delays nehmen --> 20 zufällige bedingungen mit genau den delays aus der großen liste auswählen
% die aus der liste streichen,
% wiederholen
%
% danach einbauen --> irgendwie bedingungen balancen
%


% 2 laufende Prozesse im Hintergrund:
% Delays im 20er block abarbeiten
% conditions im 40er block abarbeiten

b=[];
for i = 1:12
a = ones(20,1).*i;
b = [b;a]
end
present.art_block  = b;


test = gramm('x',present.delay,'color',present.art_block);
test.stat_bin;
%test.facet_wrap(present.art_block);
test.draw;



