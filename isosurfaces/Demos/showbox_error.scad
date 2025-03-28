include<BOSL2/std.scad>
include<BOSL2/isosurface.scad>

bbox = [[-10,-10,-10],[10,10,10]];
    spec = [
        IDENT, mb_sphere(3),
        up(4), mb_sphere(3),
    ];
    metaballs(spec, bbox, show_stats = true, show_box = true);

