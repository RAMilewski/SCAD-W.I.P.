include <BOSL2/std.scad>
<<<<<<< Updated upstream
include <danmi_200x201.scad>

textured_tile(danmi, [30,40], tex_reps=[1,1], tex_depth = 3, tex_inset = false, diff = false);  
=======
include <netfoolDM_200x200.scad>

//textured_tile(netfoolDM, [40,40], tex_reps=[1,1], tex_depth = 1.5,         tex_inset = false, diff = false);  

>>>>>>> Stashed changes



*diff() {
  cuboid(45, rounding = 2, $fn = 64) {
  attach([TOP,LEFT,FWD],BOT)
<<<<<<< Updated upstream
        textured_tile(John, [40,40], tex_reps=[1,1], tex_depth = 3, tex_inset = false, diff = false, style="quincunx");  
=======
        textured_tile(netfoolDM, [40,40], tex_reps=[1,1], tex_depth = 3, tex_inset = false, diff = true, style="quincunx");  
>>>>>>> Stashed changes
  };
}

/* */