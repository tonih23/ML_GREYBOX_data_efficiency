function show_elec(h, param, data, what)

switch what
    case "elec"
        axes(h)
        rows = ceil(sqrt(param.elec_n));
        cols = ceil(param.elec_n/rows);

        for i = 1:rows
            for j = 1:cols
                % Calculate the cell number
                cell_number = (i-1)*cols + j;
                if ismember(cell_number, param.cathode)
                    color = [0.2, 0.9, 0.2]; % green
                elseif ismember(cell_number, param.anode)
                    color = [0.9, 0.2, 0.2]; % red
                elseif cell_number > param.elec_n
                    color = [0.2, 0.2, 0.2]; % grey
                else
                    color = [1, 1, 1];
                end

                x = (j-1)/cols;
                y = 1-i/rows;
                width = 1/cols;
                height = 1/rows;

                rectangle('Position', [x, y, width, height], 'FaceColor', color, 'EdgeColor', 'black');
                text(x + width/2, y + height/2, num2str(cell_number), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            end
        end

        % Set axis properties
        axis equal;
        axis off;
    case "score"
        axes(h);
        c = gca;
        t = 1:size(data,1);
        plot(t, data,'o-');
        grid on;
        if isempty(c.Legend)
            legend('grip', 'open')
        end
        xlabel('trial');
        ylabel('score')
    case "emg"
        axes(h);
        plot(data.time, data.v_ch);grid on
        xlabel('time')
        ylabel('emg')
    case "grip"
        axes(h);
        plot(data.time, data.x);grid on
        xlabel('time')
        ylabel('grip score')
end