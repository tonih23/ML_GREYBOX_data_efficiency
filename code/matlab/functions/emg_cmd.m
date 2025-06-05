function EMG = emg_cmd(what, param, EMG)
switch what
    case "initialise"
        while true
            clear EMG

            disp("searching for the EMG device...")

            dv  = bt_close(param.device);
            if ~isempty(dv) % device found
                try
                    fprintf("EMG (%s) being initialised...\n", param.device)
                    EMG.device = bluetooth(param.device+char(13), 1, "Timeout", 60);
                    EMG.device.flush;
                    configureTerminator(EMG.device,'CR/LF');pause(0.1);

                    EMG.cmd.ini = "iam DESKTOP";
                    EMG.cmd.battery = "battery ? ";
                    EMG.cmd.time = "rtc *date %s *time %s";
                    EMG.cmd.acq = sprintf("acq config *freq %d *channels %s *type %s *gain %d", param.fs, param.channel_hex, param.type, param.gain);
                    EMG.cmd.stream_on  = "acq stream on";
                    EMG.cmd.stream_off  = "acq stream off";

                    EMG.cmd.start = "acq on";
                    EMG.cmd.stop = "acq off";

                    write_emg(EMG.device, EMG.cmd.ini);
                    write_emg(EMG.device, EMG.cmd.battery);
                    write_emg(EMG.device, EMG.cmd.acq);

                    param.time = datetime('now', 'Format', 'HH:mm:ss');
                    cmd = sprintf("rtc *date %s *time %s", param.date, param.time);
                    write_emg(EMG.device, cmd);

                    write_emg(EMG.device, EMG.cmd.stream_on);

                    while EMG.device.NumBytesAvailable>0
                        msg =  readline(EMG.device);
                        disp(msg)
                    end
                    disp("initialisation compelte.")
                    break
                catch ME
                    disp(['Error: ', ME.message]);
                end % device available
            end % device found
            pause(1)
        end
end