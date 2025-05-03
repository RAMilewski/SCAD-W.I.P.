include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn = 72;
dia = 45;
wall = 2;
gap = 8;
height = 30;

diff() {
    cyl(d = dia+5, h = wall, rounding = wall/2, teardrop = true, anchor = BOT) {
        position(TOP) up(6) cyl(d = dia * .85, h = 3, rounding = 1.5);
        attach(TOP,BOT) cyl(d1 = dia * .75, d2 = dia-gap, h = height, rounding2 = 2)
            position(TOP) 
                screw_hole("#6,1",head="flat",head_oversize = 2, counterbore = height/2 ,anchor=TOP);
    }
}
