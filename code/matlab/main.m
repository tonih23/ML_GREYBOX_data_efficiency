function main

clear all % clear all just in case FES is connected in the background

fpath.code =  fullfile(fileparts(mfilename('fullpath')));
fpath.main = fullfile(fpath.code,"..","..");
fpath.save.main = fullfile(fpath.main, "data");
if ~isfolder(fpath.save.main)
    mkdir(fpath.save.main);
end
addpath(genpath(fpath.code));

param.main.sub = 1;
param.main.trial_max = 5; % max iteration allowed

[stim_data] = FES_GUI();  % Receive parameters from GUI

% Extract the parameters from the structure
anodes = stim_data.anodes;
cathodes = stim_data.cathodes;
amps = stim_data.amp;
widths = stim_data.width;
%% parameters
param.fes.device = "STIM_2_1.default";
% param.fes.device = "STIM.default";
param.fes.baud = 115200;
param.fes.freq = 25; % hz
param.fes.com = "COM4"; %

param.fes.elec_n = 32; % electrode number
param.fes.amp_max = 10; %mA

P = [];
P.name = "grip";
P.id = 5; % 5 or above
P.anode = [];    % Initialize as empty or with default values
P.cathode = [];  % Initialize as empty or with default values
P.amp = [];      % Initialize as empty or with default values
P.width = [];  
P.elec_n = param.fes.elec_n;
P.score = [0,0];
param.fes.velec(1) = fes_param_gen(P);


param.fes.primitive = 1; % work on the velec1 or velec2;

%% initialise FES
 FES = []; % in case it's in the workspace
if flag.fes
    FES = fes_cmd("initialise", param.fes);
end

%% initialise Leap
param.leap.fs = 100; % hz, cycle freq limit
param.leap.td = ceil(param.fes.velec(param.fes.primitive).td)+1; % sec, leap recording duration per file. Adjust to fes time

if flag.fes
    matleap(0); pause(1); % wakeup device
    disp(newline)
end
param.fes.velec(param.fes.primitive).anode = stim_data.anodes;  % Assign anodes
param.fes.velec(param.fes.primitive).cathode = stim_data.cathodes; 
param.fes.velec(param.fes.primitive).amp = stim_data.amp;  % Assign anodes
param.fes.velec(param.fes.primitive).width = stim_data.width; 
if ~isfield(param.fes.velec(param.fes.primitive), 'anode') || ...
   ~isfield(param.fes.velec(param.fes.primitive), 'cathode') || ...
   ~isfield(param.fes.velec(param.fes.primitive), 'amp')
    error('Missing anode or cathode or amp fields in param structure.');
end
%% initalise beeps
[BP, param.sound] = design_beep(param);
figure(1);
set(gcf, 'Position', [2600,100, 1000, 700]); % Change the values to adjust the size
h(1) = subplot(2, 5, [1, 6]);
show_elec(h(1), param.fes.velec(param.fes.primitive), [], "elec");

h(2) = subplot(2, 5, [2:3, 7:8]);
S = [0, 0];
show_elec(h(2), param.fes.velec(param.fes.primitive), S, "score");
h(3) = subplot(2, 5, 4:5);

GRIP.x = 0;
GRIP.time = 0;
show_elec(h(3), [], GRIP, "grip");

h(4) = subplot(2, 5, 9:10);

i = 1;
baseline1Time = stim_data.baseline1Time;          % First baseline period before stimulation (1 second)
stimDuration = stim_data.stimDuration;      % Duration of FES stimulation (in seconds)
baseline2Time = stim_data.baseline2Time;           % Second baseline period after stimulation (2 seconds)


while true
    param.main.trial = i;
    param.main.date = datetime('now', 'Format', 'yyyyMMddHHmmss');
    fpath.save.fname = sprintf("ReHyb_FESAutoCalib_Ex1_Sub%02d_Trial%03d_%s", param.main.sub, param.main.trial, char(param.main.date));
   
    P = param.fes.velec(param.fes.primitive);
    P.anode = anodes;
    P.cathode = cathodes;
    P.amp = amps;
    P.width = widths;

    show_elec(h(1), P, [], "elec");

    param.fes = fes_safety(param.fes); % make sure amp is bounded by the safety value

 
        FES = fes_cmd("elec_define", param.fes,  FES); % generate elec definition
        writefes(FES.device, FES.cmd.(P.name).velec);
        writefes(FES.device, FES.cmd.(P.name).select); % select primitive

        disp('Starting Leap Motion recording...');
        Motion.Leap = leap_record(param.leap);  % Begin recording before stimulation
        startTime= tic;
        
        while toc(startTime) < baseline1Time   %FES Baseline
            pause(0.01)
        end

        disp('Starting FES stimulation...');
        sound(BP.start, param.sound.fs);
        writefes(FES.device, FES.cmd.(P.name).stim); % FES start
        stimStartTime= tic;
        while toc(stimStartTime) < stimDuration   %FES STIM duration
            pause(0.01);
        end
        
        writefes(FES.device, FES.cmd.(P.name).deselect); % fes deletect
        writefes(FES.device, FES.cmd.stim_off); % fes off
        disp("FES stimulation ended")
       
        postStartTime= tic
        while toc(postStartTime) < baseline2Time  %return to baseline
            pause(0.01);
        end

        GRIP.x = Motion.Leap.hand.grab_strength;
        GRIP.time = Motion.Leap.time;
        

      
    P.score(1) = max(GRIP.x);
    P.score(2) = 1-min(GRIP.x);
    S(i,:) = P.score;

    %% update plot
    show_elec(h(2), P, S, "score");
    show_elec(h(3), P, GRIP, "grip");

    %% store file
    param.fes.velec(param.fes.primitive) = P;
    save(fullfile(fpath.save.fpath, fpath.save.fname ), "Motion", "param");
           
    % disp("next trial");
    %     postStartTime= tic
    %     while toc(postStartTime) < baseline2Time  %return to baseline
    %         pause(0.01);
    %     end
        
    % update loop
    i = i+1;
    if i > param.main.trial_max % data converged...
        break
    end
end


 

if flag.fes
   writefes(FES.device, FES.cmd.(P.name).delete)
   FES.device.delete;
   fprintf("FES disconnected. Matlab closing...\n");
   pause(5)
   system('taskkill /F /IM matlab.exe /T'); % matlab needs to end this way due to the bug in loop sdk
end



