function M = get_elec(param, markers)

for i = 1:size(param.anode,1)
    s_anode = sprintf("marker_%03d", param.anode(i));
    M.anode(idx,:) = markers.(s_anode);
end
for i = 1:size(param.cathode,1)
    s_cathode = sprintf("marker_%03d", param.cathode(i));
    M.cathode = markers.(s_cathode);
end

end