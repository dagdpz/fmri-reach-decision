function plot_peak_instructed
%% Plots peak instructed plots stats

export = 0;
export_path = 'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\stats\plots peak instructed';

%% load data
load('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\stats\Exp_era_period_average.mat'); 
load('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\curve_colors.mat');

%% check it table exists, if not create it, otherwise load it
if ~exist('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\stats\PIfitted_table.mat')
    
    load('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\voi_names.mat');

    load('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\stats\PIfitted.mat');

    
    pi_fit = struct2table(PIfitted);
    
    pi_fit.name = cell(length(pi_fit.fitted),1);
    for i = 1:length(pi_fit.fitted)
        pi_fit.name{i} = [pi_fit.eff{i} '_' pi_fit.choi{i} '_' pi_fit.side{i}];
    end
    
    pi_fit.eff = categorical(pi_fit.eff);
    pi_fit.choi = categorical(pi_fit.choi);
    pi_fit.side = categorical(pi_fit.side);
    pi_fit.name = categorical(pi_fit.name);
    pi_fit = join(pi_fit,vois,'Keys','voi_number');
    
    [pi_fit.pvalue,pi_fit.zscore,pi_fit.SE] = pvalue_from_ci(pi_fit.fitted,pi_fit.lwr,pi_fit.upr);
    
    save('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\stats\PIfitted_table.mat','pi_fit')
    %writetable(pi_fit,'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\stats\PIfitted_table.csv')    

else
    load('Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI\stats\PIfitted_table.mat')
end

%% FITTED VALUES
title = 'fitted values - left hemisphere';
figure ('Position', [100 100 1600 1000],'Name',title);
g = gramm('y',pi_fit.fitted,'ymin',pi_fit.lwr,'ymax',pi_fit.upr,'x',pi_fit.side,'lightness',pi_fit.choi,'color',pi_fit.eff,'column',pi_fit.voi_number,'subset',pi_fit.voi_number < 100);
g.facet_wrap(pi_fit.voi);
g.geom_interval('geom',{'bar','black_errorbar'},'dodge',0.4);
g.geom_hline('yintercept',0);
g.set_title('')
%g.set_color_options('map',colors.color,'n_color',8,'n_lightness',1);
g.set_order_options('color',{'sac','reach'});
g.set_names('x','side','y','% BOLD change','lightness','','color','','column','');
g.axe_property('YGrid','on');
g.set_title(title)
g.draw;

if export
    g.export('file_name',title,...
        'export_path',export_path,...
        'file_type','pdf');
    
    close(title)
end

title = 'fitted values - right hemisphere';
figure ('Position', [100 100 1600 1000],'Name',title);
g = gramm('y',pi_fit.fitted,'ymin',pi_fit.lwr,'ymax',pi_fit.upr,'x',pi_fit.side,'lightness',pi_fit.choi,'color',pi_fit.eff,'column',pi_fit.voi_number,'subset',pi_fit.voi_number > 100);
g.facet_wrap(pi_fit.voi);
g.geom_interval('geom',{'bar','black_errorbar'},'dodge',0.4);
g.geom_hline('yintercept',0);
g.set_title('')
%g.set_color_options('map',colors.color,'n_color',8,'n_lightness',1);
g.set_order_options('color',{'sac','reach'});
g.set_names('x','side','y','% BOLD change','lightness','','color','','column','');
g.axe_property('YGrid','on');
g.set_title(title)
g.draw;

if export
    g.export('file_name',title,...
        'export_path',export_path,...
        'file_type','pdf');
    
    close(title)
end

%% simple means - BAR plot

title = 'simple group means - left hemisphere';
figure ('Position', [100 100 1600 1000],'Name',title);
g = gramm('x',tt.side,'y',tt.mean,'color',tt.eff,'lightness',tt.choi,'subset',tt.hemi == 'lh');
g.facet_wrap(tt.voi,'ncols',4);
g.stat_summary('geom',{'bar','black_errorbar'},'setylim',true);
g.set_order_options('lightness',{'9','12','15'});
g.geom_hline('yintercept',0);
g.axe_property('YGrid',true);
g.set_title(title);
%g.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1);
g.set_order_options('color',{'sac', 'reach'});
g.set_names('x','side','lightness','','color','','column','','y','diff % BOLD change');

g.draw;

if export
    g.export('file_name',title,...
        'export_path',export_path,...
        'file_type','pdf');
    
    close(title)
end

title = 'simple group means - right hemisphere';
figure ('Position', [100 100 1600 1000],'Name',title);
g = gramm('x',tt.side,'y',tt.mean,'color',tt.eff,'lightness',tt.choi,'subset',tt.hemi == 'rh');
g.facet_wrap(tt.voi,'ncols',4);
g.stat_summary('geom',{'bar','black_errorbar'},'setylim',true);
g.set_order_options('lightness',{'9','12','15'});
g.geom_hline('yintercept',0);
g.axe_property('YGrid',true);
g.set_title(title);
%g.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1);
g.set_order_options('color',{'sac', 'reach'});
g.set_names('x','side','lightness','','color','','column','','y','diff % BOLD change');

g.draw;

if export
    g.export('file_name',title,...
        'export_path',export_path,...
        'file_type','pdf');
    
    close(title)
end


%% VIOLINE PLOTS

title = 'distribution - left hemisphere';
figure ('Position', [100 100 1600 1000],'Name',title);
g = gramm('x',tt.side,'y',tt.mean,'color',tt.eff,'lightness',tt.choi,'subset',tt.hemi == 'lh')
g.facet_wrap(tt.voi,'ncols',4);
%g.stat_summary('geom',{'area', 'point'},'setylim',true);
%g.stat_summary('geom',{'line', 'point', 'errorbar'},'setylim',true,'dodge',0.2);
%g.stat_summary('geom',{'bar', 'black_errorbar'},'setylim',true,'dodge',0.7);
g.stat_violin('fill','edge','dodge',0.8);
g.stat_boxplot('width',0.2,'dodge',0.8);
%g.stat_glm('geom','area');
%g.axe_property('YLim',[0 0.25]);
g.axe_property('YGrid','on');
%g.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1);

g.set_order_options('color',{'sac', 'reach'});
g.set_names('color','','column','');
g.geom_hline('yintercept',0);
g.set_title(title);
g.draw;

if export
    g.export('file_name',title,...
        'export_path',export_path,...
        'file_type','pdf');
    
    close(title)
end



title = 'distribution - right hemisphere';
figure ('Position', [100 100 1600 1000],'Name',title);
g = gramm('x',tt.side,'y',tt.mean,'color',tt.eff,'lightness',tt.choi,'subset',tt.hemi == 'right')
g.facet_wrap(tt.voi,'ncols',4);
%g.stat_summary('geom',{'area', 'point'},'setylim',true);
%g.stat_summary('geom',{'line', 'point', 'errorbar'},'setylim',true,'dodge',0.2);
%g.stat_summary('geom',{'bar', 'black_errorbar'},'setylim',true,'dodge',0.7);
g.stat_violin('fill','edge','dodge',0.8);
g.stat_boxplot('width',0.2,'dodge',0.8);
%g.stat_glm('geom','area');
%g.axe_property('YLim',[0 0.25]);
g.axe_property('YGrid','on');
%g.set_color_options('map',[ 0.1020, 0.5882, 0.2549; 0.8431, 0.0980, 0.1098],'n_color',2,'n_lightness',1);

g.set_order_options('color',{'sac', 'reach'});
g.set_names('color','','column','');
g.geom_hline('yintercept',0);
g.set_title(title);
g.draw;

if export
    g.export('file_name',title,...
        'export_path',export_path,...
        'file_type','pdf');
    
    close(title)
end


%% %%%%%%%%%%%%%%%%% Export Stuff
pi_fit.hemi_long = renamecats(pi_fit.hemi,{'lh','rh'},{'left','right'});
pi_fit.voi_short = renamecats(pi_fit.voi_short,{'Insular'},{'Insula'});
pi_fit.side = renamecats(pi_fit.side,{'l','r'},{'left','right'});

pi_fit.voi_fig = cell(length(pi_fit.hemi),1);
for i = 1:length(pi_fit.hemi)
    
   pi_fit.voi_fig{i} = [char(pi_fit.voi_short(i)),' ',char(pi_fit.hemi_long(i))];
end


%%
subset = pi_fit.hemi == 'lh';
sor = sortrows(unique(table(pi_fit.voi_short(subset), pi_fit.voi_number(subset))),2);

title = 'Model 1: activation strength per task condition - left hemisphere';
figure ('Position', [100 100 800 1000],'Name','model 1 left');
g = gramm('y',pi_fit.fitted,'ymin',pi_fit.lwr,'ymax',pi_fit.upr,'x',pi_fit.side,'lightness',pi_fit.choi,'color',pi_fit.eff,'column',pi_fit.voi_number,'subset',subset);
g.facet_wrap(pi_fit.voi_short,'ncols',3);
g.geom_interval('geom',{'bar','black_errorbar'},'width',0.5,'dodge',0.6);
g.set_color_options('lightness_range',[35 80],'chroma_range',[80 40],'hue_range',[25 230]);
g.set_order_options('color',{'sac','reach'},'column',sor.Var1);
g.set_names('x','side','y','% BOLD change','lightness','','color','','column','');
g.set_text_options('base_size', 14,'facet_scaling',0.8,'title_scaling',1,'legend_scaling',0.9,'label_scaling',0.95);
g.set_line_options('base_size',1.2);
g.set_layout_options('legend_width',0.2,'legend_position',[0.78 0.06 0.2 0.2],'redraw',false,'margin_height',[0.1 0.15],'margin_width',[0.1 0.1],'gap',[0.03 0.06],'title_centering','plot');

g.axe_property('YGrid','on','Ylim',[-0.08 0.48]);
g.set_title(title)
g.draw;

if 1
    g.export('file_name','model 1 left',...
        'export_path','Y:\Personal\Peter\writing up',...
        'file_type','jpg');
    
    close('model 1 left')
end

%%
subset = pi_fit.hemi == 'rh';
sor = sortrows(unique(table(pi_fit.voi_short(subset), pi_fit.voi_number(subset))),2);

title = 'Model 1: activation strength per task condition - right hemisphere';
figure ('Position', [100 100 800 1000],'Name','model 1 right');
g = gramm('y',pi_fit.fitted,'ymin',pi_fit.lwr,'ymax',pi_fit.upr,'x',pi_fit.side,'lightness',pi_fit.choi,'color',pi_fit.eff,'column',pi_fit.voi_number,'subset',subset);
g.facet_wrap(pi_fit.voi_short,'ncols',3);
g.geom_interval('geom',{'bar','black_errorbar'},'width',0.5,'dodge',0.6);
g.set_color_options('lightness_range',[35 80],'chroma_range',[80 40],'hue_range',[25 230]);
g.set_order_options('color',{'sac','reach'},'column',sor.Var1);
g.set_names('x','side','y','% BOLD change','lightness','','color','','column','');
g.set_text_options('base_size', 14,'facet_scaling',0.8,'title_scaling',1,'legend_scaling',0.9,'label_scaling',0.95);
g.set_line_options('base_size',1.2);
g.set_layout_options('legend_width',0.2,'legend_position',[0.78 0.06 0.2 0.2],'redraw',false,'margin_height',[0.1 0.15],'margin_width',[0.1 0.1],'gap',[0.03 0.06],'title_centering','plot');

g.axe_property('YGrid','on','Ylim',[-0.08 0.48]);
g.set_title(title)
g.draw;

if 1
    g.export('file_name','model 1 right',...
        'export_path','Y:\Personal\Peter\writing up',...
        'file_type','jpg');
    
    close('model 1 right')
end


