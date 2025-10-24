include<BOSL2/std.scad>
include<netfool_300x300.scad>



diff() {
    cuboid([62,62,5.9])
        position(TOP) textured_tile(netfool, [50,50,.01],tex_depth = 1, tex_reps = [1,1], anchor = BOT);
    tag("remove") cutter(6);
}

//cutter(5);


module cutter(h) {
    difference(){
        cuboid([62,62,h]);
        cyl(h = h, d = 60, rounding2 = 2, $fn = 72);
    }

}