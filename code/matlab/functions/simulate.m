function D = simulate(fpath, param)

[osimModel, D.model] = load_model(fpath);

FES = get_fes(param.fes); % generate FES profiles
param.stim.t = max(FES.time);

dist = get_distance(D.model, param.fes); % distance of electrodes to the muscles;

D.actv = get_activation(FES, dist);

warning off
D.sim = fes_simulate(osimModel, FES, D.actv, D.model, fpath);
warning on

 make_osimm(fullfile(fpath.result, fpath.fname + ".sto"), D.model.dof.name, D.sim.x(:,1: D.model.dof.n), D.sim.time); % save osim file

% h = surf(Actv);
% shading interp
% colormap(jet)
% view([0,90])
% ylabel("Time (sec)")
% xlabel("muscle");
%
% fd = fieldnames(S.Muscle);
% set(h.Parent, 'TickLabelInterpreter', 'none')
% h.Parent.XTick = 1:length(fd);
% h.Parent.XTickLabel = fd;
% h.Parent.YTickLabel = h.Parent.YTick/param.fes.fs;
%
