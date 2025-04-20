include <BOSL2/std.scad>
include <star.data>

*diff()
    cuboid(35) attach([TOP,LEFT,FWD],BOT)
        textured_tile(star, 30, tex_reps=[1,1], tex_depth = 0.5, tex_inset = false, diff = false, style="quincunx");

import("SVG/Flower-Icons/SVG/Icon 19.svg");
