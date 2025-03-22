include<BOSL2/std.scad>
include<BOSL2/isosurface.scad>

bbox = [[-30,-30,-30],[30,30,50]];

spec = [
    IDENT, mb_sphere(15),
    up(20), mb_sphere(8, cutoff = 10),
    up(10), mb_disk(h = 2, d = 10),
];

metaballs(spec, bbox, debug = true);