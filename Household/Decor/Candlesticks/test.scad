include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

$fn = 72;

core = 7.5;

base();

module base(anchor = BOT) {
    bez = [[44,0],[20,10],[core,30],[core,40]];
    path = bezpath_curve(bezpath_close_to_axis(bez,"Y"));
    cyl(d1 = 90, d2 = 88, h = 4, anchor = anchor)
    attachable(anchor, h = bez[1][1], r = bez[0][0]) {
        position(TOP) rotate_sweep(path, 360, anchor = anchor);
        children();
    }
}

