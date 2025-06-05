% Function to apply affine transformation
function X_transformed = apply_affine_transform(X, T)
    % Apply affine transformation
    % X: N x 2 matrix of points [x, y]
    % T: 3 x 3 affine transformation matrix

    % Augment X with a column of ones
    X_augmented = [X, ones(size(X, 1), 1)];
    
    % Apply transformation
    X_transformed_augmented = X_augmented * T';
    
    % Extract the transformed 2D coordinates
    X_transformed = X_transformed_augmented(:, 1:2);
end