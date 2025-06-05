function v = get_voltage(channel,param)

% %% two complement format conversion
dm = dec2hex(channel(end-2:end),2); % 3 bypes
ch_dec = hex2dec([dm(1,:),dm(2,:),dm(3,:)]);

if bitget(ch_dec, param.bits) == 1
    data = (bitxor(ch_dec,2^param.bits-1)+1)*-1;
else
    data = ch_dec;
end

%% convert to voltage
v = data * (2*2.048) / (param.gain*2^24); % in volts

end