include<BOSL2/std.scad>
include<skull_300x402.scad>


$fn = 72;

cuboid(50, rounding = 2, teardrop = true){
    attach(TOP,BOT)
        textured_tile(size = [37,45,.1], texture=skull, tex_depth = 2, tex_reps = [2,2]);
    attach(LEFT,BOT)
        textured_tile(size = [37,45,.1], texture=skull, tex_depth = 1, tex_reps = [1,1]);
    attach(FWD,BOT)
        textured_tile(size = [37,45,.1], texture=skull, tex_depth = 2, tex_reps = [1,1]);
    attach(RIGHT,BOT)
        textured_tile(size = [37,45,.1], texture=skull, tex_depth = 3, tex_reps = [1,1]);
    attach(BACK,BOT)
        textured_tile(size = [37,45,.1], texture=skull, tex_depth = 4,  tex_reps = [1,1]);
}
