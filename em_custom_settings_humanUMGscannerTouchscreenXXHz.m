% em_custom_settings_humanUMGscanner60Hz
% settings file for use for em_saccade_blink_detection
% see defpar in em_saccade_blink_detection.m for more options
% should contain variable **settings** as below!

settings = {...
    'SampleRate',       1000, ...       % Hz
    'Downsample2Real',  125, ...         % Hz (actual eyetracker sampling
    'SacOnsetVelThr',   1, ...         % deg/s
    'SacOffsetVelThr',  0.3, ...         % deg/s
    'MinSacDuration',   0.03, ...       % s
    'MaxSacDuration',   Inf, ...        % s
    'MinSacAmplitude',  6, ...          % deg
    'MaxSacAmplitude',  Inf, ...        % deg
    'PosSmoothConvWin', 'gausswin', ... % 'rectwin', 'gausswin', etc.
    'PosSmoothConvLen', 0 ...           % s, length of conv kernel, set
    'PosFilterCutoff',  0, ...         % Hz, set to 0 if no filter 
    'VelSmoothConvWin', 'gausswin', ... % 'rectwin', 'gausswin', etc.
    'VelSmoothConvLen', 0.1, ...          % s, length of conv kernel, set 
    'VelFilterCutoff',  0, ...         % Hz, set to 0 if no filter
    'VelAdaptiveThr',   false, ...      % true or false
    'MinFixDurAfterSac',0, ...          % s
    'Plot',             true, ...       % true or false
    'OpenFigure',       true ...        % true or false

	};