function preproc_pipeline_job_with_code
% Resources
% Motion correction
% Although SPM plots rotations in radians, when they are saved in the rp_*.txt file, they are saved in radians.
% https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=SPM;46fdaa35.1801

tic;
clear all
load('Y:\MRI\Human\fMRI-reach-decision\Experiment\behavioral_data\protocols_v2.mat');

throwaway =  strcmp('LAHI',{prot.name}) |  strcmp('JOOD',{prot.name}) ;
prot(~throwaway) = [];
%prot.session(3) = [];
runpath = 'D:\MRI\Human\fMRI-reach-decision\mni_Experiment';

save('D:\MRI\Human\fMRI-reach-decision\mni_Experiment\buffer_for_pipeline.mat','prot', 'runpath')
tic;
%%
for u = 1:length(prot)
    
    for e = 1:length({prot(u).session.date})
        
        
        spm('Defaults','fMRI');
        spm_jobman('initcfg');
        
        toc;
        disp(['start running '  prot(u).name '_' prot(u).session(e).date])
        
        %clear matlabbatch
        
        matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'run1to5files';
        
        % EPIs here
        
        matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {
            cellstr(spm_select('FPList',[runpath filesep prot(u).name filesep prot(u).session(e).date filesep 'run01'],'^hum.*\.nii$'))
            cellstr(spm_select('FPList',[runpath filesep prot(u).name filesep prot(u).session(e).date filesep 'run02'],'^hum.*\.nii$'))
            cellstr(spm_select('FPList',[runpath filesep prot(u).name filesep prot(u).session(e).date filesep 'run03'],'^hum.*\.nii$'))
            cellstr(spm_select('FPList',[runpath filesep prot(u).name filesep prot(u).session(e).date filesep 'run04'],'^hum.*\.nii$'))
            cellstr(spm_select('FPList',[runpath filesep prot(u).name filesep prot(u).session(e).date filesep 'run05'],'^hum.*\.nii$'))
            }';
        
        %
        
        matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Named File Selector: run1to5files(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
        matlabbatch{2}.spm.spatial.realign.estwrite.data{2}(1) = cfg_dep('Named File Selector: run1to5files(2) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{2}));
        matlabbatch{2}.spm.spatial.realign.estwrite.data{3}(1) = cfg_dep('Named File Selector: run1to5files(3) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{3}));
        matlabbatch{2}.spm.spatial.realign.estwrite.data{4}(1) = cfg_dep('Named File Selector: run1to5files(4) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{4}));
        matlabbatch{2}.spm.spatial.realign.estwrite.data{5}(1) = cfg_dep('Named File Selector: run1to5files(5) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{5}));
        
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
        matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = '';
        
        matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [2 1];
        matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 4;
        matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
        matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
        
        matlabbatch{3}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
        
        % anat here
        
        matlabbatch{3}.spm.spatial.coreg.estimate.source = cellstr(spm_select('FPList',[runpath filesep prot(u).name filesep prot(u).session(e).date filesep 'anat'],'^hum.*\.nii$'));
        
        %
        
        matlabbatch{3}.spm.spatial.coreg.estimate.other = {''};
        matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
        
        matlabbatch{4}.spm.spatial.preproc.channel.vols(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
        matlabbatch{4}.spm.spatial.preproc.channel.biasreg = 0.001;
        matlabbatch{4}.spm.spatial.preproc.channel.biasfwhm = 60;
        matlabbatch{4}.spm.spatial.preproc.channel.write = [0 0];
        
        matlabbatch{4}.spm.spatial.preproc.tissue(1).tpm = {'Y:\Sources\spm12\tpm\TPM.nii,1'};
        matlabbatch{4}.spm.spatial.preproc.tissue(1).ngaus = 1;
        matlabbatch{4}.spm.spatial.preproc.tissue(1).native = [1 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(1).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(2).tpm = {'Y:\Sources\spm12\tpm\TPM.nii,2'};
        matlabbatch{4}.spm.spatial.preproc.tissue(2).ngaus = 1;
        matlabbatch{4}.spm.spatial.preproc.tissue(2).native = [1 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(2).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(3).tpm = {'Y:\Sources\spm12\tpm\TPM.nii,3'};
        matlabbatch{4}.spm.spatial.preproc.tissue(3).ngaus = 2;
        matlabbatch{4}.spm.spatial.preproc.tissue(3).native = [1 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(3).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(4).tpm = {'Y:\Sources\spm12\tpm\TPM.nii,4'};
        matlabbatch{4}.spm.spatial.preproc.tissue(4).ngaus = 3;
        matlabbatch{4}.spm.spatial.preproc.tissue(4).native = [1 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(4).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(5).tpm = {'Y:\Sources\spm12\tpm\TPM.nii,5'};
        matlabbatch{4}.spm.spatial.preproc.tissue(5).ngaus = 4;
        matlabbatch{4}.spm.spatial.preproc.tissue(5).native = [1 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(5).warped = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(6).tpm = {'Y:\Sources\spm12\tpm\TPM.nii,6'};
        matlabbatch{4}.spm.spatial.preproc.tissue(6).ngaus = 2;
        matlabbatch{4}.spm.spatial.preproc.tissue(6).native = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(6).warped = [0 0];
        
        matlabbatch{4}.spm.spatial.preproc.warp.mrf = 1;
        matlabbatch{4}.spm.spatial.preproc.warp.cleanup = 1;
        matlabbatch{4}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
        matlabbatch{4}.spm.spatial.preproc.warp.affreg = 'mni';
        matlabbatch{4}.spm.spatial.preproc.warp.fwhm = 0;
        matlabbatch{4}.spm.spatial.preproc.warp.samp = 3;
        matlabbatch{4}.spm.spatial.preproc.warp.write = [0 1];
        matlabbatch{4}.spm.spatial.preproc.warp.vox = NaN;
        matlabbatch{4}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
            NaN NaN NaN];
        matlabbatch{5}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
        matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
        matlabbatch{5}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
            78 76 85];
        matlabbatch{5}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
        matlabbatch{5}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{5}.spm.spatial.normalise.write.woptions.prefix = 'w';
        matlabbatch{6}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(2) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 2)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{2}, '.','rfiles'));
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(3) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 3)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{3}, '.','rfiles'));
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(4) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 4)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{4}, '.','rfiles'));
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(5) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 5)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{5}, '.','rfiles'));
        matlabbatch{6}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
            78 76 85];
        matlabbatch{6}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
        matlabbatch{6}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{6}.spm.spatial.normalise.write.woptions.prefix = 'w';
        
        matlabbatch{7}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
        matlabbatch{7}.spm.spatial.smooth.fwhm = [6 6 6];
        matlabbatch{7}.spm.spatial.smooth.dtype = 0;
        matlabbatch{7}.spm.spatial.smooth.im = 0;
        matlabbatch{7}.spm.spatial.smooth.prefix = 's8';
        
        
        spm_jobman('run', matlabbatch);
        
        toc;
        disp(['finished running '  prot(u).name '_' prot(u).session(e).date])
        
        save('D:\MRI\Human\fMRI-reach-decision\mni_Experiment\buffer_for_pipeline.mat','prot', 'runpath','u','e')
        memory
        inmem
        
        clear all
        memory
        inmem
        load('D:\MRI\Human\fMRI-reach-decision\mni_Experiment\buffer_for_pipeline.mat')
        
    end
end