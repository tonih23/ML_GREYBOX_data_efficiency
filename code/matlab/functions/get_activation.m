function activations = get_activation(param, fes, muscles, MusclePath)
mk1 = [param.now.anode; param.now.cathode];

for j = 0:param.model.numMuscles-1
    muscle = muscles.get(j);
    muscleName = char(muscle.getName());
    pathPoints = muscle.getGeometryPath().getPathPointSet();
    numPathPoints = pathPoints.getSize();

    % Iterate through path points
    minDistance = inf;
    for k = 1:numPathPoints-1
        mk2 = [MusclePath.(muscleName).point(k,:); MusclePath.(muscleName).point(k+1,:)];
        distance = get_dist(mk1 , mk2);
        minDistance = min(minDistance, distance);
    end

    activationLevel = compute_activation(param, fes, minDistance);
    activations.(muscleName) = activationLevel;
end
end

function activationLevel = compute_activation(param, fes, minDistance)
% Determine activation level based on distance
if minDistance <= param.main.thres_dist
    activationLevel = 1 - (minDistance / param.main.thres_dist); % Normalize activation level between 0 and 1
else
    activationLevel = 0; % No activation if distance is greater than 1 cm
end
activationLevel = activationLevel*1;
end
