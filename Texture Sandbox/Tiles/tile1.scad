include <BOSL2/std.scad>
include <terrain.scad>

textured_tile(elevation_data, [50,50,5], tex_reps=[1,1], tex_depth = 5, tex_inset = false, diff = false);  




*diff() {
  cuboid(45, rounding = 2, $fn = 64) {
  attach([TOP,LEFT,FWD],BOT)
        textured_tile(netfoolDM, [40,40], tex_reps=[1,1], tex_depth = 3, tex_inset = false, diff = true, style="quincunx");  
  };
}

/* */