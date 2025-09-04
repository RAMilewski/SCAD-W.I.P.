include <BOSL2/std.scad>
include <Tiles/blizzard_200x200.scad>

cuboid(50, rounding = 5, $fn = 72)
    attach([TOP,LEFT,FWD,RIGHT,BACK],BOT) textured_tile(blizzard, 40, tex_reps = [1,1]);
