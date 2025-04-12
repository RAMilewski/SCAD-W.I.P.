include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>
spec = [
    left(9), mb_sphere(5),
    right(12), mb_sphere(5),
    right(25), mb_sphere(5, influence = 3, cutoff = 15, negative = true),
];

bbox = [[-20,-20,-20],[20,20,20]];

metaballs(spec, voxel_size=1, bounding_box=bbox, debug = false, show_box = false);


