function  test
clear all; close all
rng(0) % make it repeatable
import org.opensim.modeling.*
warning off

fpath.osim.model = "C:\Users\endo\Documents\GitHub\Wesenick-bachelor-2024\code\opensim\wrist_fes_hand.osim";
param = load_param("initialise");

Osim = gen_model("load", fpath);
Osim = gen_model("update", Osim);

param  = load_param("model", param, Osim.model); % update the model parameters
t = 0:1/param.sim.fq:param.sim.td;

Osim.muscles = change_muscle(Osim.muscles, Osim.state);
Osim.model = add_limitforce(Osim.model, Osim.coordinate);

% Osim.model.print("C:\Users\endo\Documents\GitHub\Wesenick-bachelor-2024\code\opensim\temp.osim")

Osim = gen_model("initialise", Osim, param);

act_muscles = Osim.muscles.get(30);

try
    t = 0:1/param.sim.fq:param.sim.td;
    for i = 1:size(t,2)
        act_muscles.setActivation(Osim.state, 1);
        Osim.state = Osim.manager.integrate(t(i)); % Simulate the system
    end
catch
    disp("simulation failed!")
end

storage = Storage(Osim.manager.getStateStorage());
storage.print('C:\Users\endo\Documents\GitHub\Wesenick-bachelor-2024\simulation_results.mot');  % Save file

end