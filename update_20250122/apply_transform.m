% Function to apply scaling, rotation, and translation to points
function X_transformed = apply_transform(X, scale, rotation, translation)
    % Scaling
    X_scaled = X * scale;

    % Rotation matrix
    R = [cos(rotation), -sin(rotation); sin(rotation), cos(rotation)];
    X_rotated = (R * X_scaled')';

    % Translation
    X_transformed = X_rotated + translation;
end