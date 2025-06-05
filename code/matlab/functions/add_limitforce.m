function model = add_limitforce(model, coodinates)
import org.opensim.modeling.*
param.coodinates = coodinates.getSize;

rad_list = {'flexion','deviation'};
for i = 0:param.coodinates -1
    c_seg = coodinates.get(i);
    c_name = c_seg.getName;

    % Create a new CoordinateLimitForce

    limitForce = CoordinateLimitForce();
    limitForce.set_coordinate(c_name)
    limitForce.setName(c_name);

    if ismember(char(c_name) ,rad_list)
        ang(1) = c_seg.get_range(0);
        ang(2) = c_seg.get_range(1);
    else
        ang(1) = rad2deg(c_seg.get_range(0));
        ang(2) = rad2deg(c_seg.get_range(1));
    end
    limitForce.setLowerLimit(ang(1));
    limitForce.setUpperLimit(ang(2));
    limitForce.setLowerStiffness(1000);
    limitForce.setUpperStiffness(1000);
    limitForce.setDamping(1);

    model.addForce(limitForce);
end

end