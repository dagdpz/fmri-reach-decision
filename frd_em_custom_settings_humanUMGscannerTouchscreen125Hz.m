% em_custom_settings_humanUMGscanner60Hz
% settings file for use for em_saccade_blink_detection
% see defpar in em_saccade_blink_detection.m for more options
% should contain variable **settings** as below!

settings = {...
    'SampleRate',       1000, ...       % Hz
    'Downsample2Real',  125, ...         % Hz (actual eyetracker sampling
    'SacOnsetVelThr',   4.2, ...         % deg/s
    'SacOffsetVelThr',  1.5, ...         % deg/s
    'MinSacDuration',   0.03, ...       % s
    'MaxSacDuration',   Inf, ...        % s
    'MinSacAmplitude',  5, ...          % deg
    'MaxSacAmplitude',  Inf, ...        % deg
    'PosSmoothConvWin', 'gausswin', ... % 'rectwin', 'gausswin', etc.
    'PosSmoothConvLen', 0 ...           % s, length of conv kernel, set
    'PosFilterCutoff',  20, ...         % Hz, set to 0 if no filter %10 
    'VelSmoothConvWin', 'gausswin', ... % 'rectwin', 'gausswin', etc.
    'VelSmoothConvLen', 0, ...          % s, length of conv kernel, set 
    'VelFilterCutoff',  12, ...         % Hz, set to 0 if no filter
    'VelAdaptiveThr',   false, ...      % true or false
    'MinFixDurAfterSac',0, ...          % s
    'Plot',             false, ...       % true or false
    'OpenFigure',       false, ...        % true or false
    'Verbose',          false ...		% true or false

	};