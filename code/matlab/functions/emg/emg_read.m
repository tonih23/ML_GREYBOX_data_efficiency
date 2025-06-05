function D = emg_read(EMG, fpath, param)
data = read(EMG.device, EMG.device.NumBytesAvailable,'char');
data_int = uint8(data);

save(fullfile(fpath.main, fpath.fname), "data", "data_int");
[D, ~] = emg_unpack(data, param);
end

%%%
function [D, idx] = emg_unpack(data, param)

idx.n = size(data,2);
idx.time_temp = find(data(5:end-(3+4*param.elec_n))==46)+4; % always use the timestamp to navigate

c(1,:) = data(idx.time_temp-4)==10|data(idx.time_temp-4)==13;
c(2,:) = data(idx.time_temp+35)==13;
c(3,:) = data(idx.time_temp+3)==32;
c(4,:) = data(idx.time_temp+7)==32;
c(5,:) = data(idx.time_temp+11)==32;
c(6,:) = data(idx.time_temp+15)==32;
c(7,:) = data(idx.time_temp+19)==32;
c(8,:) = data(idx.time_temp+23)==32;
c(9,:) = data(idx.time_temp+27)==32;
c(10,:) = data(idx.time_temp+31)==32;
idx.time = idx.time_temp(sum(c)==10);

n_data = length(idx.time);
D = table;
D.time = nan(n_data,1);
D.v_ch = nan(n_data,8);

for j = 1:n_data

    idx.dot = idx.time(j);

    ms = data(idx.dot-3:idx.dot-1);  % 3 bypes
    mcs = data(idx.dot+1:idx.dot+2); % 2 bypes

    ch1 = data(idx.dot+4:idx.dot+6); % space+3 bypes
    ch2 = data(idx.dot+8:idx.dot+10);
    ch3 = data(idx.dot+12:idx.dot+14);
    ch4 = data(idx.dot+16:idx.dot+18);
    ch5 = data(idx.dot+20:idx.dot+22);
    ch6 = data(idx.dot+24:idx.dot+26);
    ch7 = data(idx.dot+28:idx.dot+30);
    ch8 = data(idx.dot+32:idx.dot+34);

    %% time
    dm = dec2hex(ms,2);
    millisec = hex2dec([dm(1,:),dm(2,:),dm(3,:)]); % 3 bypes

    dm = dec2hex(mcs); % 2 bypes
    microsec =  hex2dec([dm(1,:),dm(2,:)]);

    %% save in D struct
    D.time(j,1) = millisec + microsec/1000*0;
    D.v_ch(j,1) = get_voltage(ch1,param);
    D.v_ch(j,2) = get_voltage(ch2,param);
    D.v_ch(j,3) = get_voltage(ch3,param);
    D.v_ch(j,4) = get_voltage(ch4,param);
    D.v_ch(j,5) = get_voltage(ch5,param);
    D.v_ch(j,6) = get_voltage(ch6,param);
    D.v_ch(j,7) = get_voltage(ch7,param);
    D.v_ch(j,8) = get_voltage(ch8,param);
end
end
