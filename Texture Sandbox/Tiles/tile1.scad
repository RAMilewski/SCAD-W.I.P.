include <BOSL2/std.scad>
include <Netfool_1b3_230x230.scad>
include <Netfool_2b3_230x230.scad>
include <Netfool_3b3_230x230.scad>
include <netfoolDM_230x230.scad>
include <netfoolAS_200x200.scad>



$fn = 64;

left(25)  textured_tile(Netfool_3, [40,40], tex_reps=[1,1], tex_depth = 3, tex_inset = false, diff = false, style="quincunx");  
right(25) textured_tile(netfoolAS, [40,40], tex_reps=[1,1], tex_depth = 3, tex_inset = false, diff = false, style="quincunx");  

*diff() {
  cuboid(45, rounding = 2) {
  attach([TOP,LEFT,RIGHT,FWD,BACK],BOT)
        textured_tile(netfoolAS, [40,40], tex_reps=[1,1], tex_depth = 3, tex_inset = false, diff = false, style="quincunx");  
  };
}
