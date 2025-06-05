function p_map = main
rng(0) % make it repeatable
param.thres_dist = 0.01; % (m) electrical field distance for activating muscle
param.grid = 25; % size of the grid
import org.opensim.modeling.*
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
if ~isfolder(fpath.result)
    mkdir(fpath.result)
end
 
% Load OpenSim model
model = Model(fpath.osim.model);

% Initialize system state
state = model.initSystem();
model.equilibrateMuscles(state);

% Access marker locations and transform to ground frame
markerSet = model.getMarkerSet();
numMarkers = markerSet.getSize();
markers = struct();
for i = 0:numMarkers-1
    marker = markerSet.get(i);
    markerName = char(marker.getName());
    locationInGroundVec = marker.getParentFrame().expressVectorInGround(state, Vec3(marker.get_location()));
    markers.(markerName) = [locationInGroundVec.get(0), locationInGroundVec.get(1), locationInGroundVec.get(2)];
end

% muscle activations based on updated anode-cathode positions
muscles = model.getMuscles();
numMuscles = muscles.getSize();

for j = 0:numMuscles-1
    muscle = muscles.get(j);
    muscleName = char(muscle.getName());
    pathPoints = muscle.getGeometryPath().getPathPointSet();
    numPathPoints = pathPoints.getSize();

    % Iterate through path points
    for k = 0:numPathPoints-1
        pathPoint = pathPoints.get(k);
        parentFrame = pathPoint.getParentFrame();
        locationInParent = pathPoint.getLocation(state);

        locationInGroundVec = parentFrame.expressVectorInGround(state, locationInParent);
        MusclePath.(muscleName).point(k+1,:) = [locationInGroundVec.get(0), locationInGroundVec.get(1), locationInGroundVec.get(2)];
    end
end

%% Create a figure with subplots for each finger to visualize probability map changes
fingers = {'thumb', 'index', 'middle', 'ring', 'little'};

xRange = linspace(0, 0.25, param.grid );
yRange = linspace(-0.08, 0.08, param.grid );
zRange = linspace(-0.08, 0.08, param.grid );

[X, Y, Z] = meshgrid(xRange, yRange, zRange);
pl_y = X(:); % X remains as is
pl_x = atan2d(Z(:), Y(:)); % Compute the angle for the Y-Z plane
[pl_x_grid, pl_y_grid] = meshgrid(unique(pl_x), unique(pl_y));

p_map = struct();
for f = 1:length(fingers)
    fingerName = fingers{f};
    p_map.(fingerName) = zeros(size(Y));
    temp.(fingerName).active = zeros(param.grid ^3,1);
    temp.(fingerName).n =  temp.(fingerName).active;
end

close all

h = plot_pdf(fingers, X, Y, Z);
h(6) = subplot(2, 3, 6); % Use the last subplot to visualize the marker IDs
plot_elec(h(6), markers)

% Access muscles and calculate activation levels based on distance to the line
muscles = model.getMuscles();
numMuscles = muscles.getSize();
activations = struct();

% Iterate through markers to visualize probability map changes

for i = 1:numMarkers*10 %

    %%%% random selection
    param.marker.anode = randi(numMarkers);
    param.marker.cathode =  param.marker.anode;

    while param.marker.anode == param.marker.cathode
        param.marker.cathode = randi(numMarkers); % make it random for now
    end
    %%%%


    % Select anode and cathode markers
    s_anode = sprintf("marker_%03d", param.marker.anode);
    s_cathode = sprintf("marker_%03d", param.marker.cathode);
    anode = markers.(s_anode);
    cathode = markers.(s_cathode);

    mk1 = [anode;cathode];
    for j = 0:numMuscles-1
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

        % Determine activation level based on distance
        if minDistance <= param.thres_dist
            activationLevel = 1 - (minDistance / param.thres_dist); % Normalize activation level between 0 and 1
        else
            activationLevel = 0; % No activation if distance is greater than 1 cm
        end
        activations.(muscleName) = activationLevel;
    end

    %% asumme activation has direct correlation with kinematics for now
    Motion.thumb = mean([activations.FPL, activations.APL]);
    Motion.index = mean([activations.FCR, activations.FDSI, activations.FDPI]);
    Motion.middle = mean([activations.PL, activations.FDSM, activations.FDPM]);
    Motion.ring = mean([activations.FDSR, activations.FDPR]);
    Motion.little = mean([activations.FCU, activations.FDSL, activations.FDPL]);

    % Update the density map using Motion scores
    for f = 1:length(fingers)
        fingerName = fingers{f};
        activationValue = Motion.(fingerName);

        % Identify the grid cells that are covered by the current anode-cathode line
        for xIdx = 1:size(X(:), 1)
            point = [X(xIdx), Y(xIdx), Z(xIdx)];

            distance = get_dist(mk1, point);

            if distance <= param.thres_dist % Width of the stimulation area
                temp.(fingerName).active(xIdx) = temp.(fingerName).active(xIdx) + activationValue*distance/param.thres_dist;
                temp.(fingerName).n(xIdx) = temp.(fingerName).n(xIdx) + 1;
            end
        end

        p_map.(fingerName) = reshape(temp.(fingerName).active./temp.(fingerName).n, param.grid, param.grid, param.grid); % return the average to 3D grid
        p_map.(fingerName)(isnan(p_map.(fingerName))) = 0;

        % Flatten the 3D grid data into pl_x, pl_y, pl_z
        pl_z = p_map.(fingerName)(:); % Extract the corresponding values from the probability density map

        % Convert the data to grid format for contour plotting
        pl_z_grid = griddata(pl_x, pl_y, pl_z, pl_x_grid, pl_y_grid);


        pl_z_grid_smooth = imgaussfilt(pl_z_grid, [0.05,5]);

        subplot(h(f));
        h(f).Children.XData = pl_x_grid;
        h(f).Children.YData = pl_y_grid;
        h(f).Children.ZData = pl_z_grid_smooth;
        drawnow;
    end
end
save(fpath.save,"p_map");
end

%%
function  plot_elec(h, markers)
% Draw the marker grid IDs for visualization
subplot(h);
hold on;
title('marker ID');
xlabel('angle (deg)');
ylabel('length (m)');
grid on;

xlim([-180, 180]);
ylim([0, 0.25]);
fd = fieldnames(markers);
for m = 1:size(fd,1)
    markerName = sprintf('marker_%03d', m);
    markerLocation = markers.(markerName);
    markerY = markerLocation(1);
    markerX = atan2d(markerLocation(3), markerLocation(2)); % flatten 2D as an angle

    plot(markerX, markerY, 'ko', 'MarkerFaceColor', 'k');
    text(markerX, markerY, sprintf('%d', m), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'r');
end
hold off
end

%%
function h = plot_pdf(fingers, X, Y, Z)
figure('Name', 'Stimulation Probability Maps');
pl_y = X(:); % X remains as is
pl_x = atan2d(Z(:), Y(:)); % Compute the angle for the Y-Z plane
pl_z = zeros(size(pl_x));
[pl_x_grid, pl_y_grid] = meshgrid(unique(pl_x), unique(pl_y));
pl_z_grid = griddata(pl_x, pl_y, pl_z, pl_x_grid, pl_y_grid);

for f = 1:length(fingers)
    h(f) = subplot(2, 3, f);
    hold on;
    title(sprintf('Probability Map - %s', fingers{f}));
    xlabel('Position along y-z (deg)');
    ylabel('Height (m)'); % Flattened y-z to show on 2D map
    grid on;

    xlim([-180, 180]);
    ylim([min(X(:)), max(X(:))]);
    zlim([0,1])
    contourf(pl_x_grid, pl_y_grid, pl_z_grid, 'LineStyle', 'none');
    colorbar;
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