function score = simulate_hand(fpath, param)

actv = get_activation(param);
P = param.fes.velec(param.fes.primitive);
prof = cumsum(P.prof_time/1000)+5;
td = max(prof)+1;
sim_t = 0:1/param.fes.freq:td;

muscles = ["FCR","ECU"];

import org.opensim.modeling.*

M = Model(fpath.osim.model);
M.initSystem();
 % M.setUseVisualizer(true);

fdTool = ForwardTool();
fdTool.setModel(M);
fdTool.setInitialTime(0);
fdTool.setFinalTime(td); % Adjust as needed
fdTool.setResultsDir(fpath.osim.data_folder);
fdTool.setName("FD")

controller = PrescribedController();

% Grasp muscles - Approximate a sinusoidal excitation pattern
for i = 1:length(muscles)
    pf = PiecewiseLinearFunction();
    for j = 1:size(sim_t,2)
        pf.addPoint(sim_t(j), actv.(muscles{i})(1,j));
    end
    controller.addActuator(M.getMuscles().get(muscles{i}));
    controller.prescribeControlForActuator(muscles{i}, pf);
end

M.addController(controller);
M.finalizeConnections();

fdTool.run();

clear M
warning off
T = readtable(fpath.osim.data,"FileType","text","Delimiter","\t","Range",[7,1]);
warning on

x = T.x_jointset_wrist_hand_wrist_hand_r1_value(T.time>5);

temp(1) = max(x-0.6)/pi*2;
temp(2) = -min(x-0.6)/pi*3;
score = temp;
score(temp<0) = 0;
end


function actv = get_activation(param)

P = param.fes.velec(param.fes.primitive);
prof = cumsum(P.prof_time/1000)+5;
td = max(prof)+1;
sim_t = 0:1/param.fes.freq:td;

FCR.mp_x = abs(sin((1:param.fes.elec_n)*pi*1.23)); % arbitrary electrode distance to the muscle
FCR.mp_y = abs(sin((1:param.fes.elec_n)*pi*2.01));
FCR.mp = sqrt(sum(FCR.mp_x.^2+FCR.mp_y.^2,1));

temp_mp = 1-FCR.mp+(rand(1, param.fes.elec_n)-0.5)*0.1; % add noise to distance map (effectively activation map)
temp_mp(temp_mp < 0.5) = 0;
FCR.act_mp = temp_mp/2000;
FCR.act_gain = sum(FCR.act_mp(P.cathode));
actv.FCR = trapmf(sim_t, prof)*FCR.act_gain;

ECU.mp_x = abs(cos((1:param.fes.elec_n)*pi*1.53)); % arbitrary electrode distance to the muscle
ECU.mp_y = abs(cos((1:param.fes.elec_n)*pi*1.21));
ECU.mp = sqrt(sum(ECU.mp_x.^2+ECU.mp_y.^2,1));

temp_mp = 1-ECU.mp+(rand(1, param.fes.elec_n)-0.5)*0.1; % add noise to distance map (effectively activation map)
temp_mp(temp_mp < 0.5) = 0;
ECU.act_mp = temp_mp/2000;
ECU.act_gain = sum(ECU.act_mp(P.cathode));
actv.ECU = trapmf(sim_t, prof)*ECU.act_gain;
end