function param = fes_param_gen(param)
    % param.prof_amp = [100, 100, 0]; % percent, for fes profile
    % param.prof_width = [100, 100, 0]; % percent, for fes profile
    % param.prof_ramp = [0, 1, 0, 1,0]; % 0) constant, 1) ranmp
    % param.prof_time = [500, 500, 2000, 250,250]; %msec

    param.prof_amp = [100, 100, 0];         % amplitude percentages for each pulse stage
    param.prof_width = [100, 100, 0];       % width percentages for each pulse stage
    param.prof_ramp = [1, 0, 1];            % 1 for RAMP, 0 for CONST
    param.prof_time = [500, 5000, 500];     % time durations in milliseconds

    param.td = sum(param.prof_time)/1000; %sec
    param.anode = []; % placeholder
    param.cathode = []; % placeholder
    param.amp = []; % placeholder
    param.width = []; % placeholder
end

