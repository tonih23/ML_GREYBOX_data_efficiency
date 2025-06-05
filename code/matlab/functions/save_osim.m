function save_osim(storage, param, fpath)
if ~isfolder(fpath.result_now)
    mkdir(fpath.result_now)
end
fpath.file = sprintf("osim_%s_ID_%05d.mot",fpath.date, param.sim.idx);
storage.print(fullfile(fpath.result_now, fpath.file));  % Save file
end