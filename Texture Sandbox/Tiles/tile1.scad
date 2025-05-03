include <BOSL2/std.scad>
include <woodgrain_200x200.scad>


$fn = 64;
//diff()
  //cuboid(35, rounding = 2) attach([TOP,LEFT,FWD],BOT)
        textured_tile(woodgrain, [30,30], tex_reps=[1,1], tex_depth = 1.5, tex_inset = false, diff = false, style="quincunx");


