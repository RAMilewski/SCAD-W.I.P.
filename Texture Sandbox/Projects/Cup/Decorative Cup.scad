include <BOSL2/std.scad>
include <celtic-01.scad>

$fn = 72;

diff() {
    cyl(d = 60, h = 25, anchor = BOT, texture=custom, tex_size=[800,200], tex_reps = [2,1], tex_depth=1, tex_rot = 270)
        tag("remove") attach(TOP) rounding_hole_mask(d = 54, rounding = 3);
    tag("remove") up(3) cyl(d=54, h=25, anchor = BOT);
}