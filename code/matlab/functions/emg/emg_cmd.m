function EMG = emg_cmd(what, param, EMG)
switch what
    case "initialise"

        fprintf("EMG at %s being initialised...\n", param.com)
        EMG.device = serialport(param.com, param.baud, "Timeout", 0.5);

        configureTerminator(EMG.device,'CR/LF');pause(0.1);


        EMG.cmd.ini = "iam DESKTOP";
        EMG.cmd.battery = "battery ? ";
        EMG.cmd.time = "rtc *date %s *time %s";


        EMG.cmd.acq = sprintf("acq config *freq %d *channels 0x%s *type %s *gain %d *input %s", param.fs, param.channel_hex, param.type, param.gain, param.input);
        EMG.cmd.stream_on  = "acq stream on";
        EMG.cmd.stream_off  = "acq stream off";

        EMG.cmd.start = "acq on";
        EMG.cmd.stop = "acq off";

        write_emg(EMG.device, EMG.cmd.ini);
        write_emg(EMG.device, EMG.cmd.battery);

        param.time = datetime('now', 'Format', 'HH:mm:ss');
        cmd = sprintf("rtc *date %s *time %s", param.date, param.time);
        write_emg(EMG.device, cmd);

        while EMG.device.NumBytesAvailable>0
            readline(EMG.device)
        end

end