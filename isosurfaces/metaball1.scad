include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

xpos = -15 + $t * 30;
zpos =  15 - $t * 30;

bounding_box = [[-30,-30,-30], [30,30,30]];
isovalue = 5;
voxel_size = 1;

funcs = [
    IDENT, mb_sphere(25),
    move([xpos,0,zpos]), mb_sphere(15),
];

metaballs(funcs = funcs, voxel_size = voxel_size, bounding_box = bounding_box, isovalue=isovalue);

