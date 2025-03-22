include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>
spec = [
    up(10) * zscale(0.8), mb_sphere(20),
    IDENT, mb_sphere(2, influence=30, cutoff=20, negative=true),
    down(5), mb_cyl(d = 15, h = 20, cutoff = 5),
    //down(10), mb_disk(d = 18, h = 2),
];
voxel_size = 0.5;
boundingbox = [[-20,-20,-30], [20,20,30]];
metaballs(spec, boundingbox);