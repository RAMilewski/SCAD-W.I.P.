include <BOSL2/std.scad>

$fn = 64;
tube(h = 60, id = 65, wall = 0.75, anchor = BOT) {
    zrot_copies(n = 8, r = 8) position(BOT) cuboid([25,0.75,55], anchor = BOT+LEFT);
    position(BOT) tube(h = 55, od = 16.5, wall = 0.75, anchor = BOT);
}