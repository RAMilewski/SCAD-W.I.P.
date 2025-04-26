include <BOSL2/std.scad>
include <netfool_200x200.scad>


diff()
    cuboid(35, rounding = 3, $fn = 72) 
    attach([TOP,LEFT,FWD],BOT)
        textured_tile(netfool, 30, tex_reps=[1,1], tex_depth = 1, tex_inset = true, diff = true, style="quincunx");
        