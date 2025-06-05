function pl_z_grid_smooth = get_map(p_map, Motion, fingers)
% Update the density map using Motion scores
for f = 1:length(fingers)
    fingerName = fingers{f};
    activationValue = Motion.(fingerName);

    % Identify the grid cells that are covered by the current anode-cathode line
    for xIdx = 1:size(X(:), 1)
        point = [X(xIdx), Y(xIdx), Z(xIdx)];

        distance = get_dist(mk1, point);

        if distance <= param.thres_dist % Width of the stimulation area
            temp.(fingerName).active(xIdx) = temp.(fingerName).active(xIdx) + activationValue*distance/param.thres_dist;
            temp.(fingerName).n(xIdx) = temp.(fingerName).n(xIdx) + 1;
        end
    end

    p_map.(fingerName).raw = reshape(temp.(fingerName).active./temp.(fingerName).n, param.grid, param.grid, param.grid); % return the average to 3D grid
    p_map.(fingerName).raw(isnan(p_map.(fingerName).raw)) = 0;

    % Flatten the 3D grid data into pl_x, pl_y, pl_z
    pl_z = p_map.(fingerName).raw(:); % Extract the corresponding values from the probability density map

    % Convert the data to grid format for contour plotting
    pl_z_grid = griddata(pl_x, pl_y, pl_z, pl_x_grid, pl_y_grid);

    pl_z_grid_smooth = imgaussfilt(pl_z_grid, [0.05,5]);
end
end