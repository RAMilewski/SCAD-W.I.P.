include <BOSL2/std.scad>
x = 56;
y = 50;
z = 20;
$fn = 72;

diff() {
    cuboid([x,y,z], rounding = 4){
        tag("remove") position(BACK+LEFT) right(15) 
            cuboid([13,30,z], rounding = 4, edges = "Z", except = BACK, anchor = BACK+LEFT);
    }
}