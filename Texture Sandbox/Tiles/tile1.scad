include <BOSL2/std.scad>
include <Netfool_3b3_230x230.scad>

textured_tile(Netfool_3, [40,40], tex_reps=[1,1], tex_depth = 3,         tex_inset = false, diff = false);  

/*

diff() {
  cuboid(45, rounding = 2, $fn = 64) {
  attach([TOP,LEFT,RIGHT,FWD,BACK],BOT)
        textured_tile(Netfool_3, [40,40], tex_reps=[1,1], tex_depth = 3, tex_inset = false, diff = false, style="quincunx");  
  };
}

/* */