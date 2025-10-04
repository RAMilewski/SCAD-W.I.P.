include <BOSL2/std.scad>

difference() {
    scale([.33,.33,.1]) surface("Bunny1d.png");
    cuboid([200,200,1]);
}