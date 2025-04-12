include<BOSL2/std.scad>
include<BOSL2/isosurface.scad>

bbox = [[-30,-30,-30],[30,30,50]];

spec = [
    IDENT, mb_sphere(15),
    up(20), mb_capsule(18,5),
    up(25), mb_sphere(3, negative = true, influence = 0.5, cutoff = 5),
];

metaballs(spec, bbox, debug = true);