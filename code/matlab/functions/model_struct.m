fpath.osim.main = "C:\Users\endo\OneDrive - TUM\Desktop\test\model";
  fpath.osim.model = fullfile(fpath.osim.main,"das3.osim");



function model_struct(fpath)

fpath.osim.save = fullfile(fpath.osim.model, "model_struct.mat");

import org.opensim.modeling.*
osimModel = Model(fpath.osim.model);


model.name = 'DAS3';
model.osimfile = 'das3.osim';
model.modified = 'xx-xx-xxxx xx:xx:xx';
model.gravity = [osimModel.getGravity.get(0),  osimModel.getGravity.get(1),  osimModel.getGravity.get(2)];

model.nJoints = osimModel.getJointSet.getSize;

%% joints
for i = 1:osimModel.getJointSet.getSize
    a = osimModel.getJointSet.get(i-1);

    model.joints{i}.name = a.getName.toCharArray';

    model.joints{i}.location = [a.get_frames(0).get_translation.get(0), a.get_frames(0).get_translation.get(1), a.get_frames(0).get_translation.get(2)];
    model.joints{i}.orientation = [a.get_frames(0).get_orientation.get(0), a.get_frames(0).get_orientation.get(1), a.get_frames(0).get_orientation.get(2)];

    b = a.get_frames(0).getPropertyByIndex(4).toString.toCharArray';
    c = strsplit(b,"/");
    model.joints{i}.parent_segment = c{end};

    b = a.get_frames(1).getPropertyByIndex(4).toString.toCharArray';
    c = strsplit(b,"/");
    model.joints{i}.segment = c{end};
    j_list{i} = model.joints{i}.segment;
end

%% body
model.nSegments = osimModel.getBodySet.getSize;

model.segments{1}.name = 'ground';
model.segments{1}.mass = 0;
model.segments{1}.mass_center = [0, 0, 0];
model.segments{1}.inertia = zeros(3);
model.segments{1}.parent_joint = '';

for i = 1:osimModel.getBodySet.getSize
    a = osimModel.getBodySet.get(i-1);

    model.segments{i+1}.name = a.getName.toCharArray';

    model.segments{i+1}.mass = a.getMass;
    model.segments{i+1}.mass_center = [a.getMassCenter.get(0), a.getMassCenter.get(1), a.getMassCenter.get(2)];

 
    inertia(1,1) = a.getInertia.get().Moments.get(0);
    inertia(2,2) = a.getInertia.get().Moments.get(1);
    inertia(3,3) = a.getInertia.get().Moments.get(2);

    inertia(1,2) = a.getInertia.get().Products.get(0);
    inertia(2,1) = a.getInertia.get().Products.get(0);
    
    inertia(1,3) = a.getInertia.get().Products.get(1);
    inertia(3,1) = a.getInertia.get().Products.get(1);

    inertia(2,3) = a.getInertia.get().Products.get(2);
    inertia(3,2) = a.getInertia.get().Products.get(2);

    model.segments{i+1}.inertia = inertia;

    idx = find(matches(j_list, model.segments{i+1}.name),1,"first");
    model.parent_joint{i+1}.parent_segment = j_list{idx};
end

%% dof
model.nDofs = osimModel.getCoordinateSet.getSize;

for i = 1:osimModel.getCoordinateSet.getSize
a = osimModel.getCoordinateSet.get(i-1);
    model.dofs{i}.locked = a.get_locked;
    model.dofs{i}.osim_name = a.getName.toCharArray';
    model.dofs{i}.name = strrep(model.dofs{i}.osim_name,"_","");

    model.dofs{i}.range = [a.getRangeMin, a.getRangeMax];
end

model.dof_indeces = 0:model.nDofs-1;

model.nConstraints = 0;

%% muscle
model.nMus = osimModel.getMuscles.getSize;

m_active_x = [-5.3077; -4.3077; -1.9231; -0.8846; -0.2692; 0.2308; 0.4615; 0.5272; 0.6288; 0.7188; 0.8612; 1.0450; 1.2175; 1.4387; 1.5000; 1.6154; 2.0000; 2.9615; 3.6923; 5.4615; 9.9019];
m_active_y = [0.0122; 0.0219; 0.0365; 0.0525; 0.0753; 0.1142; 0.1579; 0.2267; 0.6367; 0.8567; 0.9500; 0.9933; 0.7700; 0.2467; 0.1938; 0.1333; 0.0727; 0.0444; 0.0363; 0.0219; 0.0073];
m_passive_x = [-5; 0.99799999999999999822; 0.99899999999999999911; 1; 1.1000000000000000888; 1.1999999999999999556; 1.3000000000000000444; 1.3999999999999999112; 1.5; 1.6000000000000000888; 1.6009999999999999787; 1.6020000000000000906; 5];
m_passive_y = [0;  0;  0;  0;  0.035000000000000003331;  0.11999999999999999556;  0.26000000000000000888;  0.55000000000000004441;  1.1699999999999999289;  2;  2;  2;  2];

for i = 1:osimModel.getMuscles.getSize
    a = osimModel.getMuscles.get(i-1);
    
    model.muscles{i}.osim_name = a.getName.toCharArray';
    model.muscles{i}.name = strrep(model.muscles{i}.osim_name,"_","");
   
    model.muscles{i}.mass = 0.01; % to be defined...
    model.muscles{i}.fmax = a.getPropertyByName("max_isometric_force");
    model.muscles{i}.lceopt = a.getPropertyByName("optimal_fiber_length");
    model.muscles{i}.lslack = a.getPropertyByName("tendon_slack_length");
    model.muscles{i}.pennopt = a.getPropertyByName("pennation_angle_at_optimal");
    model.muscles{i}.vmax = a.getPropertyByName("max_contraction_velocity");
    model.muscles{i}.tact = a.getPropertyByName("activation_time_constant");
    model.muscles{i}.tdeact = a.getPropertyByName("deactivation_time_constant");
    model.muscles{i}.Xval_active_fl = m_active_x;
    model.muscles{i}.Yval_active_fl = m_active_y;
    model.muscles{i}.Xval_passive_fl = m_passive_x;
    model.muscles{i}.Yval_passive_fl = m_passive_y;
    model.muscles{i}.PEEslack = 1;
   
    model.muscles{i}.dof_count = 6;
    model.muscles{i}.dof_indeces = 1:model.muscles{i}.dof_count
    model.muscles{i}.dof_names = {6×1 cell}
    model.muscles{i}.lparam_count = 12;
    model.muscles{i}.lparams = [12×6 double]
    model.muscles{i}.lcoefs = [12×1 double]
    model.muscles{i}.crossesGH = 0;
end

model.nMarkers = 0;
model.conoid_eps = 1.0000e-03;
model.conoid_stiffness = 80000;
model.conoid_length = 0.0174;
model.conoid_origin = [0.1365 0.0206 0.0136];
model.conoid_insertion = [-0.0536 -9.0000e-04 -0.0266];
model.scap_thorax_eps = 0.0100;
model.scap_thorax_k = 20000;
model.TSprojection = [-0.1274 -0.0228 -0.0346];
model.AIprojection = [-0.1257 -0.1223 -0.0275];
model.thorax_radii = [0.1470 0.2079 0.0944];
model.thorax_center = [0;0;0];

save(fpath.osim.save, "model");


 
