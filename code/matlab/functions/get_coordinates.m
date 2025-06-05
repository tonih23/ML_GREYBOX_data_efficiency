function [coordinateSet, coordinate_state] = get_coordinates(model, state)

coordinateSet = model.getCoordinateSet();
param.numCoord = coordinateSet.getSize();

for i = 0:param.numCoord-1
    coordinate = coordinateSet.get(i);
    coordName = char(coordinate.getName());

    coordinate_state.(coordName) =  coordinate.getValue(state);
end
