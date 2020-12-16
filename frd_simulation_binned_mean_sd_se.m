%% Simulation of binned mean, sd, se depending on interpolation

% dat = time x trials;

random_dat = rand(12,4);

dat_coarse = reshape(1:24,6,4);
% dat_coarse =
%      1     7    13    19
%      2     8    14    20
%      3     9    15    21
%      4    10    16    22
%      5    11    17    23
%      6    12    18    24

dat_fine = 1:0.2:24.8; % inventing 4 additional data points (24.2, 24.4, 24.6, 24.8) --> but means are different
dat_fine = reshape(dat_fine,[],4);

% dat_fine =
%     1.0000    7.0000   13.0000   19.0000
%     1.2000    7.2000   13.2000   19.2000
%     1.4000    7.4000   13.4000   19.4000
%     1.6000    7.6000   13.6000   19.6000
%     1.8000    7.8000   13.8000   19.8000
%     2.0000    8.0000   14.0000   20.0000
%     2.2000    8.2000   14.2000   20.2000
%     ...       ...      ...       ...
%     6.8000   12.8000   18.8000   24.8000

dat_fine2 = 0.6:0.2:24.4;   % inventing data points before and after (0.6, 0.8, 24.2, 24.6) --> bin_means are exactly the same as in coarse data
dat_fine2 = reshape(dat_fine2,[],4);

% dat_fine2 =
%     0.6000    6.6000   12.6000   18.6000
%     0.8000    6.8000   12.8000   18.8000
%     1.0000    7.0000   13.0000   19.0000
%     1.2000    7.2000   13.2000   19.2000
%     ...       ...      ...       ...
%     6.4000   12.4000   18.4000   24.4000

dat_even_finer = 0.52:0.04:24.48;
dat_even_finer = reshape(dat_even_finer,[],4);

%     0.5200    6.5200   12.5200   18.5200
%     0.5600    6.5600   12.5600   18.5600
%     ...       ...      ...       ...
%     1         7        13        19 
%     ...       ...      ...       ...
%     6.4800   12.4800   18.4800   24.4800

%% simple 
dat = dat_coarse; % time x trials

row_mean = mean(dat,2);
row_std = (std(dat'))';
row_se = row_std/sqrt(numel(dat));

disp('dat_coarse');
table(row_mean,row_std,row_se)

%% downsampling to binsize 

% dat = dat_coarse; % sanity check
% name = 'dat_coarse';
% binsize = 1; % dat_coarse

dat = dat_fine2; 
name = 'dat_fine2';
binsize = 5; % dat_fine2

%  dat = dat_even_finer;
%  name = 'dat_even_finer';
%  binsize = 25; % dat_even_finer

%%
% calculation
ds_row_mean = [];
ds_row_std = [];
ds_row_se = [];

for i = 0:(size(dat,1)/binsize)-1
    part_dat = dat((1+i*binsize):(binsize+i*binsize),:);
    
    ds_row_mean(i+1) = mean(part_dat,'all');
    ds_row_std(i+1) = std(part_dat(:));
    ds_row_se(i+1) = ds_row_std(i+1) / sqrt(numel(part_dat)); 
    
    
end

disp(name)
table(ds_row_mean', ds_row_std', ds_row_se')








