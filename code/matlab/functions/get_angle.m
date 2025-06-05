function angles = get_angle(points)
% Compute vectors between adjacent points
vectors = diff(points, 1, 1); % Compute differences between rows

% Compute angles between adjacent vectors
numAngles = size(vectors, 1) - 1; % Number of angles to compute
angles = zeros(numAngles, 1); % Preallocate angles array

for i = 1:numAngles
    v1 = vectors(i, :);
    v2 = vectors(i+1, :);

    % Compute dot product
    dotProd = dot(v1, v2);

    % Compute magnitudes
    mag1 = norm(v1);
    mag2 = norm(v2);

    % Compute angle in radians
    angles(i) = acos(dotProd / (mag1 * mag2));
end

end
