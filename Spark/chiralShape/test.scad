include<BOSL2/std.scad>


diff() {
    back_half() cuboid(50);
    tag("remove") scale(0.25) import("chiralShape.stl");

}


