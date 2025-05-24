include <BOSL2/std.scad>
include <bunny_200x239.scad>


aspect = image_array_size.y/image_array_size.x;
width = 50;


textured_tile(image_array, [width,width*aspect], tex_reps=[1,1], tex_depth = -1, tex_inset = false, style = "min_area", diff = false);  




*diff() {
  cuboid(45, rounding = 2, $fn = 64) {
  attach([TOP,LEFT,FWD],BOT)
        textured_tile(image, [40,56], tex_reps=[1,1], tex_depth = 3, tex_inset = false, diff = true, style="quincunx");  
  };
}

/* */