include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>
vsize = 1;
bbox =  [[-10,-10,-10], [30,10,20]];

spec = [
    
    IDENT, mb_octahedron(h = 5, d1 = 3, d2 = 3, negative = true, influence = 12, cutoff = 10),
];
metaballs(spec, vsize, bbox,  show_stats = true);

    /* */