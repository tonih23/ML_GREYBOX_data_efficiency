function flag = monitor_limit(Osim)
import org.opensim.modeling.*
for i = 0:Osim.coordinate.getSize-1
    c = Osim.coordinate.get(i);
    v = c.getValue(Osim.state);
    if v> c.getRangeMax+0.0873 || v < c.getRangeMin -0.0873
        flag = true;
        return
    else
        flag = false;
    end
end
