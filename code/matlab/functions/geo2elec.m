
function elec_map = geo2elec(geo_map, markers, param)
xRange = linspace(0, 0.25, param.grid );
yRange = linspace(-0.08, 0.08, param.grid );
zRange = linspace(-0.08, 0.08, param.grid );

[X, Y, Z] = meshgrid(xRange, yRange, zRange);
pl_y = X(:); % X remains as is
pl_x = atan2d(Z(:), Y(:)); % Compute the angle for the Y-Z plane
[pl_x_grid, pl_y_grid] = meshgrid(unique(pl_x), unique(pl_y));

pl_z = geo_map(:); % Extract the corresponding values from the probability density map
pl_z_grid = griddata(pl_x, pl_y, pl_z, pl_x_grid, pl_y_grid);
pl_z_grid_smooth = imgaussfilt(pl_z_grid, [0.05,5]);

fd = fieldnames(markers);
for m = 1:size(fd,1)
    markerName = sprintf('marker_%03d', m);
    markerLocation = markers.(markerName);
    markerY = markerLocation(1);
    markerX = atan2d(markerLocation(3), markerLocation(2)); % flatten 2D as an angle

    z_query(m) = interp2(pl_x_grid, pl_y_grid, pl_z_grid_smooth, markerX, markerY, 'linear');
end
z = reshape(1:160,16,10)';
elec_map = z_query(z);

end
