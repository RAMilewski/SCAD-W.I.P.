include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

inf = .75;

spec = [
    left(20), mb_sphere(d=25, influence = inf),
    right(20), mb_sphere(d=25, influence = inf)
];
metaballs(spec, voxel_size=1,
    bounding_box=[[-35,-15,-15], [35,15,15]], show_stats = true);
