function M = MotionIndex(D)
M.raw.thumb = mean(D.thumb(end-1,:)-D.thumb(2,:));
M.raw.index =  mean(D.index(end-1,:)-D.index(2,:));
M.raw.middle =  mean(D.middle(end-1,:)-D.middle(2,:));
M.raw.ring =  mean(D.ring(end-1,:)-D.ring(2,:));
M.raw.little =  mean(D.little(end-1,:)-D.little(2,:));
M.activations = D.activations;

M.indp.thumb = get_independence(M.raw, "thumb");
M.indp.index = get_independence(M.raw, "index");
M.indp.middle = get_independence(M.raw, "middle");
M.indp.ring = get_independence(M.raw, "ring");
M.indp.little = get_independence(M.raw, "little");

end


function indp = get_independence(D,what)
%% compute Independence Index
v_list = fieldnames(D);
ref = [];
for i= 1:length(v_list)
    v_now = v_list{i};
    if strcmp(v_now, what)
        tgt = D.(v_now);
    else
        ref = [ref;D.(v_now)];
    end
end

if abs(tgt)<pi/180*5 % penalise too small motion
    tgt = 0;
end
score = mean(abs(ref))/abs(tgt);
score_lim = min(score,0.99999999); % constrain
indp = (1-score_lim)*sign(tgt);
end