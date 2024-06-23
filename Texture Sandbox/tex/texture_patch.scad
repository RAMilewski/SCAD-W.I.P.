
include<BOSL2/std.scad>

*diff() {
    cuboid(100, rounding = 10){
        attach(FWD,BACK) texture_patch("dots", [80,80], 1);
        tag("remove") attach(LEFT,BACK) texture_patch("dots", [80,80] ,1);
    }
}

texture_patch("dots", [80,80], 1);
up(40) color("red") sphere(1);

module texture_patch(texture, size, depth){ 
    region = rect([size.x,0.001]);
    linear_sweep(region, h = size.y, texture = texture, tex_reps = [8,4], tex_depth = depth);
}


