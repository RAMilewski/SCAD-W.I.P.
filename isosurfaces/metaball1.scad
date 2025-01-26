include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>
centers = [[-10,-10,10], 
            [10,10,10] ];
charges = [14, 15];
type = MB_SPHERE;
isovalue = 3;
voxelsize = 1
;
boundingbox = [[-20,-20,-10], [20,20,22]];
metaballs(voxelsize, boundingbox, isovalue=isovalue,
    ball_centers=centers, charge=charges, ball_type=type);