% Parameters
radius = 0.05; % Cylinder radius in meters
length = 0.20; % Cylinder length in meters
circumference_markers = 16; % Number of markers around circumference
length_markers = 10; % Number of markers along length
output_file = 'markers_cylinder.xml'; % Output XML file

% Calculate positions
angles = linspace(0, 2 * pi, circumference_markers + 1); % Include full circle
angles = angles(1:end-1); % Remove duplicate point
z_positions = linspace(-length / 2, length / 2, length_markers);

% Initialize XML content
xml_content = [];

% Generate markers
marker_id = 1;
for z = z_positions
    for theta = angles
        x = radius * cos(theta)-z/5;
        y = radius * sin(theta)-z/5;
        xml_content = [xml_content ...
            sprintf('        <Marker name="marker_%03d">%s', marker_id, newline), ...
            '            <socket_parent_frame>/bodyset/radius</socket_parent_frame>' newline, ...
            sprintf('            <location>%.5f %.5f %.5f</location>%s', x, z-0.12, y, newline), ...
            '        <fixed>true</fixed>' newline,...
            '        </Marker>' newline];
        marker_id = marker_id + 1;
    end
end

% Close XML structure
% xml_content = [xml_content '    </Markers>' newline '</OpenSimDocument>'];

% Save to file
file_id = fopen(output_file, 'w');
fprintf(file_id, '%s', xml_content);
fclose(file_id);

fprintf('XML file saved to: %s\n', output_file);
