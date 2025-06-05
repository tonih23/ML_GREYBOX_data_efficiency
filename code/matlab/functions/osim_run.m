function [osim, Motion] = osim_run(what, param, P, osim)
import org.opensim.modeling.*

switch what
    case "initialise"
        rng(0) % make it repeatable

        warning off
        % Load file paths
        fpath.main = "C:\Users\sendo\Desktop\git\Wesenick-bachelor-2024\";
        fpath.code = fullfile(fpath.main, "code");
        fpath.result = fullfile(fpath.main, "model");
        fpath.save = fullfile(fpath.result,"fd_model.mat");
        fpath.osim.main = fullfile(fpath.main, "code", "opensim");
        fpath.osim.model_name = 'wrist_fes.osim'; % Replace with your file path
        fpath.osim.model = fullfile(fpath.osim.main, fpath.osim.model_name);

        addpath(genpath(fpath.code));
        addpath(genpath(fpath.osim.main));

        % Load OpenSim model
        osim.model = Model(fpath.osim.model);

        % Initialize system state
        state = osim.model.initSystem();
        osim.model.equilibrateMuscles(state);

        % Access marker locations and transform to ground frame
        markerSet = osim.model.getMarkerSet();
        numMarkers = markerSet.getSize();
        osim.markers = struct();
        for i = 0:numMarkers-1
            marker = markerSet.get(i);
            markerName = char(marker.getName());
            locationInGroundVec = marker.getParentFrame().expressVectorInGround(state, Vec3(marker.get_location()));
            osim.markers.(markerName) = [locationInGroundVec.get(0), locationInGroundVec.get(1), locationInGroundVec.get(2)];
        end

        % muscle activations based on updated anode-cathode positions
        osim.muscles = osim.model.getMuscles();
        numMuscles = osim.muscles.getSize();

        for j = 0:numMuscles-1
            osim.muscle = osim.muscles.get(j);
            muscleName = char(osim.muscle.getName());
            pathPoints = osim.muscle.getGeometryPath().getPathPointSet();
            numPathPoints = pathPoints.getSize();

            % Iterate through path points
            for k = 0:numPathPoints-1
                pathPoint = pathPoints.get(k);
                parentFrame = pathPoint.getParentFrame();
                locationInParent = pathPoint.getLocation(state);

                locationInGroundVec = parentFrame.expressVectorInGround(state, locationInParent);
                osim.MusclePath.(muscleName).point(k+1,:) = [locationInGroundVec.get(0), locationInGroundVec.get(1), locationInGroundVec.get(2)];
            end
        end
    case "simulate"
        param.thres_dist = 0.01; % (m) electrical field distance for activating muscle
        param.grid = 25; % size of the grid
        
        % Access muscles and calculate activation levels based on distance to the line
        osim.muscles = osim.model.getMuscles();
        numMuscles = osim.muscles.getSize();
         for i = 0:numMuscles-1
            osim.muscle = osim.muscles.get(i);
            muscleName = char(osim.muscle.getName());
            activations.(muscleName) = 0;
        end

        %map real elec to osim markers
        param.marker.anode = map_marker(P.velec.anode, "real2osim");
        param.marker.cathode = map_marker(P.velec.cathode, "real2osim");
        
        % Select anode and cathode markers
        for m = 1:size(param.marker.anode,1)
            for n = 1:size(param.marker.cathode,1)
                s_anode = sprintf("marker_%03d", param.marker.anode(m));
                s_cathode = sprintf("marker_%03d", param.marker.cathode(n));
                anode = osim.markers.(s_anode);
                cathode = osim.markers.(s_cathode);

                mk1 = [anode;cathode];
                for i = 0:numMuscles-1
                    osim.muscle = osim.muscles.get(i);
                    muscleName = char(osim.muscle.getName());
                    pathPoints = osim.muscle.getGeometryPath().getPathPointSet();
                    numPathPoints = pathPoints.getSize();

                    % Iterate through path points
                    minDistance = inf;
                    for j = 1:numPathPoints-1
                        mk2 = [osim.MusclePath.(muscleName).point(j,:); osim.MusclePath.(muscleName).point(j+1,:)];
                        distance = get_dist(mk1 , mk2);
                        minDistance = min(minDistance, distance);
                    end

                    % Determine activation level based on distance
                    if minDistance <= param.thres_dist
                        activationLevel = 1 - (minDistance / param.thres_dist); % Normalize activation level between 0 and 1
                    else
                        activationLevel = 0; % No activation if distance is greater than 1 cm
                    end
                    activations.(muscleName) = activationLevel+activations.(muscleName);
                end
            end
        end

        %% asumme activation has direct correlation with kinematics for now
        Motion.thumb = rad2deg(mean([activations.FPL, activations.APL]));
        Motion.index = rad2deg(mean([activations.FCR, activations.FDSI, activations.FDPI]));
        Motion.middle = rad2deg(mean([activations.PL, activations.FDSM, activations.FDPM]));
        Motion.ring = rad2deg(mean([activations.FDSR, activations.FDPR]));
        Motion.little = rad2deg(mean([activations.FCU, activations.FDSL, activations.FDPL]));
        Motion.ana.ang(1,1,1) = Motion.thumb;
        Motion.ana.ang(1,2,1) = Motion.index;
        Motion.ana.ang(1,3,1) = Motion.middle;
        Motion.ana.ang(1,4,1) = Motion.ring;
        Motion.ana.ang(1,5,1) = Motion.little;
 
end
end


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
