include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

func = [
    yrot(90)*yscale(0.75), mb_capsule(r = 5, h = 25),
    left(15) * xrot(90), mb_disk(h = 2, r = 3),
];

bbox = [[-19, -5, -4], [13, 5, 6]];

metaballs(func,bbox,1, show_stats=true);