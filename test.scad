include <BOSL2/std.scad>

cuboid([10, 10, 10]) {
    position(TOP+LEFT) cuboid([5, 5, 5], anchor=BOTTOM+LEFT); // cube 1
    position(LEFT) cuboid([5, 5, 5]); // cube 2
}
