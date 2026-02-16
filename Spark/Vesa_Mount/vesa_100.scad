include<BOSL2/std.scad>

$fn = 64;

spacing = 100;
size = [119,119,4];
hole_size = 4.5;

layer_0 = rect(size.x * 0.8, rounding = 10, anchor = CENTER);
layer_1 = circle(d = size.x * 0.6); 
layer_2 = circle(d = size.x * 0.4); 
layer_3 = circle(d = size.x * 0.2); 


diff(){
    cuboid(size, rounding = 5, edges="Z", anchor = BOT) {
        grid_copies(n = [2,2], spacing = spacing) tag("remove") cyl(h = size.z+.01, d = hole_size);
        position(TOP) skin([layer_0,layer_1,layer_2,layer_3], z = [0,10,25,30], slices = 10);
    }
}