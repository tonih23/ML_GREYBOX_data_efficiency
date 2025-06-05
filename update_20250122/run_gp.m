
param.gp.length_scale = 10; % Adjust based on problem
param.sim.n = 50; % data resolution (point)
param.sim.scaleFactor = 0.05; % for interpolation
param.plt.disc_size = 100; % for scatterplot
param.plt.LineWidth = 1;  % for scatterplot
param.plt.MarkerEdgeColor = "w"; % for scatterplot
param.plt.FaceAlpha = 0.9;

% Load data from files
% h.hd = openfig('C:\Users\endo\Documents\GitHub\Wesenick-bachelor-2024\update_20250122\hdmap.fig','invisible'); % load hd data from the figure
h.hd = openfig('C:\Users\endo\Documents\GitHub\Wesenick-bachelor-2024\update_20250122\hd_index.fig','invisible'); % load hd data from the figure

h.mes = openfig('C:\Users\endo\Documents\GitHub\Wesenick-bachelor-2024\update_20250122\Activation_heatmap_real_data.fig','invisible'); % load measured data from the figure

% S.thumb.x = h.hd.Children(11).Children.XData; % angle
% S.thumb.y = h.hd.Children(11).Children.YData; % distance
% S.thumb.z = h.hd.Children(11).Children.ZData; % value
% S.index.x = h.hd.Children(9).Children.XData;
% S.index.y = h.hd.Children(9).Children.YData;
% S.index.z = h.hd.Children(9).Children.ZData;
% S.middle.x = h.hd.Children(7).Children.XData;
% S.middle.y = h.hd.Children(7).Children.YData;
% S.middle.z = h.hd.Children(7).Children.ZData;
% S.ring.x = h.hd.Children(5).Children.XData;
% S.ring.y = h.hd.Children(5).Children.YData;
% S.ring.z = h.hd.Children(5).Children.ZData;
% S.little.x = h.hd.Children(3).Children.XData;
% S.little.y = h.hd.Children(3).Children.YData;
% S.little.z = h.hd.Children(3).Children.ZData;

S.index.x = h.hd.Children(1).Children.XData;
S.index.y = h.hd.Children(1).Children.YData;
S.index.z = h.hd.Children(1).Children.ZData(:,end:-1:1);

% S.index.z_select = S.index.z - (S.thumb.z+S.middle.z+S.ring.z+S.little.z)/4; % penalise areas other fingers were active
% S.index.z_select = max(S.index.z_select,0); % remove negatives

S.index.z_select =  S.index.z;

xGrid = linspace(S.index.x(1:1),S.index.x(end:end), param.sim.n);  % increase resolutions of hd map
yGrid = linspace(S.index.y(1:1),S.index.y(end:end), param.sim.n);

[M.hd.x, M.hd.y] = meshgrid(xGrid, yGrid);
M.mes = M.hd; % copy grid data to mes map

z_norm = S.index.z_select/max(S.index.z_select(:)); % normalise it [0, 1]
zGrid = griddata(S.index.x(:), S.index.y(:), z_norm(:), M.hd.x, M.hd.y, 'linear');
sigma = 3;  % Standard deviation for the Gaussian kernel
M.hd.z  = imgaussfilt(zGrid, sigma);  % Gaussian smoothing

D.x = transpose((h.mes.Children(2).Children(1).XData)*10); % angle, adjust the workspace
D.y = transpose((h.mes.Children(2).Children(1).YData)*0.015); % distance
D.z = h.mes.Children(2).Children(1).CData;

close (h.hd)
close (h.mes)

% Interpolate z-values onto the grid
z_temp = griddata(D.x, D.y, D.z, M.mes.x, M.mes.y, 'natural');

% Compute the binary mask for non-NaN values
nonNaNMask = ~isnan(z_temp);

% Compute the distance from each point to the nearest non-NaN point
[distances, nearestIndices] = bwdist(nonNaNMask);

z_filled = fillmissing2(z_temp, 'nearest'); % fill nans
z_penalised = z_filled .* exp(-param.sim.scaleFactor * distances); % penalise filled value with distance

% Apply Gaussian smoothing
sigma = 1;  % Standard deviation for the Gaussian kernel
M.mes.z  = imgaussfilt(z_penalised, sigma);  % Gaussian smoothing

% Create the heatmap
figure(1)
subplot(1,2,1)

% Visualise electrode area
clr = jet(100); % colour scheme

% draw electrode workspace
g_x_min = min(xGrid(:));
g_x_max = max(xGrid(:));
g_y_min = min(yGrid(:));
g_y_max = max(yGrid(:));
elec_x_min = min(D.x);
elec_x_max = max(D.x);
elec_y_min = min(D.y);
elec_y_max = max(D.y);
pl_x = [elec_x_min, elec_x_min, elec_x_max, elec_x_max, g_x_max, g_x_max, g_x_min, g_x_min,g_x_min];
pl_y = [g_y_min, elec_y_max, elec_y_max, g_y_min, g_y_min, g_y_max, g_y_max, g_y_min, g_y_min];

imagesc(xGrid, yGrid, M.hd.z); % Display interpolated data
% hold on
% fill(pl_x,pl_y,'w','FaceAlpha', param.plt.FaceAlpha/2)
% hold off

set(gca, 'YDir', 'normal'); % Flip Y-axis for correct orientation
colormap('jet');           % Set colormap (e.g., 'jet', 'parula', 'hot')
ylabel('dist-prox length (m)');
xlabel('circumference (deg)');
title('HD simulation');
axis square

subplot(1,2,2)
imagesc(xGrid, yGrid, M.mes.z); % Display interpolated data
% hold on
clr_now = clr(floor(D.z*100+1),:);
% scatter3(D.x, D.y, D.z, param.plt.disc_size, clr_now, "filled", LineWidth = param.plt.LineWidth, MarkerEdgeColor= param.plt.MarkerEdgeColor);
% fill(pl_x,pl_y,'w','FaceAlpha', param.plt.FaceAlpha)
% hold off

set(gca, 'YDir', 'normal');
colormap('jet');
ylabel('dist-prox length (m)');
xlabel('circumference (deg)');
title('measured');
axis square
drawnow

%%%%%%%%%%%%%%%%%%%%%%%%
% submit the data to GP
opts = statset('fitrgp');
opts.TolFun = 1e-5;

query_idx = 6; % First query point
sparse_idx = 1:5:param.sim.n;

% Combine Dx, Dy into coordinates matrix
query_points = [D.x, D.y];

% Preallocate storage for results
best_y = max(D.z); % Initialise best observed value

% Custom squared exponential kernel function with transformations
custom_kernel = @(X1, X2, theta) squared_exponential_kernel(X1, X2, theta);

% Initial kernel parameters: [param.gp.length_scale, scaling_factor, rotation, dx, dy]
kernel_params = [param.gp.length_scale, 1, 0, 0, 0]; % Initial guesses

% Precompute transformed sparse grid coordinates
sparse_x = M.hd.x(sparse_idx, sparse_idx);
sparse_y = M.hd.y(sparse_idx, sparse_idx);
sparse_coords = [sparse_x(:), sparse_y(:)];
T = create_affine_transformation(kernel_params(2), kernel_params(3), kernel_params(4:5));
transformed_sparse_coords = apply_affine_transform(sparse_coords, T);
transformed_sparse_x = reshape(transformed_sparse_coords(:, 1), size(sparse_x));
transformed_sparse_y = reshape(transformed_sparse_coords(:, 2), size(sparse_y));

% Helper function for interpolation
basis_function_interp = @(X) interp2( ...
    transformed_sparse_x, ...
    transformed_sparse_y, ...
    M.hd.z(sparse_idx, sparse_idx), ...
    X(:, 1), X(:, 2), 'linear', 0);

figure(2)
% Loop through each query point and compute kernel with EI guidance
for i = 1:length(D.z)

    % Current query points up to iteration i
    X_query = [D.x(query_idx, 1), D.y(query_idx, 1)]; % Queried points
    Y_query = D.z(query_idx, 1); % Corresponding values

    % Transform grid coordinates
    grid_coords = [M.hd.x(:), M.hd.y(:)];
    transformed_grid_coords = apply_affine_transform(grid_coords, T);
    transformed_x = reshape(transformed_grid_coords(:, 1), size(M.hd.x));
    transformed_y = reshape(transformed_grid_coords(:, 2), size(M.hd.y));

    % Compute residuals for Y_query
    Y_query_residual = D.z(query_idx) - interp2(transformed_x, transformed_y, M.hd.z, D.x(query_idx), D.y(query_idx), 'linear', 0);

    % Compute prior mean values at query points
    prior_mean = interp2(M.hd.x, M.hd.y, M.hd.z, D.x, D.y, 'linear', 0);

    % Use prior mean as Beta coefficients for the basis function
    beta_coefficients = prior_mean;

    % Fit the GP model with optimisable kernel parameters
    gp_model = fitrgp(X_query, Y_query_residual, ...
        'KernelFunction', @(X1, X2, theta) squared_exponential_kernel(X1, X2, theta), ...
        'KernelParameters', kernel_params, ...
        'Sigma', 0.01, ...
        'SigmaLowerBound',1e-3,...
        'Verbose', 1, ...
        'Optimizer', 'lbfgs', ...
        'OptimizerOptions', opts);

    % Update the map and EI
    [m_residual_pred, s_pred, ei_values] = expected_improvement([M.hd.x(:), M.hd.y(:)], gp_model, best_y);
    m_pred = m_residual_pred + interp2(transformed_x, transformed_y, M.hd.z, M.hd.x(:), M.hd.y(:), 'linear', 0); % Add prior map back to predicted residuals

    M.pred.z(:, :, 1) = reshape(m_pred, param.sim.n, param.sim.n);

    % Visualise
    subplot(5, 6, i)
    imagesc(M.hd.x(1, :), M.hd.y(:, 1), M.pred.z(:, :, 1))
    hold on
    clr_now = clr(floor(D.z(query_idx)*100+1),:);
    scatter3(D.x(query_idx, 1), D.y(query_idx, 1), D.z(query_idx, 1), param.plt.disc_size, clr_now, "filled", LineWidth = param.plt.LineWidth, MarkerEdgeColor=param.plt.MarkerEdgeColor);
    % fill(pl_x,pl_y,'w','FaceAlpha', param.plt.FaceAlpha)
    hold off

    title(sprintf("Predicted map at query %02d", i))
    set(gca, 'YDir', 'normal');
    colormap('jet');
    ylabel('dist-prox length (m)');
    xlabel('circumference (deg)');
    drawnow

    % Select the next query point with maximum EI
    [~, max_idx] = max(ei_values); % Find maximum EI among unqueried points
    q_next = [M.hd.x(:), M.hd.y(:)];
    q_next = q_next(max_idx, :);

    if i < size(query_points,1)
        % Find the nearest unqueried point
        query_points(query_idx, :) = nan; % remove the queries samples from the next query
        distances = sum((query_points - q_next).^2, 2);
        [~, min_idx] = min(distances);
        while ismember(min_idx, query_idx)
            min_idx = randi(size(query_points,1));
        end
        query_idx = [query_idx; min_idx]; % Add query point
    end

    % Update best observed value if needed
    best_y = max(best_y, D.z(i));
end

