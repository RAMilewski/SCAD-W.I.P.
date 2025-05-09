include <BOSL2/std.scad>
include <danmi_200x201.scad>

textured_tile(danmi, [30,40], tex_reps=[1,1], tex_depth = 3, tex_inset = false, diff = false);  



*diff() {
  cuboid(45, rounding = 2, $fn = 64) {
  attach([TOP,LEFT,FWD],BOT)
        textured_tile(John, [40,40], tex_reps=[1,1], tex_depth = 3, tex_inset = false, diff = false, style="quincunx");  
  };
}

/* */