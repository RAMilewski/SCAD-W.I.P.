
include<BOSL2/std.scad>
include<textures/nsfw/eiffel_tower.data>

diff() {
    cuboid(100, rounding = 10){
        attach(FWD,BACK) texture_patch(texdata, [80,80], 1);
        tag("remove") attach(LEFT,BACK) texture_patch(texdata, [80,80] ,1);
    }
}

//texture_patch(texdata, [80,80], 1);


module texture_patch(texture, size, depth){ 
    region = rect([size.x,0.001]);
    linear_sweep(region, h = size.y, texture = texture, tex_reps = [2,1], tex_depth = depth);
}


