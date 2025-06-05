function close_osim
% force close osim visualiser as vis.shutdown doesn't work
[~, cmdout] = system('powershell "Get-Process | Where-Object {$_.MainWindowTitle -ne ''''} | Select-Object MainWindowTitle"');
lines = split(cmdout, newline);
for i = 1:length(lines)
    if contains(lines{i}, 'OpenSim 4.5')
        % Extract the window title
       % fprintf('Closing window: %s\n', strtrim(lines{i}));
        system('taskkill /F /FI "WINDOWTITLE eq OpenSim 4.5*" > NUL 2>&1');
    elseif contains(lines{i}, 'Simbody')
      %  fprintf('Closing window: %s\n', strtrim(lines{i}));
        system('taskkill /F /FI "WINDOWTITLE eq Simbody*" > NUL 2>&1');
    end
end
end
