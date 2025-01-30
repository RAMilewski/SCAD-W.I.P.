include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>
xpos = -15 + $t * 30;
zpos =  15 - $t * 30;
centers = [[0,0,0], 
           [xpos,0,zpos] ];
charges = [25, 15];
type = MB_SPHERE;
isovalue = 5;
voxelsize = 1
;
boundingbox = [[-30,-30,-30], [30,30,30]];
metaballs(voxelsize, boundingbox, isovalue=isovalue,
    ball_centers=centers, charge=charges, ball_type=type);

