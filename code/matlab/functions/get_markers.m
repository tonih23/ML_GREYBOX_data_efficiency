function markers = get_markers(model, state)
import org.opensim.modeling.*
% Access marker locations and transform to ground frame

markerSet = model.getMarkerSet();
param.numMarkers = markerSet.getSize();

markers = struct();
for i = 0:param.numMarkers-1
    marker = markerSet.get(i);
    markerName = char(marker.getName());
    locationInGroundVec = marker.getParentFrame().expressVectorInGround(state, Vec3(marker.get_location()));
    markers.(markerName) = [locationInGroundVec.get(0), locationInGroundVec.get(1), locationInGroundVec.get(2)];
end
