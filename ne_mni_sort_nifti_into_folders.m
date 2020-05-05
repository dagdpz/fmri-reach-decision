function sort_nifti_into_folders(session_path,unzip_nifti_path,hum_nr,series_order,anat)
% this function takes unziped EPIs and anatomical per session and puts them
% in session_path in new folder structure

% sort_nifti_into_folders('D:\MRI\Human\fMRI-reach-decision\mni_Experiment\JOOD\20200207','D:\MRI\Human\fMRI-reach-decision\Carsten_folder','hum_14835',[6, 9, 12, 17, 20], 15)

if series_order
    for m = 1:length(series_order) % loop runs
        
        % extracting EPIs
        run_name = ['run' num2str(m,'%02d')];
        [~,mess,~] = mkdir (session_path, run_name);
        
        if isempty(mess)
            disp([[session_path filesep run_name] ' created']);
            
            gzipfilename = [unzip_nifti_path filesep hum_nr filesep 'nifti' filesep...
                hum_nr '_'...
                sprintf('%04d',series_order(m)) '_'...
                'topupcorr.nii.gz'];
            
            gunzip(gzipfilename,[session_path filesep run_name]);
            disp([gzipfilename ' unpacked']);
        else
            disp([[session_path filesep run_name] ' already exists']);
        end
        
    end
end

if anat
    % extracting anat
    [~,mess,~] = mkdir (session_path, 'anat');
    
    if isempty(mess)
        disp([[session_path filesep 'anat'] ' created']);
        
        gzipfilename = [unzip_nifti_path filesep hum_nr filesep 'nifti' filesep...
            hum_nr '_'...
            sprintf('%04d',anat)...
            '.nii.gz'];
        
        gunzip(gzipfilename,[session_path filesep 'anat']);
        disp([gzipfilename ' unpacked']);
    else
        disp([[session_path filesep 'anat'] ' already exists']);
    end
end

end

