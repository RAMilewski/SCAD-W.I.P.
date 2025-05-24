include <BOSL2/std.scad>

cuboid(30)
    attach(TOP,BOT) prismoid([30,30],[15,15],h=2);