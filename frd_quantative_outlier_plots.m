function frd_quantative_outlier_plots

% these plots are not exactly valid for number of trials which go into time
% courses, because those trials exceeding the scanner recording time are
% still counted


app_pdfs = 0;
app_pdfs2 = 0;
which_threshold = 0;
treshold_consequences = 1;
saving_plot_Ntrials_per_subject = 1;
    runpath_for_plot_saving = 'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI';


if app_pdfs
    pdfs = findfiles('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI','*_QA.pdf','mindepth=2');
    append_pdfs('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\all_quality_assessment_plots_combined.pdf',pdfs);
end

if app_pdfs2
    pdfs = findfiles('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI','*_Ntrials.pdf','mindepth=2');
    append_pdfs('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\all_Ntrials_plots_combined.pdf',pdfs);
end
%%

if which_threshold
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
        
        if i > 1
            if strcmp(outl.subj(i),outl.subj(i-1))
                outl.run(i) = outl.run(i-1) + 1;
            else
                outl.run(i) = 1;
            end
        else
            outl.run(i) = 1;
        end
        
        fi = load(outl.path{i});
        
        %% DVARS
        
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
        
        outl.DVARS_max(i) = max(fi.fq.DVARS_Stat.DeltapDvar);
        
        %% FD
        %outl.FD(i,:) = [fi.fq.FD'];
        
        % cut off FD 0.5
        FD05 = find(fi.fq.FD > 0.5);
        FD10 = find(fi.fq.FD > 1);
        FD15 = find(fi.fq.FD > 1.5);
        
        outl.FD05(i) = length(add_neighboring_volumes(FD05,[1 1],800));
        outl.FD10(i) = length(add_neighboring_volumes(FD10,[1 1],800));
        outl.FD15(i) = length(add_neighboring_volumes(FD15,[1 1],800));
        
        outl.FD_max(i) = max(fi.fq.FD);
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
    
    figure('Position',[0 0 1900 1400]);
    gDVARS = gramm('x',outl.subj,'y',outl.DVARS20);
    gDVARS.geom_bar();
    gDVARS.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5]);
    gDVARS.set_title(['Amount of Outliers, DVARS > 20']);
    gDVARS.draw;
    
    %% DVARS in perc.
    
    figure('Position',[0 0 1900 1400]);
    gDVARS = gramm('x',G.subj,'y',G.DVARS_perc_20);
    gDVARS.geom_bar();
    gDVARS.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5]);
    gDVARS.set_title(['Amount of Outliers, DVARS > 20']);
    gDVARS.axe_property('YTick',[0:1:20]);
    gDVARS.geom_hline('yintercept',mean(G.DVARS_perc_20),'style','k--');
    gDVARS.set_names('x','','y','percentage of all volumes');
    gDVARS.draw;
    
    
    
    %% DVARS number
    
    figure('Position',[0 0 1900 1400]);
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
    
    %% DVARS max
    figure('Position',[0 0 1900 1400]);
    gDVARS_max = gramm('x',outl.subj,'y',outl.DVARS_max,'color',outl.run);
    gDVARS_max.stat_summary('geom','bar');
    gDVARS_max.axe_property('YTick',[0:20:1000],'Ylim',[0 1000],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
    gDVARS_max.set_title('max DVARS per run (EVBO max = 2000)');
    gDVARS_max.draw;
    
    %% FD
    figure('Position',[0 0 1900 1400]);
    gFD = gramm('x',outl.subj,'y',outl.FD05);
    gFD.geom_bar();
    gFD.set_color_options('map',[0 1 0]);
    gFD.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5]);
    gFD.set_title(['Amount of Outliers, FD > 0.5']);
    gFD.draw;
    
    figure('Position',[0 0 1900 1400]);
    gFD = gramm('x',outl.subj,'y',outl.FD15);
    gFD.geom_bar();
    gFD.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5]);
    gFD.set_title(['Amount of Outliers, FD > 1.5']);
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
    
    %% max FD
    figure('Position',[0 0 1900 1400]);
    gDVARS_max = gramm('x',outl.subj,'y',outl.FD_max,'color',outl.run);
    gDVARS_max.stat_summary('geom','bar');
    gDVARS_max.axe_property('YTick',[0:0.5:14],'Ylim',[0 14],'Ygrid','on','GridColor',[0.5 0.5 0.5]);
    gDVARS_max.set_title('max FD per run');
    gDVARS_max.geom_hline('yintercept',1.5,'style','k--');
    gDVARS_max.draw;
    
    
end

%%
if treshold_consequences
    load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\protocols_v2.mat');
    runpath = 'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI';
    subjects = {prot.name};
    
    ntrials = struct;
    m = 1;
    for i = 1:length(subjects) %loop subjects
        
        
        filez = findfiles([runpath filesep subjects{i} filesep 'mat2prt_reach_decision_vardelay_foravg'],{'*cue_3.avg','*cue_6.avg','*cue_9.avg','*cue_12.avg','*cue_15.avg'},'mindepth=1');
        filez_no = findfiles([runpath filesep subjects{i} filesep 'mat2prt_reach_decision_vardelay_foravg'],{'*cue*no_outliers.avg'},'mindepth=1');
        
        
        for f = 1:length(filez)
            clear avg
            avg = xff(filez{f});
            for g = 1:length(avg.Curve)
                ntrials(m).subj = subjects{i};
                ntrials(m).cond = avg.Curve(g).Name;
                ntrials(m).n_trials = avg.Curve(g).NrOfConditionEvents;
                ntrials(m).outl = 'excl_preds';
                m = m +1;
            end
        end
        
        
        
        for f = 1:length(filez_no)
            clear avg
            avg = xff(filez_no{f});
            for g = 1:length(avg.Curve)
                ntrials(m).subj = subjects{i};
                ntrials(m).cond = avg.Curve(g).Name;
                ntrials(m).n_trials = avg.Curve(g).NrOfConditionEvents;
                ntrials(m).outl = 'incl_preds';
                m = m +1;
            end
        end
        
    end
    ntrials_struct = ntrials;
    %%
    ntrials = struct2table(ntrials_struct);
    ntrials.subj = categorical(ntrials.subj);
    ntrials.delay = cell(height(ntrials),1);
    ntrials.cond_short = cell(height(ntrials),1);
    for t = 1:height(ntrials)
        
        w = ntrials.cond{t};
        ntrials.cond{t}= w(1:(end-4));
        
        number = ntrials.cond{t};
        number = number(end);
        if  strcmp('3',number)||strcmp('6',number)||strcmp('9',number)
            ntrials.delay{t}= number;
            cond_short = ntrials.cond{t};
            ntrials.cond_short{t} = cond_short(1:(end-2));
        else
            ntrials.delay{t}= ['1' number];
            cond_short = ntrials.cond{t};
            ntrials.cond_short{t} = cond_short(1:(end-3));
        end
        
    end
    ntrials.outl = categorical(ntrials.outl);
    ntrials.cond_cat = categorical(ntrials.cond_short);
    ntrials.delay = categorical(ntrials.delay);
   
    
    %% plot consequences
    
    if saving_plot_Ntrials_per_subject
        
        for u = 1:length(subjects)
            
            figure('Position', [0 0 1100 1000]);
            c = gramm('x',ntrials.cond_cat,'y',ntrials.n_trials,'lightness',ntrials.outl,'subset',ntrials.subj == subjects{u});
            c.geom_bar('dodge',0.6);
            c.facet_wrap(ntrials.delay,'ncols',3);
            c.axe_property('Ygrid','on','GridColor',[0.5 0.5 0.5],'YTick',[0:1:36]);
            c.geom_hline('yintercept',7,'style','r--');
            c.geom_hline('yintercept',14,'style','k-.');
            c.geom_hline('yintercept',21,'style','k-.');
            c.geom_hline('yintercept',28,'style','k-.');
            c.set_order_options('color',{'incl_preds' 'excl_preds'},'column',{'3','6','9','12','15'});
            c.axe_property('XTickLabelRotation',35);
            c.set_names('x','','y','number of trials','linestyle','','column','');
            c.set_layout_options('legend_position',[0.75 0.2 0.2 0.2],'title_centering','plot');
            c.set_title(['number of trials of ' subjects{u}]);
            c.draw;
            
            orient('tall');
            saveas(gcf, [runpath_for_plot_saving filesep  subjects{u} filesep 'mat2prt_reach_decision_vardelay_foravg' filesep  subjects{u} '_Ntrials.pdf'], 'pdf');
            close(gcf);
            
            
        end
    end
end



function out = add_neighboring_volumes(in,ba,n_vol)
% in		- original volumes
% ba		- add before and after each volume
% n_vol		- max number of volumes

in = in(:)'; % make sure "in" is row

out = sort(unique(cell2mat(arrayfun(@colon,in-ba(1),in+ba(2),'Uniform', false))));
% out = sort(unique(reshape(o,1,size(o,1)*size(o,2)))); % only need to reshape if "in" is a column
out = out(out>0 & out<n_vol);
