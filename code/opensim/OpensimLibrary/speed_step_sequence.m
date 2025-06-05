function ref = speed_step_sequence( controlIteration )

    global Ts
    t = 20.0;

    % define speed
    low_vel = deg2rad(200); 
    high_vel = deg2rad(300);
    
    % step reference
    if controlIteration*Ts < t
        ref = low_vel;
    else
        ref = high_vel;
    end   

end