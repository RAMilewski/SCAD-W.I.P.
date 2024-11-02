include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

$fn = 72;
core = 7.5;
base() show_anchors();
cyldim = [90, 88, 4];

module base(anchor = BOT) {
    bez = [[44,0],[20,10],[core,30],[core,40]];
    path = bezpath_curve(bezpath_close_to_axis(bez,"Y"));

    h = bez[3][1] + cyldim.z;
    echo(h=h);
    attachable(anchor, h = h, d1 = cyldim[0], r2 = core) {
        down(h/2)
            cyl(d1 = cyldim[0], d2 = cyldim[1], h = cyldim.z, anchor=BOT)
                position(TOP) rotate_sweep(path, 360);
        children();
    }
}
