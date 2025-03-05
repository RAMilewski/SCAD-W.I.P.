include <BOSL2/std.scad>
include <BOSL2/isosurface.scad> 

stats = false; // [true,false]
debug = false; // [true,false]
box  = false; // [true,false]

vsize = 1;
ival = 1;
bbox =   [[-20, -20, -20], [20, 20, 20]];

/* [Hidden] */

spec = [
    IDENT, mb_sphere(10),
];

metaballs(spec, bbox, vsize, isovalue = ival, show_box = box, debug = debug, show_stats = stats);

    /* */