function D = leap_record(param)

% prepare data field
x = ceil(param.td * param.fs);
nan1 = nan(x, 1);
nan3 = nan(x, 3);
nan4 = nan(x, 4);
nan3d = nan(x, 3, 4);
nan3d4 = nan(x, 4, 4);

D.id = nan1;
D.time = nan1;
D.hand.id = nan1;
D.hand.arm.joint_prev = nan3;
D.hand.arm.joint_next= nan3;
D.hand.arm.quat = nan4;
D.hand.palm.pos = nan3;
D.hand.palm.pos = nan3;
D.hand.palm.vel = nan3;
D.hand.palm.direction = nan3;
D.hand.palm.quat = nan4;

D.hand.pinch_strength = nan1;
D.hand.pinch_distance = nan1;
D.hand.grab_angle = nan1;
D.hand.grab_strength = nan1;

D.hand.digit1.pos = nan3d;
D.hand.digit2.pos = nan3d;
D.hand.digit3.pos = nan3d;
D.hand.digit4.pos = nan3d;
D.hand.digit5.pos = nan3d;

D.hand.digit1.rot = nan3d4;
D.hand.digit2.rot = nan3d4;
D.hand.digit3.rot = nan3d4;
D.hand.digit4.rot = nan3d4;
D.hand.digit5.rot = nan3d4;

disp("Recording started.")

idx = 1;
t.hq = 1/param.fs;

tic
t.now = toc;
t.prev = t.now;
t.prev_disp = t.now;
while t.now <= param.td % run for the trial duration
    if t.now >= t.prev + t.hq % keep to a target frequency
        temp = matleap(1);    % get a frame

        D.id(idx,1) = temp.id;
        D.time(idx,1) = temp.timestamp;

        if ~isempty(temp.hands) % tracking data available
            D.hand.id(idx,1) = temp.hands(1).id;

            D.hand.grab_angle(idx, 1) =  temp.hands(1).grab_angle;
            D.hand.grab_strength(idx, 1) =  temp.hands(1).grab_strength;
            D.hand.pinch_distance(idx, 1) =  temp.hands(1).pinch_distance;
            D.hand.pinch_strength(idx, 1) =  temp.hands(1).pinch_strength;

            D.hand.arm.joint_prev(idx, 1:3) = temp.hands(1).arm.prev_joint; % assume 1 hand only...
            D.hand.arm.joint_next(idx, 1:3) = temp.hands(1).arm.next_joint;
            D.hand.arm.quat(idx, 1:4) = temp.hands(1).arm.rotation;
            D.hand.palm.pos(idx,1:3) = temp.hands(1).palm.position;
            D.hand.palm.vel(idx,1:3) = temp.hands(1).palm.velocity;
            D.hand.palm.direction(idx,1:3) = temp.hands(1).palm.direction;
            D.hand.palm.quat(idx,1:4) = temp.hands(1).palm.orientation;

            D.hand.digit1.pos(idx, 1:3, 1) = temp.hands(1).digits(1).bones(1).prev_joint;
            D.hand.digit1.pos(idx, 1:3, 2) = temp.hands(1).digits(1).bones(1).next_joint;
            D.hand.digit1.pos(idx, 1:3, 3) = temp.hands(1).digits(1).bones(2).next_joint;
            D.hand.digit1.pos(idx, 1:3, 4) = temp.hands(1).digits(1).bones(3).next_joint;
            D.hand.digit1.pos(idx, 1:3, 5) = temp.hands(1).digits(1).bones(4).next_joint;

            D.hand.digit2.pos(idx, 1:3, 1) = temp.hands(1).digits(2).bones(1).prev_joint;
            D.hand.digit2.pos(idx, 1:3, 2) = temp.hands(1).digits(2).bones(1).next_joint;
            D.hand.digit2.pos(idx, 1:3, 3) = temp.hands(1).digits(2).bones(2).next_joint;
            D.hand.digit2.pos(idx, 1:3, 4) = temp.hands(1).digits(2).bones(3).next_joint;
            D.hand.digit2.pos(idx, 1:3, 5) = temp.hands(1).digits(2).bones(4).next_joint;

            D.hand.digit3.pos(idx, 1:3, 1) = temp.hands(1).digits(3).bones(1).prev_joint;
            D.hand.digit3.pos(idx, 1:3, 2) = temp.hands(1).digits(3).bones(1).next_joint;
            D.hand.digit3.pos(idx, 1:3, 3) = temp.hands(1).digits(3).bones(2).next_joint;
            D.hand.digit3.pos(idx, 1:3, 4) = temp.hands(1).digits(3).bones(3).next_joint;
            D.hand.digit3.pos(idx, 1:3, 5) = temp.hands(1).digits(3).bones(4).next_joint;

            D.hand.digit4.pos(idx, 1:3, 1) = temp.hands(1).digits(4).bones(1).prev_joint;
            D.hand.digit4.pos(idx, 1:3, 2) = temp.hands(1).digits(4).bones(1).next_joint;
            D.hand.digit4.pos(idx, 1:3, 3) = temp.hands(1).digits(4).bones(2).next_joint;
            D.hand.digit4.pos(idx, 1:3, 4) = temp.hands(1).digits(4).bones(3).next_joint;
            D.hand.digit4.pos(idx, 1:3, 5) = temp.hands(1).digits(4).bones(4).next_joint;

            D.hand.digit5.pos(idx, 1:3, 1) = temp.hands(1).digits(5).bones(1).prev_joint;
            D.hand.digit5.pos(idx, 1:3, 2) = temp.hands(1).digits(5).bones(1).next_joint;
            D.hand.digit5.pos(idx, 1:3, 3) = temp.hands(1).digits(5).bones(2).next_joint;
            D.hand.digit5.pos(idx, 1:3, 4) = temp.hands(1).digits(5).bones(3).next_joint;
            D.hand.digit5.pos(idx, 1:3, 5) = temp.hands(1).digits(5).bones(4).next_joint;
            % 
            % D.hand.digit1.rot(idx, 1:4, 1) = temp.hands(1).digits(1).bones(1).rotation;
            % D.hand.digit1.rot(idx, 1:4, 2) = temp.hands(1).digits(1).bones(2).rotation;
            % D.hand.digit1.rot(idx, 1:4, 3) = temp.hands(1).digits(1).bones(3).rotation;
            % D.hand.digit1.rot(idx, 1:4, 4) = temp.hands(1).digits(1).bones(4).rotation;
            % 
            % D.hand.digit2.rot(idx, 1:4, 1) = temp.hands(1).digits(2).bones(1).rotation;
            % D.hand.digit2.rot(idx, 1:4, 2) = temp.hands(1).digits(2).bones(2).rotation;
            % D.hand.digit2.rot(idx, 1:4, 3) = temp.hands(1).digits(2).bones(3).rotation;
            % D.hand.digit2.rot(idx, 1:4, 4) = temp.hands(1).digits(2).bones(4).rotation;
            % 
            % D.hand.digit3.rot(idx, 1:4, 1) = temp.hands(1).digits(3).bones(1).rotation;
            % D.hand.digit3.rot(idx, 1:4, 2) = temp.hands(1).digits(3).bones(2).rotation;
            % D.hand.digit3.rot(idx, 1:4, 3) = temp.hands(1).digits(3).bones(3).rotation;
            % D.hand.digit3.rot(idx, 1:4, 4) = temp.hands(1).digits(3).bones(4).rotation;
            % 
            % D.hand.digit4.rot(idx, 1:4, 1) = temp.hands(1).digits(4).bones(1).rotation;
            % D.hand.digit4.rot(idx, 1:4, 2) = temp.hands(1).digits(4).bones(2).rotation;
            % D.hand.digit4.rot(idx, 1:4, 3) = temp.hands(1).digits(4).bones(3).rotation;
            % D.hand.digit4.rot(idx, 1:4, 4) = temp.hands(1).digits(4).bones(4).rotation;
            % 
            % D.hand.digit5.rot(idx, 1:4, 1) = temp.hands(1).digits(5).bones(1).rotation;
            % D.hand.digit5.rot(idx, 1:4, 2) = temp.hands(1).digits(5).bones(2).rotation;
            % D.hand.digit5.rot(idx, 1:4, 3) = temp.hands(1).digits(5).bones(3).rotation;
            % D.hand.digit5.rot(idx, 1:4, 4) = temp.hands(1).digits(5).bones(4).rotation;

        end % tracking data available

        %% update loop
        idx = idx + 1 ;
        t.prev = t.now;
    end  % target frequency

    t.now = toc; % update clock

end
end
