%% Correct Distance Calculation for a Finite Line Segment
function d = compute_distance_to_segment(points, P1, P2)
    % Vector along the segment
    lineVec = P2 - P1;
    lineLengthSquared = dot(lineVec, lineVec); % Squared length of the segment

    % Compute distance for each point
    d = zeros(size(points, 1), 1);
    for i = 1:size(points, 1)
        P = points(i, :); % Current grid point
        % Vector from P1 to P
        vec_P1P = P - P1;
        
        % Compute projection scalar t (clamped to [0,1] for segment constraint)
        t = max(0, min(1, dot(vec_P1P, lineVec) / lineLengthSquared));

        % Compute the closest point on the segment
        closestPoint = P1 + t * lineVec;
        
        % Compute perpendicular distance
        d(i) = norm(P - closestPoint);
    end
end
