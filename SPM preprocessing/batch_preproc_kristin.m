%% The primary control script for PREPROCESSING
% Started: september 2016
% Kristin Kaduk
%% TODO
% asthestic procedures for the script
%%create an error log
%%use the batch_function to loop through function and perhaps with the option to chose specific functions
%%
clc; clear all;
% get and set paths
%cd('Y:\MRI\Human\PDW_connectivity')
% get and set paths
%cd('C:\Users\kkaduk\Desktop\SPM')

%path_data = 'C:\Users\kkaduk\Desktop\SPM';

%% Specify variables
subjects = 'JOOD' ; %,  'JEME', 'KARA', 'KARU' } ; %'CHKO', 'JAKL', 'JEME', 'KARA', 'KARU', 'LAFR'
% 'LIFY', 'LUKA', 'MAGS', 'MAPF', 'MASC', 'RODO','SIKO', '',  }; % vector with subjects
%batch_functions = {'dicom_import_job' 'realign_estimate_job' 'coregister_job' 'segment_job'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spm('defaults','fmri');
spm_jobman('initcfg');


%% MRIchrom -> view - Information -> fMRI -> no slice duration in the header anymore
% matrix -> needed for slice time correction
% exact time for each slice
% slice order sd = ()
% Merle Dohrmann
%hdr = spm_dicom_headers('C:\Users\kkaduk\Desktop\SPM\JAKL\20151027\run01\dicom\11768-0006-0005.dcm')
%slice_times = hdr{1}.Private_0019_1029
clear jobs matlabbatch

i_sub=1;
    %path_data = 'Y:\MRI\Human\PDW_connectivity\taskState\Data';
    path_data = 'Y:\MRI\Human\fMRI-reach-decision\Experiment\testground';
    %cd('Y:\MRI\Human\PDW_connectivity')
    
    b = initialize_vars(path_data, subjects,i_sub);  % get subject-specific variables ()
    cd(b.dataDir);
    session = dir('20*');
    session = {session(1:3,1).name};
    b.session = session;
    cd('Y:\MRI\Human\PDW_connectivity');
    for i_Sess=1:numel(session)
        for i_run=1:4
            mkdir(fullfile( b.dataDir,b.session{i_Sess},b.funcRuns{i_run},'dicom'))
            mkdir(fullfile( b.dataDir,b.session{i_Sess},b.funcRuns{i_run},'fhum_nii'))
            fcNii_Data = cellstr(spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess}, b.funcRuns{i_run},'dicom'), '.nii'));
            
            if ~cellfun(@isempty,fcNii_Data)
                % discard 4 first images of each functional run
                for ind =  1: length(fcNii_Data); movefile(char(fcNii_Data(ind)) , fullfile( b.dataDir,b.session{i_Sess},b.funcRuns{i_run} , 'fhum_nii\'));  end
            else
                fprintf('\nWarning: No nii found...  %s\n',fullfile( b.dataDir,b.session{i_Sess}, b.funcRuns{i_run}));
                
            end
        end
    end
    
for i_sub=1:numel(subjects)
    %%  Slice time correction
     path_data = 'Y:\MRI\Human\PDW_connectivity\taskState\Data';
    cd('Y:\MRI\Human\PDW_connectivity')
    
    clear jobs matlabbatch
    b = initialize_vars(path_data, subjects,i_sub);  % get subject-specific variables ()
    cd(b.dataDir);
    session = dir('20*');
    session = {session(1:3,1).name};
    b.session = session;
    cd('Y:\MRI\Human\PDW_connectivity');
    %cd('C:\Users\kkaduk\Desktop\SPM')
    sliceTimes = [0	82.5	167.5	250	335	417.5	502.5	585	670	752.5	837.5	920	0	82.5	167.5	250	335	417.5	502.5	585	670	752.5	837.5	920	0	82.5	167.5	250	335	417.5	502.5	585	670	752.5	837.5	920];
    
    for i_Sess=1:numel(session)
        
        for i_run=1:4
            mkdir(fullfile( b.dataDir,b.session{i_Sess},b.funcRuns{i_run},'afhum_nii'))
            rawNii = spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess}, b.funcRuns{i_run},'fhum_nii'),'.nii');
            rawNii(1:4,:) = [];
            rawNii =  cellstr(rawNii);
            %for ii=1:numel(rawNii) ; rawNii{i} = [ rawNii{ii},',', num2str(ii)];end %add a ",1" to each line
            for ii=1:numel(rawNii) ; rawNii{ii} = [ rawNii{ii}, ',1'];end %add a ",1" to each line
            rawNii =  {rawNii};
            matlabbatch = slicetime_spm12_job(rawNii,sliceTimes);
            spm_jobman('serial', matlabbatch ,'');
            aNii = spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess}, b.funcRuns{i_run},'fhum_nii'),'a*');
            for ind =  1: length(aNii); movefile(char(aNii(ind,:)) , fullfile( b.dataDir,b.session{i_Sess},b.funcRuns{i_run} , 'afhum_nii\'));  end
        end
    end
    
    %%  spatial REALIGNMENT:Estimate - motion parameters
    % the images from each Session with the 4 functional runs is aligned to
    % the first image of the functional Session indpendently from all the
    % other two sessions
    % reslice -> correcct it as covariate  -> change the images
    % unwarp -> simulated distortions, one experinence worse for
    % individual field maps
    rawForSubject = {};
    b = initialize_vars(path_data, subjects,i_sub);  % get subject-specific variables ()
    cd(b.dataDir);
    session = dir('20*');
    session = {session(1:3,1).name};
    b.session = session;
    cd('Y:\MRI\Human\PDW_connectivity');
    %cd('C:\Users\kkaduk\Desktop\SPM')
    clear jobs matlabbatch
    
    for i_Sess=1:numel(session)
        AllrawNii =[];
        for i_run=1:4
            aNii = spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess}, b.funcRuns{i_run},'afhum_nii'),'a*');
            if size(aNii, 1)== 900;
                size(aNii, 1)
                AllrawNii = [AllrawNii; aNii];
                
            else
                fprintf('\nError not enough volumes %s...',subjects{i_sub},b.session{i_Sess}, b.funcRuns{i_run});
            end
            %size(AllrawNii, 1)
        end
        
        AllrawNii =  cellstr(AllrawNii);
        for ii=1:numel(AllrawNii) ; AllrawNii{ii} = [ AllrawNii{ii}, ',1'];end %add a ",1" to each line
        matlabbatch = realign_estimate_unwarp_job(AllrawNii);
        spm_jobman('serial', matlabbatch ,'');
        
        for i_run=1:4
            mkdir(fullfile( b.dataDir,b.session{i_Sess},b.funcRuns{i_run},'uafhum_nii'))
            uaNii = spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess}, b.funcRuns{i_run},'afhum_nii'),'u*');
            size(uaNii, 1)
            for ind =  1: length(uaNii); movefile(char(uaNii(ind,:)) , fullfile( b.dataDir,b.session{i_Sess},b.funcRuns{i_run} , 'uafhum_nii\'));end
        end
        
    end
    
    
    
    %% T1 - Coregistration: varying the parameter to find the best match between files
    % Coregistration of the anatomical file to the T1-template
    % 1. first functional Run to anatomical image of the same session
    rawData_anat_ForAllSessions = {};
    rawData_anat = {};
    fprintf('\nWorking on coregistration (anatomical to T1) %s...\n',subjects{i_sub});
    for i_Sess=1:numel(session)
        File = dir(fullfile( b.dataDir,b.session{i_Sess},b.anatT1, '/y_1*.nii'));
        if exist(fullfile( b.dataDir,b.session{i_Sess},b.anatT1,[ File.name])) == 2
            fprintf('\n PROCESS Segmentation Skipped because file exist already...  %s\n',[subjects{i_sub},'   ',  b.dataDir,b.session{i_Sess},b.anatT1,'   ' [ File.name]]);
            File = dir(fullfile( b.dataDir,b.session{i_Sess},b.anatT1, '/*.nii'));
            rawData_anat_ForAllSessions{1,i_Sess} = {fullfile( b.dataDir,b.session{i_Sess},b.anatT1,[ File.name])};
        else
            rawData_anat = cellstr(spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess},b.anatT1), '1*.nii'));
            rawData_anat = rawData_anat(1,:);
            rawData_anat = [cell2mat(rawData_anat), ',1'];
            rawData_anat =  {rawData_anat};
            rawData_anat_ForAllSessions{1,i_Sess} = rawData_anat;
        end
    end
    
    for i_Sess=1:numel(session)
        rawData_Reference =       {'D:\Sources\MATLAB\spm12\toolbox\OldNorm\T1.nii,1'}; %
        rawData_Source    =       rawData_anat_ForAllSessions{1,i_Sess};
        matlabbatch       =       corregistration_job_T1(rawData_Reference, rawData_Source);
        spm_jobman('serial', matlabbatch ,'');
    end
    
    %% Segmentation of the anatomical data
    for i_Sess=1:numel(session)
        File = dir(fullfile( b.dataDir,b.session{i_Sess},b.anatT1, '/y*.nii'));
        if exist(fullfile( b.dataDir,b.session{i_Sess},b.anatT1,[ File.name])) == 2
            fprintf('\n Segmentated anat already exists...  %s\n',[subjects{i_sub},'   ',  b.dataDir,b.session{i_Sess},'\',b.anatT1,'   ' [ File.name]]);
        else
            matlabbatch = segment_job(rawData_anat_ForAllSessions{1,i_Sess});
            spm_jobman('serial', matlabbatch ,'');
        end
    end
    %% Extraction eines Bias korrigierten Hirnbildes
    % T1
    for i_Sess=1:numel(session)
        c1 = spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess},b.anatT1),'c11');
        c1 = c1(1,:);
        while not(c1(end) == 'i'); c1 = c1(1:end - 1); end
        c1 = [c1, ',1'];
        c2 = spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess},b.anatT1),'c21*');
        c2 = c2(1,:);
        while not(c2(end) == 'i'); c2 = c2(1:end - 1); end
        c2 = [c2(1,:), ',1'];
        c3 = spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess},b.anatT1), 'c31*');
        c3 = c3(1,:);
        while not(c3(end) == 'i'); c3 = c3(1:end - 1); end
        c3 = [c3(1,:), ',1'];
        rawfilename = spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess},b.anatT1), '1*.nii');
        rawfilename = rawfilename(1,:);
        [pathstr,name,ext] = fileparts(rawfilename);
        m =spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess},b.anatT1), ['m', name]);
        m = [m, ',1'];
        
        CoreSegmData(:,i_Sess) =[{c1},{c2},{c3},{m}] ;
        CoreSegmData
        output = [name '_t1_biascorr_masked'];
        outdir = {fullfile( b.dataDir,b.session{i_Sess},b.anatT1)};
        matlabbatch = ImCalc_biasc_masked_job(CoreSegmData(:,i_Sess), output,outdir );
        spm_jobman('serial', matlabbatch ,'');
    end
    
    %% Coregistration EPIs
    T1_biasCorrected_masked = {};
    for i_Sess=1:numel(session)
        uaData_perRUN = {};
        for i_run=1:4 % get the fhum data from all 4 runs & saved in cells
            rawData_Nii_fMRI = cellstr(spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess}, b.funcRuns{i_run},'uafhum_nii'), 'ua1*'));
            for ii=1:numel(rawData_Nii_fMRI) ; rawData_Nii_fMRI{ii} = [ rawData_Nii_fMRI{ii}, ',1'];end %add a ",1" to each line
            uaData_perRUN{1,i_run} = rawData_Nii_fMRI;
        end
        
        T1_biasCorrected_masked{1,i_Sess} = cellstr(spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess},b.anatT1),'t1_biascorr*'));
        
        
        %% Coregistration of the function images to the biascorrected_masked_t1_image
        rawData_Reference =      T1_biasCorrected_masked{1,i_Sess};
        rawData_Source =          uaData_perRUN{1,1}(1,1); % !!!! warped mean image !!!!
        rawData_Source_other =    [uaData_perRUN{1,1}(2:end) ; uaData_perRUN{1,2} ; uaData_perRUN{1,3};  uaData_perRUN{1,4}];
        matlabbatch = coregister_job(rawData_Reference, rawData_Source, rawData_Source_other);
        spm_jobman('serial', matlabbatch ,'');
        
    end
    %% spatial normalisation
    for i_Sess=1:numel(session)
        % DeformationField
        Anat_deformationFields_Forward =  cellstr(spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess},b.anatT1), 'y_'));
        uaData_perRUN = {};
        for i_run=1:4 % get the fhum data from all 4 runs & saved in cells
            rawData_Nii_fMRI = cellstr(spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess}, b.funcRuns{i_run},'uafhum_nii'), 'ua1*'));
            for ii=1:numel(rawData_Nii_fMRI) ; rawData_Nii_fMRI{ii} = [ rawData_Nii_fMRI{ii}, ',1'];end %add a ",1" to each line
            uaData_perRUN{1,i_run} = rawData_Nii_fMRI;
            
        end
        uaData_perRUN{1,1} =uaData_perRUN{1,1}(2:end); %the first run includes the unwarped mean image which we don't want here
        
        for i_run=1:4
            
            %% a)Warping the images -  align the template (atlas) to the individual's image, inverting it and
            % writing the result to the file `y_'imagename'.nii'.
            %%% during the warping, the images were sliced to 2mm resolution because of the template -> lost spatial precision
            
            matlabbatch = normalisation_job( Anat_deformationFields_Forward, uaData_perRUN{1,i_run} );
            spm_jobman('serial', matlabbatch ,'');
            % Output is saved: in the folder uafhum_nii
            % shift the warped images into the folder wuafhum_nii
            [a,d,c ]= mkdir(fullfile( b.dataDir,b.session{i_Sess},b.funcRuns{i_run},'wuafhum_nii'));
            NormalisedData = [];
            NormalisedData = cellstr(spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess},b.funcRuns{i_run},'uafhum_nii'), 'wua'));
            size(NormalisedData)
            if isempty(d) ||  ~cellfun(@isempty,NormalisedData(1))
                for ind =  1: length(NormalisedData); movefile(char(NormalisedData(ind)) , fullfile( b.dataDir,b.session{i_Sess},b.funcRuns{i_run} , 'wuafhum_nii\'));  end
            end
            
            %% b)Smoothing the warped images
            %How much smoothing? -> twice the voxel-size
            wuafData= cellstr(spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess},b.funcRuns{i_run},'wuafhum_nii'), 'w*.nii'));
            size(wuafData)
            matlabbatch = smoothing_job(wuafData);
            spm_jobman('serial', matlabbatch ,'');
            
            %% organize the data: move data from one folder to another folder
            
            [a,d,c ]= mkdir(fullfile( b.dataDir,b.session{i_Sess},b.funcRuns{i_run},'swuaf'));
            swuafData= cellstr(spm_select('FPList',fullfile( b.dataDir,b.session{i_Sess},b.funcRuns{i_run},'wuafhum_nii'), 's'));
            size(swuafData)
            if isempty(d) || ~cellfun(@isempty,swuafData)
                for ind =  1: length(swuafData); movefile(char(swuafData(ind)) , fullfile( b.dataDir,b.session{i_Sess},b.funcRuns{i_run} , 'swuaf\'));  end
            end
            
        end
    end
    
end









