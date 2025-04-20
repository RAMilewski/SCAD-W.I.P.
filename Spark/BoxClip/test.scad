include<BOSL2/std.scad>


path = turtle(["xmove", 5, "left", 90, "ymove", 10, "left", 90, "xmove", -10, "left", 90, "ymove", -5 ]);

path_sweep(square(1), path);