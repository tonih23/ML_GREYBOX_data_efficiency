function deviceOutput = bt_close(deviceName)

try
    % Construct the PowerShell command
    powerShellCmd = sprintf('powershell.exe -Command "Get-WmiObject -Class Win32_PnPEntity | Where-Object { $_.Name -match ''%s'' }"', deviceName);
    
    % Execute the PowerShell command
    [~, deviceOutput] = system(powerShellCmd);
    
    % Check if the device is found
    if ~isempty(deviceOutput)
    
        % Release the resources associated with the object
        powerShellReleaseCmd = sprintf('powershell.exe -Command "$device = Get-WmiObject -Class Win32_PnPEntity | Where-Object { $_.Name -match ''%s'' }; $device.Dispose()"', deviceName+char(13));
        [~, releaseOutput] = system(powerShellReleaseCmd);
        
        disp('device object has been released for initialisation.');
    else
        disp('device not found.');
    end
catch
    disp('error in releasing the device.');
end

