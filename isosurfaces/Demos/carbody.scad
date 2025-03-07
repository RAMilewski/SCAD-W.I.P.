include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

debug = false;  //[true,false]

func = [
    yrot(90) * yscale(0.75), mb_capsule(r = 5, h = 25),
    left(15) * xrot(90), mb_disk(h = 2, r = 3),
    right(12) * up(8) * yrot(45), 
        mb_cuboid([10,10,2], influence = 3, cutoff = 10, negative = true),
];

bbox = [[-19, -5, -4], [13, 5, 6]];

metaballs(func,bbox,1, debug = debug, show_stats=true);