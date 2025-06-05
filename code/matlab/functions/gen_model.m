function [Osim, param] = gen_model(what, varargin)
import org.opensim.modeling.*
switch what
    case  "load"
        fpath = varargin{1};
        Osim.model = Model(fpath.osim.model);
        Osim.model.setGravity(Vec3(0.0, 0, 0.0));

        Osim.state = Osim.model.initSystem(); % Initialize system state

        param = [];
    case "update"
        Osim = varargin{1};
        fpath = varargin{2};
        param = varargin{3};

        e = Osim.model.getJointSet.get("elbow").getChildFrame; % face the hand up
        e2 = PhysicalOffsetFrame.safeDownCast(e);
        e2.set_orientation(Vec3(0,90,0))

        [Osim, joint_pos] = add_markers(Osim, param);
        param.cylinder.joint_pos = joint_pos;

        [Osim.muscles, Osim.MusclePath, Osim.List_muscles] = get_muscles(Osim.model, Osim.state);
        Osim.muscles = change_muscle(Osim.muscles, Osim.state);

        [Osim.coordinate, Osim.coordinate_state] = get_coordinates(Osim.model, Osim.state);
        Osim.model = add_limitforce(Osim.model, Osim.coordinate);

        Osim.model.print(fpath.osim.model_modified);
        fprintf("model: %s generated.\n", fpath.osim.model_mod_name)

        Osim = [];   %clearn dependencies
        Osim.model = Model(fpath.osim.model_modified);
        Osim.state = Osim.model.initSystem(); % Initialize system state
        Osim.markers = get_markers(Osim.model, Osim.state);
        [Osim.muscles, Osim.MusclePath, Osim.List_muscles] = get_muscles(Osim.model, Osim.state);
        Osim.coordinate = Osim.model.getCoordinateSet;
        
    case "report"
        Osim = varargin{1};
        Osim.reporter = TableReporter();

        Osim.reporter.set_report_time_interval(0.01);
        Osim.reporter.updInput('inputs').connect(Osim.model.getCoordinateSet().get('cmc_flexion').getOutput('value'));
        Osim.reporter.updInput('inputs').connect(Osim.model.getCoordinateSet().get('cmc_abduction').getOutput('value'));
        Osim.reporter.updInput('inputs').connect(Osim.model.getCoordinateSet().get('mp_flexion').getOutput('value'));
        Osim.reporter.updInput('inputs').connect(Osim.model.getCoordinateSet().get('ip_flexion').getOutput('value'));
        Osim.reporter.updInput('inputs').connect(Osim.model.getCoordinateSet().get('c_2mcp_flexion').getOutput('value'));
        Osim.reporter.updInput('inputs').connect(Osim.model.getCoordinateSet().get('c_2pm_flexion').getOutput('value'));
        Osim.reporter.updInput('inputs').connect(Osim.model.getCoordinateSet().get('c_2md_flexion').getOutput('value'));
        Osim.reporter.updInput('inputs').connect(Osim.model.getCoordinateSet().get('c_3mcp_flexion').getOutput('value'));
        Osim.reporter.updInput('inputs').connect(Osim.model.getCoordinateSet().get('c_3pm_flexion').getOutput('value'));
        Osim.reporter.updInput('inputs').connect(Osim.model.getCoordinateSet().get('c_3md_flexion').getOutput('value'));
        Osim.reporter.updInput('inputs').connect(Osim.model.getCoordinateSet().get('c_4mcp_flexion').getOutput('value'));
        Osim.reporter.updInput('inputs').connect(Osim.model.getCoordinateSet().get('c_4pm_flexion').getOutput('value'));
        Osim.reporter.updInput('inputs').connect(Osim.model.getCoordinateSet().get('c_4md_flexion').getOutput('value'));
        Osim.reporter.updInput('inputs').connect(Osim.model.getCoordinateSet().get('c_5mcp_flexion').getOutput('value'));
        Osim.reporter.updInput('inputs').connect(Osim.model.getCoordinateSet().get('c_5pm_flexion').getOutput('value'));
        Osim.reporter.updInput('inputs').connect(Osim.model.getCoordinateSet().get('c_5md_flexion').getOutput('value'));

        Osim.model.addComponent(Osim.reporter);
        Osim.model.finalizeConnections();
        param = [];
    case "initialise"
        Osim = varargin{1};
        param = varargin{2};

        if param.flag.vis % visualise
            close_osim; % close osim windows
            Osim.model.setUseVisualizer(true);
        end

         Osim.reporter.clearTable();
        Osim.state = Osim.model.initSystem();

        if param.flag.vis % visualise
            sviz = Osim.model.updVisualizer().updSimbodyVisualizer();
            sviz.setShowFrameNumber(true);
            sviz.setShowSimTime(true);
            sviz.setBackgroundTypeByInt(2);
            sviz.setBackgroundColor(Vec3(0.3,0.3,0.3));
            sviz.setGroundHeight(-1);
            sviz.setCameraFieldOfView(0.1);
            cameraPosition = Vec3(0.2, 3, 0.15); % Desired position coordinates
            rotationAngle = pi; % Rotation angle in radians (45 degrees)
            rotationAxis = Vec3(0,  1, 1); % Rotation axis (Z-axis)
            rotation = Rotation(rotationAngle, rotationAxis);
            cameraTransform = Transform(rotation, cameraPosition);
            sviz.setCameraTransform(cameraTransform);
        end

        % Loop through all muscles and set activation to zero
        for i = 0:param.model.numMuscles-1
            muscle = Osim.muscles.get(i);
            muscle.setActivation(Osim.state, 0.0); % Set activation to 0
        end

        Osim.current_time = 0;
        Osim.state.setTime(Osim.current_time);

        Osim.model.assemble(Osim.state);
        Osim.model.equilibrateMuscles(Osim.state);

        Osim.manager = Manager(Osim.model);
        Osim.manager.setIntegratorAccuracy(param.sim.setIntegratorAccuracy); % Set integration accuracy
        Osim.manager.initialize(Osim.state);

end


