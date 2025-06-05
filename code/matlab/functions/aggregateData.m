function aggregateData(dataPath)
  
    % Get all experiment files in the directory
    dataFiles = dir(fullfile(dataPath, 'ReHyb_FESAutoCalib_*.mat'));
    if isempty(dataFiles)
        error('No experiment data files found in the folder: %s', dataPath);
    end

    % Initialize variables
    cathodeLabels = {}; % Use a cell array for cathode labels
    cathodeActivationLevels = zeros(5, 31); % 5 fingers, 29 cathodes
    markerActivationLevels = zeros(5, 160); % 5 fingers, 160 markers
    angles = [];
    mapFile = 'C:\Users\Rehyb\Desktop\FES_AutoCalib\Wesenick-bachelor-2024\code\matlab\map.mat';
    temp = load(mapFile);
    map = temp.map;
   
    % Process each file
    for k = 1:length(dataFiles)
        % Load file
        filePath = fullfile(dataPath, dataFiles(k).name);
        data = load(filePath);

        if isfield(data, 'param') && isfield(data, 'Motion')
            P = data.param.fes.velec;
            meanAngles = max(data.Motion.ana.mean_offset, [], 1, 'omitnan'); % Max angle per finger
            
            % Normalize activation levels
            activationLevelRow = min(max(meanAngles / 35, 0), 1); % Clamp between 0 and 1

             % Map activation levels to cathodes
            for i = 1:length(P.cathode)
                cathodeIdx = P.cathode(i); % Use cathode directly as index
                if cathodeIdx <= size(cathodeActivationLevels, 2)
                    cathodeActivationLevels(:, cathodeIdx) = max(cathodeActivationLevels(:, cathodeIdx), activationLevelRow');
                end
            end
            
            % Map activation levels to markers (just for visualisation)

            markers = map_plot_marker(P.cathode, "real2osim"); % Map cathodes to markers
            for i = 1:length(markers)
                markerIdx = markers(i);
                if markerIdx <= size(markerActivationLevels, 2)
                    markerActivationLevels(:, markerIdx) = max(markerActivationLevels(:, markerIdx), activationLevelRow');
                end
            end
            % Append cathode labels
            cathodeLabels{end + 1} = sprintf('C[%s]', strjoin(string(P.cathode), ','));
            
            % Append angles for plotting
            angles = [angles; meanAngles];
        end
    end
   %%% ADD NonZeroCathodeActivationLevels
            



        % Save aggregated data
    save(fullfile(dataPath, 'FES_experimental_data.mat'), 'cathodeActivationLevels', 'angles', 'cathodeLabels');
    fprintf('Aggregated data saved to: %s\n', fullfile(dataPath, 'FES_experimental_data.mat'));
    
    % Display results
    disp('Marker Activation Levels:');
    disp(markerActivationLevels);
    disp(cathodeActivationLevels);
    disp('Original Angles:');
    disp(angles);
    
    % Plot each finger's activation levels using tiledlayout
    figure;
    t = tiledlayout(3, 2, 'Padding', 'compact', 'TileSpacing', 'compact'); % Adjust layout spacing
    
    fingerNames = {'Thumb', 'Index', 'Middle', 'Ring', 'Little'};
    
        for f = 1:5
            nexttile; % Create a new tile for each subplot
            bar(markerActivationLevels(f, :));
            title(sprintf('%s Activation Levels', fingerNames{f}));
            
            % X-axis settings for markers
            markerIndices = find(markerActivationLevels(f, :) > 0); % Only show non-zero markers
            xticks(markerIndices);
            xticklabels(arrayfun(@(x) sprintf('%d', x), markerIndices, 'UniformOutput', false));
            xtickangle(90);
            
            % Adjust font size for x-tick labels
            ax = gca; % Get current axes
            ax.XAxis.FontSize = 8; % Adjust the font size
            
            xlabel('Markers');
            ylabel('Activation Level (0-1)');
            grid on;
        end
    
    % Plot Original Angles
    nexttile; % Create a new tile for the original angles plot
        hold on;
        for i = 1:size(angles, 2)
            plot(1:length(angles(:, i)), angles(:, i), 'o-', 'DisplayName', sprintf('%s', fingerNames{i}));
        end
    title('Original Angles for Each Finger');
    xticks(1:length(cathodeLabels)); % Match the number of cathode labels
    xticklabels(cathodeLabels); % Use cathode labels for x-axis ticks
    xtickangle(90); % Rotate labels for readability
    xlabel('Cathode Configurations');
    ylabel('Angle (degrees)');
    legend('show');
    grid on;
    hold off;
%  dataPath = 'C:\Users\Rehyb\Desktop\FES_AutoCalib\Wesenick-bachelor-2024\data';
% aggregateData(dataPath);