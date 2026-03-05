include<BOSL2/std.scad>
include<BOSL2/threading.scad>
include<BOSL2/screws.scad>


$fn = 64;

spacing = 100;
size = [119,119,4];
hole_size = 4.5;
shaft = [30,undef,200];
bar_dia = 13;

layer_0 = rect(size.x * 0.8, rounding = 10, anchor = CENTER);
layer_1 = circle(d = size.x * 0.6); 
layer_2 = circle(d = size.x * 0.4); 
layer_3 = circle(d = 25); 

pimount();


module vesa(shaft) {
    //back_half(s = 200)
    diff(){
        cuboid(size, rounding = 5, edges="Z", anchor = BOT) {
            grid_copies(n = [2,2], spacing = spacing) tag("remove") cyl(h = size.z+.01, d = hole_size);
            position(TOP) skin([layer_0,layer_1,layer_2,layer_3], z = [0,5,10,20], slices = 10) {
                position(TOP) threaded_rod(d = 25, l = shaft.z, pitch = 4, bevel2 = true, anchor = BOT); 
                tag("remove") position(TOP) cyl(d =12, h = shaft.z, anchor = BOT);
            }
        }
    }
}

module mount(length) {
    tag_scope()
    diff() {
        top_half() sphere(d = shaft.x);
        ringnut(length);
        tag("remove") ycyl(d = bar_dia, h = shaft.x);
        tag("remove") xcopies(n = 2, spacing = shaft.x * 0.75) cyl(h = 6, d1 = 4.2, d2 = 4, anchor = BOT);
    }
}


module cap() {
    diff(){
        top_half() zscale(0.8) sphere(d = shaft.x);
        tag("remove") ycyl(d = bar_dia, h = shaft.x);
        tag("remove") xcopies(n = 2, spacing = shaft.x *.75) #screw_hole("m3,5", head = "socket", counterbore = 15, anchor = BOT);
    }
}

module ringnut(height) {
    tag_scope()
    diff(){
        cyl(d = 30, h = height, anchor = BOT,  $fn = 64)
            tag("remove") position(BOT) 
                #threaded_rod(d = 25, l = height, pitch = 4, internal = true, bevel = false, anchor = BOT, $slop = 0.1, $fn = 64);
    }
}


module pimount() {
    diff() {
        cyl(l = 5, d = 30, anchor = BOT);
        zrot(90) fwd(10) #linear_sweep(trapezoid(h = 20, w1 = 65 , w2 = 30, rounding = [0,0,0,0]),2);
        move([18.4,-32.6,0.5]) import("bottom.stl");
        tag("remove") cyl(l = 5, d = 26, anchor = BOT);
    }
}

/**/