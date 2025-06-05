function [muscles, MusclePath, muscleName] = get_muscles(model, state)
import org.opensim.modeling.*

muscles = model.getMuscles();
param.numMuscles = muscles.getSize();

for i = 0:param.numMuscles-1
    muscle = muscles.get(i);
    muscleName{i+1} = char(muscle.getName());
    pathPoints = muscle.getGeometryPath().getPathPointSet();
    numPathPoints = pathPoints.getSize();

    % Iterate through path points
    for j = 0:numPathPoints-1
        pathPoint = pathPoints.get(j);
        parentFrame = pathPoint.getParentFrame();
        locationInParent = pathPoint.getLocation(state);

        locationInGroundVec = parentFrame.expressVectorInGround(state, locationInParent);
        MusclePath.(muscleName{i+1}).point(j+1,:) = [locationInGroundVec.get(0), locationInGroundVec.get(1), locationInGroundVec.get(2)];
    end
end

end