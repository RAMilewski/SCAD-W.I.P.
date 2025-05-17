include <BOSL2/std.scad>
include <flower_201x200.scad>

textured_tile(flower, [50,50], tex_reps=[1,1], tex_depth = 3, tex_inset = false, diff = false);  




*diff() {
  cuboid(45, rounding = 2, $fn = 64) {
  attach([TOP,LEFT,FWD],BOT)
        textured_tile(netfoolDM, [40,40], tex_reps=[1,1], tex_depth = 3, tex_inset = false, diff = true, style="quincunx");  
  };
}

/* */