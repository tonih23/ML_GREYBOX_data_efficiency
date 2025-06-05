function d = grab_data(storage, columnName)
import org.opensim.modeling.*
%d = grab_data(storage, "/forceset/ECRL/activation");


columnData = ArrayDouble();  % Create an OpenSim ArrayDouble to hold the data

storage.getDataColumn(columnName, columnData);

d = zeros(columnData.getSize(),1);  % Preallocate MATLAB array

for i = 0:columnData.getSize()-1
    d(i+1,1) = columnData.get(i);
end
end