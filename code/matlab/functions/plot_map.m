function h = plot_map(what, varargin)

switch what
    case "initialise"
        markers = varargin{1};
        param = varargin{2};
        % close all

        figure('Name', 'Stimulation Probability Maps');
        for i = 1:length(param.main.fingers)

            h(i) = subplot(2, 3, i);
            plot_map("surf", h(i), param);
            plot_map("elec", h(i), markers);
             plot_map("id", h(i), markers);

            title(param.main.fingers{i});
            zlabel('circumferential (m)'); % Flattened y-z to show on 2D map
            zlabel('prox-distal (m)');
            clim([-1,1]);

            grid on;
            axis equal
        end
        colormap(jet)
        %
        h(6) = subplot(2, 3, 6); % Use the last subplot to visualize the marker IDs

        % plot_map("surf", h(6), param);
        % plot_map("elec", h(6), markers);
        % plot_map("id", h(6), markers);
        % title('marker ID');
        axis off
        colorbar;
        clim([-1,1]);

    case "update"
        h = varargin{1};
        p_image = varargin{2};

        fingerNames = fieldnames(p_image);
        for i = 1:5
            fingerName = fingerNames{i};
            subplot(h(i));

            h(i).Children(end).CData = p_image.(fingerName);
        end
        drawnow;
    case "surf"
        h = varargin{1};
        param = varargin{2};
        subplot(h);

        c = zeros(size(param.cylinder.x));
        cc = surf(param.cylinder.x, param.cylinder.y, param.cylinder.z, c);
        cc.Parent.CLim = [-1,1];
        zlabel('circumferential (m)'); % Flattened y-z to show on 2D map
        zlabel('prox-distal (m)');

        grid on;
        axis equal

    case "elec"
        % Draw the marker grid IDs for visualization
        h = varargin{1};
        markers = varargin{2};

        hold on
        fd = fieldnames(markers);
        for m = 1:size(fd,1)
            markerName = sprintf('marker_%03d', m);
            markerLocation = markers.(markerName);

            markerX = markerLocation(1);
            markerY = markerLocation(2);
            markerZ = markerLocation(3);

            plot3(markerX, markerY, markerZ, 'ko', 'MarkerFaceColor', 'k');
        end
        hold off
    case "id"
        % Draw the marker grid IDs for visualization
        h = varargin{1};
        markers = varargin{2};

        hold on
        fd = fieldnames(markers);
        for m = 1:size(fd,1)
            markerName = sprintf('marker_%03d', m);
            markerLocation = markers.(markerName);

            markerX = markerLocation(1);
            markerY = markerLocation(2);
            markerZ = markerLocation(3);

            text(markerX, markerY, markerZ, sprintf('%d', m), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', [0.2,0.2,0.2]);
        end
        hold off
end
