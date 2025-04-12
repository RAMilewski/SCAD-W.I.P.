include <BOSL2/std.scad>
include <texture.data>


diff()
    cuboid(35) attach([TOP,LEFT,FWD,BACK,RIGHT,BOT],BOT)
        textured_tile(texture, 30, tex_reps=[5,3], tex_depth = 0.75, tex_inset = true, diff = true, style="convex");
