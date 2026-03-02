include<BOSL2/std.scad>
include<BOSL2/threading.scad>

$fn = 64;

spacing = 100;
size = [119,119,4];
hole_size = 4.5;

layer_0 = rect(size.x * 0.8, rounding = 10, anchor = CENTER);
layer_1 = circle(d = size.x * 0.6); 
layer_2 = circle(d = size.x * 0.4); 
layer_3 = circle(d = 25); 

//back_half(s = 200)
diff(){
    cuboid(size, rounding = 5, edges="Z", anchor = BOT) {
        grid_copies(n = [2,2], spacing = spacing) tag("remove") cyl(h = size.z+.01, d = hole_size);
        position(TOP) skin([layer_0,layer_1,layer_2,layer_3], z = [0,5,10,20], slices = 10){
                position(TOP) threaded_rod(d = 25, l = 150, pitch = 4, bevel2 = true, anchor = BOT); 
                tag("remove") position(TOP) cyl(d =12, h = 150, anchor = BOT);
        }
    }
}