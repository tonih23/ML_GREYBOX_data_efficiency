function Q = make_map(Q, M, param)

if ~isfield(Q,"raw")
    idx = 1;
else
    idx = size(Q.raw.thumb,3)+1;
end

%% distance weights for cylynder
p_cylinder = [param.cylinder.x(:),param.cylinder.y(:),param.cylinder.z(:)];
dist3 = get_distance(p_cylinder, param.now.anode, param.now.cathode); % Compute map weights based on the distance
temp =  exp(-(dist3.^2) / (2 * param.map.dist_sigma^2));
dist3_w = reshape(temp, size(param.cylinder.x));
dist3_w_n = dist3_w;
dist3_w_n(dist3_w<0.01) = nan;

for i = 1:length(param.main.fingers)
    fingerName = param.main.fingers {i};

    act3d = M.raw.(fingerName)*dist3_w_n; % can be positive / negative (ext, flx). use raw map for now.
    Q.raw.(fingerName)(:,:,idx) = act3d;
    
    S = mean(Q.raw.(fingerName),3, "omitnan"); % update mean map
    S(isnan(S)) = 0;
    Q.mean.(fingerName) = S;
end
