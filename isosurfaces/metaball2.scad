include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>



centers = [[0, 0, 0], [3, 0, 0]];
charges = [25, 4];
type = MB_SPHERE;
isovalue = 5;
voxelsize = 0.25;
boundingbox = [[-6,-6,-6], [7,6,6]];
move([10,10,10])

metaballs(voxelsize, boundingbox, isovalue=isovalue,
    ball_centers=centers, charge=charges, ball_type=type, show_stats = true);

