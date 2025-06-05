function param = get_stimPos(param, markers, i)

anode = param.seq.anode{i};
cathode = param.seq.cathode{i};

for i = 1:size(anode,2)
    s_anode = sprintf("marker_%03d", anode(i));
    param.now.anode(i,:) = markers.(s_anode);
end
for i = 1:size(cathode,2)
    s_cathode = sprintf("marker_%03d", cathode(i));
    param.now.cathode(i,:) = markers.(s_cathode);
end

end