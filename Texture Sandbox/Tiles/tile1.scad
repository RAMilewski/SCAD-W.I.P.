include <BOSL2/std.scad>
include <wilbur2dmap_200x280.scad>


aspect = wilbur2dmap_size.y/wilbur2dmap_size.x;
width = 50;


textured_tile(wilbur2dmap, [width,width*aspect,3], tex_reps=[1,1], tex_depth = 1.5, tex_inset = false, style = "min_area", diff = false);  




*diff() {
  cuboid(45, rounding = 2, $fn = 64) {
  attach([TOP,LEFT,FWD],BOT)
        textured_tile(image, [40,56], tex_reps=[1,1], tex_depth = 3, tex_inset = false, diff = true, style="quincunx");  
  };
}

/* */