function [Osim, pos_joint] = add_markers(Osim, param)
import org.opensim.modeling.*

% Get Joints
jointA = Osim.model.getJointSet().get('elbow');
jointB = Osim.model.getJointSet().get('wrist_hand');

% Get Transformations
frameA = jointA.getParentFrame();
frameB = jointB.getParentFrame();
transformA = frameA.getTransformInGround(Osim.state);
transformB = frameB.getTransformInGround(Osim.state);

% Extract Positions
posA = transformA.p(); % Position of JointA in Ground
posB = transformB.p(); % Position of JointB in Ground

% Convert to MATLAB-friendly format
pA = [posA.get(0), posA.get(1), posA.get(2)];
pB = [posB.get(0)-0.03, posB.get(1), posB.get(2)+0.02];
pos_joint = [pA;pB];

% Compute the vector and segment length
vecAB = pB - pA;
lengthAB = norm(vecAB);
unitVecAB = vecAB / lengthAB; % Unit vector along the line

% Number of points along the line (every 1 cm)

numPoints = floor(lengthAB / param.marker.spacing);

% Circle parameters

angles = 0:param.marker.ang_res:360-param.marker.ang_res; % 30-degree intervals
numMarkersPerPoint = length(angles);

% Get radius Body
radiusBody = Osim.model.getBodySet().get('radius'); % Ensure this exists in your Osim.model

% Get Transform of radius in Ground Frame
radiusTransform = radiusBody.getTransformInGround(Osim.state);

radiusTranslation = radiusTransform.p(); % Translation vector

% Convert to MATLAB-friendly format
radiusTranslationVec = [radiusTranslation.get(0), radiusTranslation.get(1), radiusTranslation.get(2)];

% Create OpenSim Marker Set
markerSet = Osim.model.getMarkerSet;

% Generate Markers
markerIndex = 0;

lp_n = numMarkersPerPoint*(numPoints+1); % total loop count

for i = 0:numPoints
    % Compute base point along the line
    basePoint = pA + (i * param.marker.spacing * unitVecAB);

    % Compute perpendicular vectors
    normalVec = [0, 0, 1]; % Arbitrary normal
    if abs(dot(normalVec, unitVecAB)) > 0.9
        normalVec = [0, 1, 0]; % Adjust if too aligned
    end
    perpVec1 = cross(unitVecAB, normalVec);
    perpVec1 = perpVec1 / norm(perpVec1); % Normalize
    perpVec2 = cross(unitVecAB, perpVec1); % Second perpendicular vector

    % Generate circular markers
    for theta = angles
        angleRad = deg2rad(theta);
        circleOffset = param.marker.radius * (cos(angleRad) * perpVec1 + sin(angleRad) * perpVec2);
        markerPosGlobal = basePoint + circleOffset;

        % Convert to Local Frame of radius Body
        % Apply inverse translation
        markerPosRelative = markerPosGlobal - radiusTranslationVec;

        marker_label = lp_n-markerIndex;
        if marker_label <= param.marker.n 
            % Create Marker
            m = Marker();
            m.setName(sprintf("marker_%03d", marker_label));
            m.setParentFrame(radiusBody); % Attach to radius
            m.setParentFrameName("/bodyset/radius"); %
            m.set_location(Vec3(markerPosRelative(2), -markerPosRelative(1), markerPosRelative(3)));

            % Add to Marker Set
            markerSet.cloneAndAppend(m);
        end
        markerIndex = markerIndex + 1;
    end
end
Osim.model.finalizeConnections();
