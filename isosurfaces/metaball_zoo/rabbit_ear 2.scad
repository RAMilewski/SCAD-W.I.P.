include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>
function gyroid(x,y,z, wavelength) = let(
    p = 360/wavelength * [x,y,z]
) sin(p.x)*cos(p.y)+sin(p.y)*cos(p.z)+sin(p.z)*cos(p.x);
isovalue = [-0.1, 0.1];
bbox = [[-100,-100,-100], [100,100,100]];
isosurface(function(x,y,z) gyroid(x,y,z, wavelength=200),
    isovalue, bbox, voxel_size=5);