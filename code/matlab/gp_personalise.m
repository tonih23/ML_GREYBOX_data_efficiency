function gp_personalise
    % Parameters and Hyperparameters
    fpath.code =  fullfile(fileparts(mfilename('fullpath')));
    fpath.main = fullfile(fpath.code,"..","..");
    fpath.result = fullfile(fpath.main, "model");
    fpath.save = fullfile(fpath.result,"fd_model.mat");
    dataPath = 'C:\Users\Rehyb\Desktop\FES_AutoCalib\Wesenick-bachelor-2024\data';

    realDataFile = fullfile(dataPath, 'FES_experimental_data.mat');
    addpath('C:\Users\Rehyb\Desktop\FES_AutoCalib\Wesenick-bachelor-2024\code\matlab\functions');

    %Parameters for elec personalisation. Assume like this is a noisy transformation problem. 
    param.scalingFactor = 1.0; % Scaling factor
    param.rotationAngle = 0; % Rotation angle in degrees
    param.translationVector = [0, 0]; % Translation vector [dx, dy]
    
    %Hyperparameters
    param.convergenceThreshold = 0.01; % Threshold for uncertainty to stop iterations
    param.maxIterations = 160; % Maximum number of iterations
    param.weightDecayRate = 10; % Rate of decay for prior weight based on real data points
    param.gpSigma = 0.1; % Noise level for GPR model
    param.finger = "index"; % finger name
    
    % Step 1: Load the high-density geometric map
    % The high-density geometric map provides a detailed representation of expected FES responses. This map serves as a prior knowledge base, offering 
    % a reference to guide personalisation and reduce the number of real-world observations needed.
    temp = load(fpath.save); %See main_sim.m for how the data is saved. The same map but this is not the "full" map as you had it. 
    highDensityMap = temp.p_map.(param.finger).elec; % index
    param.highDensityGridSize = size(highDensityMap); % Size of the high-density grid
   
    [X, Y] = meshgrid(1:param.highDensityGridSize(2), 1:param.highDensityGridSize(1)); % Create the grid for the high-density map
    % [X, Y] = meshgrid(1:param.highDensityGridSize(1), 1:param.highDensityGridSize(2)); % Create the grid for the high-density map
    % X_prior = [Y(:), X(:)]; % Flatten the grid into a list of input points
    X_prior = [X(:), Y(:)]; % Flatten the grid into a list of input
    %points: swapped X and Y for correct prior add
    Y_prior = highDensityMap(:); % Corresponding activation values
    
    % Step 2: Define initial real data (personalised observations)
    % Initial real data points are selected based on their proximity to high-probability areas in the high-density map.
    % These points are strategically chosen to provide a good starting point for the Gaussian Process personalisation process,
    % ensuring that early iterations are informed by meaningful data.
    
    
    realDataFile = fullfile(dataPath, 'FES_experimental_data.mat');
        if ~isfile(realDataFile)
            error('Real data file not found: %s', realDataFile);
        end
        realData = load(realDataFile); % Load the marker data
        cathodeActivationLevels = realData.cathodeActivationLevels;

        % cathodeActivationLevels = realData.cathodeActivationLevels; 
        % indexFingerActivations = cathodeActivationLevels(2, :); % Second row for the index finger
        % 
        % markerIndices = find(indexFingerActivations); % Get non-zero marker indices (positions)
        % realDataPoints = markerIndices(:); % Marker positions as X values
        % realDataResponses = indexFingerActivations(markerIndices)'; % Activation levels as Y values
    %%%%

     %elec_ini = [1,2,3,4,5,6,7,8,9,10,11,12,13,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];% Initial sparse "real"electrode positions in hd map to seed GP (e.g., high prob on the hd map)
     %elec_ini = [32,29, 24,22,17,2,11,4,3,27,20];
     elec_ini = [32,29,8,1];
    

     temp = load(fullfile(fpath.code,"map.mat")); % load the elec maps
     map = temp.map.real; % "real" elec map corresponding to hd map
     

     a = find(ismember(map, elec_ini));
     num_ini= length(a);
    
     realDataPoints = [];
     realDataPoints(:,1) = floor(a/param.highDensityGridSize(1))+1; % elec ini in (x, y)
     realDataPoints(:,2) = rem(a,param.highDensityGridSize(1));

     disp(realDataPoints(:,1))
     disp(realDataPoints(:,2))
     
     realDataResponses = zeros(num_ini, 1);

     for i = 1:num_ini
         X_real = realDataPoints(i,:);
         elec_indx= map_marker(X_real, "osim2real");
         realDataResponses(i) = cathodeActivationLevels(2,elec_indx);
     end
        
     X_real =realDataPoints;
     Y_real = realDataResponses; % Observed responses as a column vector
    
     disp(X_real);
     disp(Y_real);
    
    
    % Step 3: Initialise variables
    % These variables are critical for controlling the iterative loop.
    % 'iteration' keeps track of the number of iterations to ensure the process does not exceed the maximum allowed.
    % 'converged' is a boolean flag indicating whether the stopping criterion (based on uncertainty threshold) has been met.
    iteration = 0;
    converged = false;

    if ~exist('usedQueryPoints', 'var')
        usedQueryPoints = []; % Keeps track of all previously used query points
    end
    
    % Step 4: Start iterative process
        while ~converged && iteration < param.maxIterations
                iteration = iteration + 1;
            
                % Dynamically adjust weights based on number of real data points
                weightPrior = exp(-numel(Y_real) / param.weightDecayRate); % Decay prior weight as real data grows.
                % This parameter ensures that the contribution of the high-density map (prior) diminishes as more personalised data points (real) are collected.
                weightReal = 1 - weightPrior; % Real data weight complements prior weight
            
                % Combine prior and real data for GPR training.
                % Combining X_prior and X_real ensures that the high-density map (prior) is integrated with the observed real data,
                % allowing the Gaussian Process model to adapt its predictions based on both prior knowledge and personalised observations.
                X_combined = [X_prior; X_real];
                Y_combined = [Y_prior; Y_real];

            
                % Train GPR model using custom kernel
                % The Gaussian Process Regression (GPR) model is responsible for updating the personalised map. It uses the
                % combined data (prior and real observations) to make predictions and assess uncertainties, ensuring that the
                % personalised map reflects both the high-density prior knowledge and the individualised real data.
                kernelParams = [param.scalingFactor, param.rotationAngle, param.translationVector(1), param.translationVector(2), weightPrior, weightReal];
                gprModel = fitrgp(X_combined, Y_combined, ...
                    'KernelFunction', @weightedKernel, ...
                    'KernelParameters', kernelParams, ...
                    'BasisFunction', 'none', ...
                    'Sigma', param.gpSigma);
            
                % Predict the personalised FES map and uncertainty
                % X_test = [Y(:), X(:)];
                X_test = [X(:), Y(:)];
                [Y_pred, Y_std] = predict(gprModel, X_test); % Predict responses and uncertainties for the entire grid
                personalisedMap = reshape(Y_pred, size(X)); % Reshape predictions back to grid format: X should have size 10 x 16 not 16 x 10
            
                % Select next query point based on highest  uncertainty%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % [maxUncertainty, maxUncertaintyIdx] = max(Y_std);
                % nextQueryPoint = X_test(maxUncertaintyIdx, :); % Select the point with the highest uncertainty
               
                [~, sortedUncertaintyIdx] = sort(Y_std, 'descend'); % Sort uncertainty in descending order
                nextQueryPoint = []; % Initialize
                for idx = 1:length(sortedUncertaintyIdx)
                    candidateQueryPoint = X_test(sortedUncertaintyIdx(idx), :); % Get the candidate point
                    
                    % Check if the candidate point has already been used
                    if isempty(usedQueryPoints) || ~ismember(candidateQueryPoint, usedQueryPoints, 'rows')
                        nextQueryPoint = candidateQueryPoint; % Select the point
                        maxUncertainty = Y_std(sortedUncertaintyIdx(idx));
                        break; % Exit loop after finding a valid point
                    end
                end
            
                fprintf('Iteration %d: Next query point: X = %.2f, Y = %.2f, Max Uncertainty = %.4f\n', iteration, nextQueryPoint(1), nextQueryPoint(2), maxUncertainty);
               
                usedQueryPoints = [usedQueryPoints; nextQueryPoint];
                
                % Store uncertainty for each iteration
                if ~exist('Y_std_history', 'var')
                    Y_std_history = {}; % Initialize storage
                end
                Y_std_history{iteration} = Y_std; % Save uncertainty for current iteration
                           
                
                electrodeIdx = map_marker(nextQueryPoint, "osim2real");   
                
                disp(electrodeIdx);

                if isempty(electrodeIdx) || isnan(electrodeIdx) || electrodeIdx <= 0 || electrodeIdx > size(cathodeActivationLevels, 2)
                        fprintf('Invalid or unmapped electrode index for query point. Finding closest electrode.\n');
                    
                        % Find all valid electrodes (non-NaN in the map)
                        validElectrodes = find(~isnan(map)); % Indices of all valid electrodes
                        [gridY, gridX] = ind2sub(size(map), validElectrodes); % Convert to grid positions
                        
                        % Map column (gridX) to angles (0° to 337.5°)
                        gridX_angles = (gridX - 1) * 22.5; % Map gridX to angles
                        
                        % Extract query point values
                        queryY = nextQueryPoint(2); % Distance along X-axis (row index)
                        queryX = nextQueryPoint(1); % Angle column index
                        
                        % Map query column index to angle
                        queryAngle = (queryX - 1) * 22.5; % Convert column index to angle
                        
                        % Compute angular distances with wrap-around
                        angularDistances = abs(gridX_angles - queryAngle); % Difference in angles
                        angularDistances = min(angularDistances, 360 - angularDistances); % Handle wrap-around
                        
                        % Compute physical distances along the X-axis (row index)
                        xDistances = abs(gridY - queryY); % Physical distances
                        
                        % Calculate the total distance metric (Euclidean distance)
                        distances = sqrt(angularDistances.^2 + xDistances.^2);
                        
                        % Find the closest electrode with a valid activation level
                        [~, closestIdx] = min(distances); % Index of the closest electrode
                        closestElectrode = map(validElectrodes(closestIdx)); % Map back to real electrode index
                        closestElectrodePos = [gridX(closestIdx), gridY(closestIdx)]; % 2D position of the closest electrode
                        disp(closestElectrode);
                        
                        % Retrieve the activation level of the closest electrode
                        if closestElectrode > 0 && closestElectrode <= size(cathodeActivationLevels, 2)
                            newResponse = cathodeActivationLevels(2, closestElectrode); % Use index finger activation
                            fprintf('Using closest electrode %d with activation %.4f.\n', closestElectrode, newResponse);
                        
                            % Update the next query point to the closest electrode position
                            nextQueryPoint = closestElectrodePos; % Update query point
                            disp(nextQueryPoint);
                        else
                            % Fallback: Use prior data if no valid mapping
                            fprintf('Fallback to prior data for query point.\n');
                            gridIdx = sub2ind(param.highDensityGridSize, round(nextQueryPoint(2)), round(nextQueryPoint(1)));
                            newResponse = Y_prior(gridIdx);
                        end
                    end
                
                    % Add the new query point to the real data  
                    noiseLevel = 0.01; % Standard deviation of the noise

                        if newResponse > 0
                            noisyResponse = newResponse + noiseLevel * randn() %Add nnmoise to electrode activation 
                        else
                            noisyResponse = newResponse;
                        end
        
                    X_real = [X_real; nextQueryPoint]; % Add the new query point to the real data
                    Y_real = [Y_real; noisyResponse]; % Add the new response to the real data
                    %Y_real = [Y_real; newResponse]; % Add the new response to the real data
                    
                        % 
                        % disp(X_real);
                        % disp(Y_real)
        
                        % Check convergence
                        if maxUncertainty < param.convergenceThreshold
                                converged = true;
                                fprintf('Converged at iteration %d.\n', iteration);
                        end
                
             end
        
        
    % Step 5: Visualise the final personalised map and uncertainties 
              
                
        
        % Extract activation levels for all valid electrodes
        elec_ini = 1:32; % All valid electrodes
        realDataResponses = cathodeActivationLevels(2, elec_ini); % Activation levels for index finger
        
        % Load the real map from the file
        temp = load(fullfile(fpath.code, "map.mat"));
        map = temp.map.real;
        
        % Find positions of all electrodes in the map
        a = find(ismember(map, elec_ini)); % Indices of all electrodes in the map
        
        % Convert linear indices to 2D positions
        [Y_real, X_real] = ind2sub(size(map), a); % (Y, X) coordinates of electrodes
        
        % Ensure proper mapping of activation levels
        mappedActivationLevels = zeros(length(a), 1);
        for i = 1:length(a)
            electrodeIdx = map(Y_real(i), X_real(i)); % Extract the electrode index from the map
            mappedActivationLevels(i) = realDataResponses(electrodeIdx); % Assign the correct activation level
        end
        
        % Create a blank grid for the heatmap
        gridSize = size(map); % Grid size of the map
        [X_grid, Y_grid] = meshgrid(1:gridSize(2), 1:gridSize(1)); % Create a grid for interpolation
        heatmapGrid = zeros(gridSize); % Initialize the heatmap grid
        
        % Define Gaussian spread parameters
        sigma = 2; % Standard deviation for the Gaussian spread
        
        % Add Gaussian contributions for each known activation level
        for i = 1:length(X_real)
            % Compute Gaussian contribution for each point
            distSquared = (X_grid - X_real(i)).^2 + (Y_grid - Y_real(i)).^2; % Squared Euclidean distance
            gaussianContribution = mappedActivationLevels(i) * exp(-distSquared / (2 * sigma^2));
            
            % Add contribution to the heatmap grid
            heatmapGrid = heatmapGrid + gaussianContribution;
        end
        
        % Normalize the heatmap for better visualization
        heatmapGrid = heatmapGrid / max(heatmapGrid(:));
        
        % Plot the heatmap
        figure;
        imagesc(heatmapGrid);
        colorbar;
        title('Index Finger Activation Levels Heatmap');
        xlabel('Angle (Y)');
        ylabel('Distance (X)');
        colormap(jet);
        
        % Reverse the Y-axis direction
        % set(gca, 'YDir', 'reverse');
        % 
        % % Customize Y-axis tick positions and labels
        % gridSize = size(heatmapGrid); % Get the size of the heatmap grid
        % maxDistance = 10; % Define the maximum distance (distance at Y=0)
        % yticks(1:gridSize(1)); % Set Y-axis ticks to match rows of the grid
        % yticklabels(fliplr(linspace(1, maxDistance, gridSize(1)))); % Create decreasing labels (10 -> 1)
        
        % Overlay the original data points
        hold on;
        scatter(X_real, Y_real, 100, mappedActivationLevels, 'filled', 'MarkerEdgeColor', 'k'); % Overlay original points
        hold off;
        
        % Add grid lines for clarity
        grid on;

        % Add grid lines for clarity
        figure;
        % High-Density Geometric Map
        subplot(2, 2, 1);
        imagesc(highDensityMap);
        colorbar;
        title('High-Density Geometric Map');
        xlabel('Angle Y'); ylabel('Distance X');
        
        % Uncertainty Map for the ? Iteration
        subplot(2, 2, 3);
        iter=1;
        Y_std_iter = Y_std_history{iter}; % Store the first iteration uncertainty
        imagesc(reshape(Y_std_iter, size(X))); % Reshape to grid
        colorbar;
        title(sprintf('Uncertainty Heatmap - Iteration %d', iter));;
        xlabel('X'); ylabel('Y');
        
        % Uncertainty Map for the Last Iteration
        subplot(2, 2, 4);
        Y_std_last = Y_std_history{end}; % Store the last iteration uncertainty
        imagesc(reshape(Y_std_last, size(X))); % Reshape to grid
        colorbar;
        title('Uncertainty Heatmap - Last Iteration');
        xlabel('X'); ylabel('Y');
        
        % Final Personalized Map
        subplot(2, 2, 2);
        imagesc(personalisedMap);
        colorbar;
        title('Personalized FES Map - Final Iteration');
        xlabel('Angle Y'); ylabel('Distance X');
        
       
     

        
end



% Define a weighted kernel function with transformations
function K = weightedKernel(X1, X2, theta)
    % Extract transformation parameters and weights from theta
    scalingFactor = theta(1);
    rotationAngle = theta(2);
    translationVector = transpose(theta(3:4));
    weightPrior = theta(5);
    weightReal = theta(6);

    % Ensure inputs are in the correct format
    if size(X1, 2) < 2 || size(X2, 2) < 2
        error('Input data must have at least 2 columns for transformation.');
    end

    % Apply transformations
    R = [cosd(rotationAngle), -sind(rotationAngle); sind(rotationAngle), cosd(rotationAngle)]; % Rotation matrix

    % Scale, rotate, and translate
    X1_transformed = (X1(:, 1:2) * scalingFactor) * R + repmat(translationVector, size(X1, 1), 1);
    X2_transformed = (X2(:, 1:2) * scalingFactor) * R + repmat(translationVector, size(X2, 1), 1);

    % Compute the squared Euclidean distance
    D = pdist2(X1_transformed, X2_transformed).^2;

    % Combine weights into the kernel
    % This kernel integrates prior and real data by combining their weighted contributions.
    % The weights (weightPrior, weightReal) are dynamically adjusted to balance the influence of the high-density map and real data.
    K = weightPrior * exp(-0.5 * D) + weightReal * exp(-0.5 * D);
end
