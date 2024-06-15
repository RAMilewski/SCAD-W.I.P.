
include<BOSL2/std.scad>
include<Textures/test.data> 
$fn = 32;
diff() {
    cuboid(100, rounding = 10){
        attach(LEFT,BACK) texture_tile(texdata, [80,62.5], 1);
        tag("remove") attach(FWD,BACK) texture_tile(texdata, [80,62.5] ,1);
        attach(TOP,BACK) move([20,15,0]) texture_tile(texdata, [40,31], 2);
        tag("remove") attach(TOP,BACK) move([-21,-15,0]) texture_tile(texdata, [40,31] ,2);
        

    }
}


module texture_tile(texture, size, depth){ 
    region = rect([size.x,0.01]);
    linear_sweep(region, h = size.y, texture = texture, tex_reps = [2,1], tex_depth = depth);
}


/* */
