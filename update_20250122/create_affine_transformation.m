% Function to create affine transformation matrix
function T = create_affine_transformation(scale, rotation, translation)
    % Create affine transformation matrix
    T = [scale * cos(rotation), -scale * sin(rotation), translation(1); ...
         scale * sin(rotation),  scale * cos(rotation), translation(2); ...
         0,                     0,                     1];
end