function p_image = main_sim
rng(0) % make it repeatable
import org.opensim.modeling.*
warning off

% set fpath
fpath = set_fpath();
if ~isfolder(fpath.result_now)
    mkdir(fpath.result_now)
end

% set param
param = load_param("initialise");

% load OpenSim model and initialise
Osim = gen_model("load", fpath);
param  = load_param("model", param, Osim.model); % update the model parameters

[Osim, param] = gen_model("update", Osim, fpath, param); % update the model
Osim = gen_model("report", Osim); % attach report

param.grid = define_shape(param.grid, "grid"); % difine some geometric data
param.cylinder = define_shape(param.cylinder, "cylinder");

% initialise a plot
h = plot_map("initialise", Osim.markers, param);

% get the stimulation sequence
param.seq = get_stimSequence(param);

param.flag.file_save = true;

% create image storage template
temp_y = linspace(0, 0.25, 50); 
temp_x = linspace(-180, 180, 101);
[p_image.x, p_image.y] = meshgrid(temp_x, temp_y);       % Create the coordinate grid


for i = 1:size(param.seq.anode,2)

    param = get_stimPos(param, Osim.markers,i);     % extract the current stimulation sites
    param.sim.idx = i;

    [D, Osim] = run_sim("direct", Osim, param, fpath); % compute motion
    if ~isempty(D)
        M = MotionIndex(D); % compute motion indices for analyses
        fprintf("Marker [%d, %d]; Score [%0.2f, %0.2f, %0.2f, %0.2f, %0.2f]\n", param.seq.anode{param.sim.idx}, param.seq.cathode{param.sim.idx}, M.raw.thumb,M.raw.index, M.raw.middle,M.raw.ring,M.raw.little);
        p_image = make_map(p_image, M, param); % data storage

        h = plot_map("update", h, p_image.mean); % update figure
        fpath_file = sprintf("osim_%s_ID_%05d.mat",fpath.date, param.sim.idx);

        save(fullfile(fpath.result_now, fpath_file), "D","param");
    end
end


for i = 1:5
    figure(2)
    finger = param.main.fingers{i};
    z = p_image.mean.(finger);
    z_sort = [z(:,68:end), z(:,1:67)];
    a = surf(p_image.x, p_image.y,z_sort);
    shading interp
    view([0, 90])
    colormap jet
    clim([-1, 1])
    % ylim([0,35])
    axis off
    axis square
    saveas(a, fullfile(fpath.result,sprintf("sim_map_%s.png",finger)) )
end

hAxes = findall(h(2), 'type', 'axes');
selectedAxes = hAxes(1);  % Change index if needed
newFig = figure;
newAxes = copyobj(selectedAxes, newFig);
set(newAxes, 'Position', [0.13, 0.11, 0.775, 0.815]); % Standard full-size figure axes position
colormap jet
clim([-1 1])
plot2svg("test.svg",newFig,"svg")

end

function fpath = set_fpath
% Load file paths
fpath.date = char(datetime('now','Format','yyyyMMddHHmm'));

fpath.code =  fullfile(fileparts(mfilename('fullpath')));
fpath.main = fullfile(fpath.code,"..","..");
fpath.result = fullfile(fpath.main, "results");
fpath.result_now = fullfile(fpath.result, fpath.date);

fpath.save = fullfile(fpath.result,"fd_model.mat");
fpath.osim.main = fullfile(fpath.main, "code", "opensim");
fpath.osim.model_name = 'wrist_fes_hand.osim';
fpath.osim.model_mod_name = 'wrist_fes_hand_modified.osim';
fpath.osim.model = fullfile(fpath.osim.main, fpath.osim.model_name);
fpath.osim.model_modified = fullfile(fpath.osim.main, fpath.osim.model_mod_name);

fpath.osim.state = fullfile(fpath.osim.main, 'steady_state.sto');

addpath(genpath(fpath.code));
addpath(genpath(fpath.osim.main));

end