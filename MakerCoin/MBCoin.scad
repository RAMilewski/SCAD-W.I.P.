include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

r1 = 25;    // Major radius of the coin
r2 = 5;     // radius of the edge
cz = 1;     // center z max

bounding_box = [[-30, -30, -15], [30, 30, 15]];
isovalue = 1;
voxel_size = 1;

funcs = [
    IDENT, mb_cyl(h = 10,r = 25),
    //move(position), mb_sphere(3),  
];

metaballs(funcs = funcs, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = true);
