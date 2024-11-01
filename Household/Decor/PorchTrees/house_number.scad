
include<BOSL2/std.scad>
include<textures/7shape.data>
include<textures/pebbles-1.data>
$fn = 64;
pts = 156;
thickness = 5;
hanger_offset = [0,15];
hanger_l = 50;
glyph_z = 11;



//right_half(s = 200, x = hanger_offset.x) 
diff() {
    glyph() {
        tag("remove") up(glyph_z - 1) back(75) xrot(90) texture_tile(texdata, [100,150,0.001], depth = 2);
        tag("remove") up(1) cuboid([380,380,3])
            position(TOP) move(hanger_offset) ycopies(n = 2, l = hanger_l) zrot(180) #hanger();

    }
}

module glyph() {
    attachable(){
        zscale(glyph_z) heightfield(size = [125,125], bottom = 0.1, data = shapedata, anchor = BOT);
        children();
    }
}

module hanger(r1= 3, r2=1.6, l=8, h1=1.5, h2 = 3.2) {
        linear_sweep(keyhole(l = l, r1 = r1, r2 = r2), h1);
        up(h1) fwd(r1 + r2 - 1) zrot(90) linear_sweep(glued_circles(r = r1, spread = l, tangent=0),h2);
    }


module texture_tile(texture, size, reps, depth, style, samples, anchor, spin, orient){ 
    region = rect([size.x,0.01]);
    attachable(anchor, spin, orient, size){
        linear_sweep(region, h = size.y, texture = texture, tex_reps = [2,1], tex_depth = depth, anchor = anchor);
        children();
    }
}

module digit(n) {
    text3d("3",thickness,pts,"Trattatello", center = true);
}


/*



/*

    difference() {
        object1(1);
        #cyl(10);
    }

diff() {
    cuboid(100, rounding = 10){
        attach(LEFT,BACK) texture_tile(texdata, [80,80], 1);
        tag("remove") attach(FWD,BACK) texture_tile(texdata, [80,80] ,1);
        attach(TOP,BACK) move([20,20]) texture_tile(texdata, [40,40], 2);
        tag("remove") attach(TOP,BACK) move([-20,-20]) texture_tile(texdata, [40,40] ,2);
    }
}
/* */