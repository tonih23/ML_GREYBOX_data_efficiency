function out = map_plot_marker(in, what)
%param.marker.cathode = map_marker(P.velec.cathode, "real2osim");
     mapFile = 'C:\Users\endo\Documents\GitHub\Wesenick-bachelor-2024\code\matlab\map.mat';
    temp = load(mapFile);
    map = temp.map;
switch what
    case "real2osim"
        idx = ismember(map.real,in);
        out = map.osim(find(idx));
    case "osim2real"
        idx = ismember(map.osim,in);
        out = map.real(find(idx));
end
