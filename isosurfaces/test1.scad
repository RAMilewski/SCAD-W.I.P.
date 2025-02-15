include <BOSL2/std.scad>
include <BOSL2/isosurface.scad> 

isovalue = 1;
voxel_size = 1;

infl = EPSILON + 1 - $t;

metaballs([
    IDENT, mb_disk(10,15),
    left(15), mb_sphere(7,influence = infl, negative = false, cutoff = 30),
    ], 
    voxel_size, [[-30,-20,-15], [20,20,15]], isovalue);


