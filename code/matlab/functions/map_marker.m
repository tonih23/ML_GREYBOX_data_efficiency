% function out = map_marker(in, what)
% %param.marker.cathode = map_marker(P.velec.cathode, "real2osim");
%      mapFile = 'C:\Users\Rehyb\Desktop\FES_AutoCalib\Wesenick-bachelor-2024\code\matlab\map.mat';
%     temp = load(mapFile);
%     map = temp.map;
% switch what
%     case "real2osim"
%         idx = ismember(map.real,in);
%         out = map.osim(find(idx));
%     case "osim2real"
%         idx = ismember(map.osim,in);
%         out = map.real(find(idx));
% end


function out = map_marker(nextQueryPoint, what)
    % Load the map
    temp = load("map.mat");
    map = temp.map;

    % Ensure the input is valid
    if size(nextQueryPoint, 2) ~= 2
        error('nextQueryPoint must have 2 elements [X, Y]');
    end

    % Extract the X and Y coordinates
    x = nextQueryPoint(1);
    y = nextQueryPoint(2);

    % Ensure X and Y are within bounds
    if x < 1 || x > size(map.real, 2) || y < 1 || y > size(map.real, 1)
        out = NaN; % Out of bounds, return NaN
        return;
    end

    % Perform mapping based on the map
    switch what
        case "osim2real"
            % Query the map at the given coordinates
            out = map.real(y, x); % Use [Y, X] because of MATLAB's indexing
        case "real2osim"
           % Find the value in the real map that matches the given coordinates
            % `nextQueryPoint` specifies the position in [X, Y]
            if x < 1 || x > size(map.real, 2) || y < 1 || y > size(map.real, 1)
                out = NaN; % Out of bounds, return NaN
                return;
            end

            % Find where the value exists in the map
            [row, col] = find(map.real == map.real(y, x)); % Search for the value in the map
            if isempty(row) || isempty(col)
                out = NaN; % Value not found
            else
                out = sub2ind(size(map.real), row, col); % Convert [row, col] to linear index
            end
            
        otherwise
            error('Invalid mapping type specified. Use "osim2real" or "real2osim".');
    end

    % If the map value is NaN, ensure output is NaN
    if isnan(out)
        fprintf('Map value at (%d, %d) is NaN\n', x, y);
    end
end
