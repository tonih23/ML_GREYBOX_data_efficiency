

function distance = get_dist(mk1, mk2)
point1 = mk1(1,:);
point2 = mk1(2,:);
point3 = mk2(1,:);

d1 = point2 - point1; % define direction vectors of line

if size(mk2,1)==2 % line to line
    point4 = mk2(2,:);

    d2 = point4 - point3;

    r = point3 - point1; % Find the vector between the two points (mk1 to mk3)
    cross_d1d2 = cross(d1, d2);

    if norm(cross_d1d2) < 1e-10     % Lines are parallel;
        distance = norm(cross(r, d1)) / norm(d1);
    else
        distance = abs(dot(r, cross_d1d2)) / norm(cross_d1d2);
    end
else % point to line
    r_point = point3 - point1;

    % Calculate the shortest distance from the point to the line
    distance = norm(cross(r_point, d1)) / norm(d1);
end
end
