include <BOSL2/std.scad>
include <isosurface.scad>

frames = 30;
position = [-15 + $t * frames, 0 , 15 - $t * frames];

bounding_box = [[-20,-10,-15],[20,10,15]];
isovalue = 5;
voxelsize = 1;

funcs = [
    IDENT, mb_sphere(25),
    move[position], mb_sphere(15),  
];

metaballs(funcs = funcs, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size);
