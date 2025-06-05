function param  = load_param(what, param, model)
import org.opensim.modeling.*

switch what
    case "initialise"
        param.main.thres_dist = 0.003; % (m) electrical field distance for activating muscle
        param.main.fingers = {'thumb', 'index', 'middle', 'ring', 'little'};

        param.fes.width = 0.0003; % sec
        param.fes.fq = 30; % fes stim hz
        param.fes.amp_max = 25; %mA

        param.map.dist_sigma = 0.01; % for distance decay gaussian
        param.map.x_lim = 0.25;
        param.map.y_lim = pi;
        param.map.z_lim = pi;

        param.grid = param.map;
        param.grid.n = 25; % size of the grid

        param.cylinder = param.map;
        param.cylinder.radius = 0.045;       % Cylinder radius
        param.cylinder.offset_y = -param.cylinder.radius/2;
        param.cylinder.offset_z = 0;
        param.cylinder.num_theta = 100;  % Angular resolution
        param.cylinder.num_length = 50;       % Length resolution

        param.marker.n = 96; % marker count to be created
        param.marker.spacing = 0.02; % 2 cm
        param.marker.ang_res = 30; %30 deg
        param.marker.radius = 0.04; % 4 cm radius

        param.flag.vis = false;
        param.flag.file_save = true;
        param.flag.model_update = false;

        param.sim.fq = 1000; % hz
        param.sim.td = 3; % duration
        param.sim.setIntegratorAccuracy = 1e-2;

    case "model"
        muscles = model.getMuscles();
        param.model.numMuscles = muscles.getSize();

        markerSet = model.getMarkerSet();
        param.model.numMarkers = markerSet.getSize();
    case "elec"
        a = [] ;
end

end


