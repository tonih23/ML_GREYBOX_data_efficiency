function Osim = set_activation(Osim, activation)
import org.opensim.modeling.*
for i = 1:size(Osim.List_muscles,1)
    muscleName = Osim.List_muscles{i};
    muscles = Osim.muscles.get(muscleName);
    muscles.setActivation(Osim.state, activation.(muscleName));
end