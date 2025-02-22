include <BOSL2/std.scad>
include <BOSL2/isosurface.scad> 




infl = EPSILON + 1 - $t;

metaballs([
    IDENT, mb_disk(10,15),
    left(15), mb_sphere(7,influence = infl, negative = false, cutoff = 30),
    ], 
    voxel_size=4, [[-75,-75,-75], [75,75,75]], show_stats = true);

ghost() left(5) cuboid([50,40,30]);
