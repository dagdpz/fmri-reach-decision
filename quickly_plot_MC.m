function quickly_plot_MC

% quickly plot MPparams


clear all

load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\protocols_v2.mat');

%throwaway = strcmp('ANEL',{prot.name});
throwaway = strcmp('ANEL',{prot.name});


runpath = 'Y:\MRI\Human\fMRI-reach-decision\Experiment\MNI';%%


%%

            scaleme = [-3 3];
            mydata = pwd;
            
for i = 1:length(prot) %loop subjects
    
    sessions = length(prot(i).session);
    
    for k = 1:sessions % loop sessions
        
        runs = length(prot(i).session);
        
        session_path = [runpath filesep ... % Y:\MRI\Human\fMRI-reach-decision\Experiment\CLSC\20200114
            prot(i).name filesep ...
            prot(i).session(k).date];
        
        for m = 1:length([prot(i).session(k).epi.nr1]) % loop runs
            
            epi_path = [session_path filesep 'run0' num2str(m)'];
            
            % motion parameter file
            txt_name = dir(fullfile(epi_path,'*.txt'));
            txt_name = txt_name.name;
            txt_file = [epi_path filesep txt_name];
            
            b = txt_file;
            

            
            
            printfig = figure;
            set(printfig, 'Name', ['Motion parameters: subject ' num2str(i) ], 'Visible', 'on');
            loadmot = load(deblank(b(:,:)));
            subplot(2,1,1);
            plot(loadmot(:,1:3));
            grid on;
            ylim(scaleme);  % enable to always scale between fixed values as set above
            title(['Motion parameters: shifts (top, in mm) and rotations (bottom, in dg)'], 'interpreter', 'none');
            subplot(2,1,2);
            plot(loadmot(:,4:6)*180/pi);
            grid on;
            ylim(scaleme);   % enable to always scale between fixed values as set above
            name = [prot(i).name '_' prot(i).session(k).date '_run0' num2str(m)]
            title(['Data from '   name ], 'interpreter', 'none');
            mydate = date;
            motname = [mydata filesep 'motion_sub_' sprintf('%02.0f', i) '_' mydate '.png'];
            % print(printfig, '-dpng', '-noui', '-r100', motname);  % enable to print to file
            % close(printfig);   % enable to close graphic window
            
            orient('tall');
            saveas(gcf, [session_path filesep name '_MCparams'  '.pdf'], 'pdf');
            close(gcf);
            
        end
    end
end