function writefes(device, cmd)

writeline(device, cmd); pause(0.01); %%.01
fprintf("FES sent: %s\n", cmd);

% while device.NumBytesAvailable> 0
%     msg = readline(device);
%     disp(msg)
% end
% Attempt to read response
% maxAttempts = 5; % Retry up to 5 times
% attempt = 0;


%
% if device.NumBytesAvailable > 0
%     while attempt < maxAttempts
%         attempt = attempt + 1;
%         try
%             % Read available data
%             msg = readline(device);
%             disp("Response received:");
%             disp(msg);
%             % break;  % Exit loop if data is read successfully
%         catch ME
%             % Display the error message and retry if possible
%             disp(['Error while reading data: ', ME.message]);
%             % pause(1); % Pause before retrying
%         end
%         % else
%         %     % No data available, pause and retry
%         %     disp('No data available, retrying...');
%         %     pause(1);  % Wait for a second before retrying
%         % If no data is received after maximum attempts
%         if device.NumBytesAvailable == 0 && attempt == maxAttempts
%             warning('Failed to read any data after %d attempts.', maxAttempts);
%             device.flush;
%         end
%     end
%
%
% end
if device.NumBytesAvailable > 0
    msg = read(device, device.NumBytesAvailable);
    disp(char(msg))
end
end