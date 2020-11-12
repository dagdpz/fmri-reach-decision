function frd_quantative_outlier_plots



pdfs = findfiles('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI','*_QA.pdf','mindepth=2');


%%

path = findfiles('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI','*_outlier_volumes.mat','mindepth=2');
%%

outl = table(path);
%outl.FD = NaN(height(outl),800);
%outl.DVARS_pvals = NaN(height(outl),800);
%outl.DeltapDvar = NaN(height(outl),800);

%FD = NaN(height(outl),800);


%% get DVARS + FD
for i = 1:height(outl)
    
    s = regexp(outl.path{i}, filesep, 'split');
    % name + session
    outl.subj(i) = s(7);
    outl.session(i) = s(8);
    
    fi = load(outl.path{i});
    % DVARS
    
    
    % taken from ne_DVARS_outlier_detection
    Idx     =   find(fi.fq.DVARS_Stat.pvals<0.05./(fi.fq.DVARS_Stat.dim(2)-1));
    pIdx_10 = find(fi.fq.DVARS_Stat.DeltapDvar>10); % > psig
    pIdx_30 = find(fi.fq.DVARS_Stat.DeltapDvar>30);
    
    pIdx_10 = intersect(Idx,pIdx_10);
    pIdx_30 = intersect(Idx,pIdx_30);    
    
    outliers_10 = pIdx_10 + 1;
    outliers_30 = pIdx_30 + 1;
    
    %  put it in table
    outl.DVARS20(i) = length(fi.outlier_volumes);
    outl.DVARS10(i) = length(add_neighboring_volumes(outliers_10,[1 1],800));
    outl.DVARS30(i) = length(add_neighboring_volumes(outliers_30,[1 1],800));

    %% FD
    %outl.FD(i,:) = [fi.fq.FD'];
    
    % cut off FD 0.5
    FD05 = find(fi.fq.FD > 0.5);
    FD10 = find(fi.fq.FD > 1);
    FD15 = find(fi.fq.FD > 1.5);
    
    outl.FD05(i) = length(add_neighboring_volumes(FD05,[1 1],800));
    outl.FD10(i) = length(add_neighboring_volumes(FD10,[1 1],800));
    outl.FD15(i) = length(add_neighboring_volumes(FD15,[1 1],800));
       
    
end

%%

G = groupsummary(outl,'subj',{'sum','mean', 'median'},{'DVARS10' 'DVARS20' 'DVARS30' 'FD05' 'FD10' 'FD15'});
G.DVARS_perc_10 = round( G.sum_DVARS10/(800*15)*100,2);
G.DVARS_perc_20 = round( G.sum_DVARS20/(800*15)*100,2);
G.DVARS_perc_30 = round( G.sum_DVARS30/(800*15)*100,2);

G.FD_perc_05 = round( G.sum_FD05/(800*15)*100,2);
G.FD_perc_10 = round( G.sum_FD10/(800*15)*100,2);
G.FD_perc_15 = round( G.sum_FD15/(800*15)*100,2);



%% DVARS 

figure;
gDVARS = gramm('x',outl.subj,'y',outl.DVARS20);
gDVARS.geom_bar();
gDVARS.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5]);
gDVARS.set_title(['Amount of Outliers, DVARS > 20']);
gDVARS.draw;


%% DVARS number

figure;
gDVARS_cutoff = gramm('x',G.subj,'y',G.DVARS_perc_10);
gDVARS_cutoff.geom_bar();
gDVARS_cutoff.set_color_options('map',[0 1 0]);
gDVARS_cutoff.axe_property('YTick',[0:1:20]);
gDVARS_cutoff.set_title('number of practically significant DVARS > 10% (green), 20% (yellow), 30% (red)');
gDVARS_cutoff.draw;

gDVARS_cutoff.update('y',G.DVARS_perc_20);
gDVARS_cutoff.geom_bar();
gDVARS_cutoff.set_color_options('map',[1 1 0]);
gDVARS_cutoff.draw;

gDVARS_cutoff.update('y',G.DVARS_perc_30);
gDVARS_cutoff.geom_bar();
gDVARS_cutoff.set_color_options('map',[1 0 0]);
gDVARS_cutoff.set_names('x','','y','percentage of all volumes');
gDVARS_cutoff.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5]);
gDVARS_cutoff.draw;




%% FD
figure;
gFD = gramm('x',outl.subj,'y',outl.FD05);
gFD.geom_bar();
gFD.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5]);
gFD.set_title(['Amount of Outliers, FD > 0.5']);
gFD.draw;

%% FD number

figure('Position',[0 0 1900 1400]);
gFD_cutoff = gramm('x',G.subj,'y',G.FD_perc_05);
gFD_cutoff.geom_bar();
gFD_cutoff.set_color_options('map',[0 1 0]);
gFD_cutoff.axe_property('YTick',[0:1:18]);
gFD_cutoff.set_title('number of FD > 0.5 (green), 1.0 (yellow), 1.5 (red)');
gFD_cutoff.draw;

gFD_cutoff.update('y',G.FD_perc_10);
gFD_cutoff.geom_bar();
gFD_cutoff.set_color_options('map',[1 1 0]);
gFD_cutoff.draw;

gFD_cutoff.update('y',G.FD_perc_15);
gFD_cutoff.geom_bar();
gFD_cutoff.set_color_options('map',[1 0 0]);
gFD_cutoff.set_names('x','','y','percentage of all volumes');
gFD_cutoff.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5]);
gFD_cutoff.draw;

%%


i






function out = add_neighboring_volumes(in,ba,n_vol)
% in		- original volumes
% ba		- add before and after each volume
% n_vol		- max number of volumes

in = in(:)'; % make sure "in" is row

out = sort(unique(cell2mat(arrayfun(@colon,in-ba(1),in+ba(2),'Uniform', false))));
% out = sort(unique(reshape(o,1,size(o,1)*size(o,2)))); % only need to reshape if "in" is a column
out = out(out>0 & out<n_vol);
