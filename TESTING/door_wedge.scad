include <BOSL2/std.scad>
x = 58;
y = 50;
z = 10;
gap = 15;
$fn = 72;

diff() {
    cuboid([x,y,z], rounding = 2){
        tag("remove") position(BACK+LEFT) right(15) 
            cuboid([gap,30,z+.1], rounding = 4, edges = "Z", except = BACK, anchor = BACK+LEFT);
    }
}