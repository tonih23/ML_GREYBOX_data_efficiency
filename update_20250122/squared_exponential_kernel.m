function K = squared_exponential_kernel(X1, X2, theta)
    % Extract parameters from theta
    length_scale = theta(1);
    scaling_factor = theta(2);
    rotation_angle = theta(3);
    translation = [theta(4), theta(5)];

    % Create affine transformation matrix
    T = create_affine_transformation(scaling_factor, rotation_angle, translation);

    % Apply transformations to the query points
    X1_transformed = apply_affine_transform(X1, T);
    X2_transformed = apply_affine_transform(X2, T);

    % Compute pairwise distances
    D = pdist2(X1_transformed, X2_transformed, 'euclidean');

    % Apply squared exponential kernel
    K = exp(-D.^2 / (2 * length_scale^2));
end
