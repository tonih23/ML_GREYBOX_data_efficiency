function [stim_data] = FES_GUI()
    % Create the main figure window
    fig = uifigure('Name', 'FES Control Panel', 'Position', [1200, 600, 500, 400]);

    %% GUI Elements for FES Parameters
    uilabel(fig, 'Position', [50, 320, 120, 22], 'Text', 'FES Device:');
    deviceDropdown = uidropdown(fig, 'Items', {'STIM_2_1.default', 'STIM_2_2.default'}, 'Position', [170, 320, 120, 22]);

    uilabel(fig, 'Position', [50, 280, 120, 22], 'Text', 'Electrode Count:');
    elecField = uieditfield(fig, 'numeric', 'Position', [170, 280, 120, 22], 'Value', 32);

    uilabel(fig, 'Position', [50, 240, 120, 22], 'Text', 'Anode Electrodes:');
    anodeField = uieditfield(fig, 'text', 'Position', [170, 240, 120, 22], 'Value', '1, 3, 6');

    uilabel(fig, 'Position', [50, 220, 120, 22], 'Text', 'Cathode Electrodes:');
    cathodeField = uieditfield(fig, 'text', 'Position', [170, 220, 120, 22], 'Value', '4, 5, 9');

    uilabel(fig, 'Position', [50, 200, 120, 22], 'Text', 'Amplitude (mA):');
    ampField = uieditfield(fig, 'numeric', 'Position', [170, 200, 120, 22], 'Value', 8);

    uilabel(fig, 'Position', [50, 180, 120, 22], 'Text', 'Pulse Width (µs):');
    widthField = uieditfield(fig, 'numeric', 'Position', [170, 180, 120, 22], 'Value', 300);

   %% STIM duration elements
    uilabel(fig, 'Position', [50, 140, 120, 22], 'Text', 'Baseline 1 Time (s):');
    baseline1Field = uieditfield(fig, 'numeric', 'Position', [170, 140, 120, 22], 'Value', 1);

    uilabel(fig, 'Position', [50, 120, 120, 22], 'Text', 'Stimulation Duration (s):');
    stimDurationField = uieditfield(fig, 'numeric', 'Position', [170, 120, 120, 22], 'Value', 5);

    uilabel(fig, 'Position', [50, 100, 120, 22], 'Text', 'Baseline 2 Time (s):');
    baseline2Field = uieditfield(fig, 'numeric', 'Position', [170, 100, 120, 22], 'Value', 2);


    % Submit Button
    submitButton = uibutton(fig, 'push', 'Position', [200, 50, 100, 30], 'Text', 'Submit', ...
        'ButtonPushedFcn', @(btn,event) submitFESParams(fig, anodeField, cathodeField, ampField, widthField, baseline1Field, stimDurationField, baseline2Field));

    % Wait for the user to submit
    uiwait(fig);

    % Retrieve stored data from appdata
    stim_data = getappdata(fig, 'stim_data');
    close(fig);
end

function submitFESParams(fig, anodeField, cathodeField, ampField, widthField, baseline1Field, stimDurationField, baseline2Field)
    % Data from the fields
    anodes = str2num(anodeField.Value); %#ok<ST2NM>
    cathodes = str2num(cathodeField.Value); %#ok<ST2NM>
    amps = ampField.Value * ones(1, length(cathodes));
    widths = widthField.Value * ones(1, length(cathodes));

    % Baseline and stimulation durations
    baseline1Time = baseline1Field.Value;
    stimDuration = stimDurationField.Value;
    baseline2Time = baseline2Field.Value;

    % Store the data in appdata
    stim_data = struct('anodes', anodes, ...
                       'cathodes', cathodes, ...
                       'amp', amps, ...
                       'width', widths, ...
                       'baseline1Time', baseline1Time, ...
                       'stimDuration', stimDuration, ...
                       'baseline2Time', baseline2Time);
    setappdata(fig, 'stim_data', stim_data);

    % Resume execution and close GUI
    uiresume(fig);
end
