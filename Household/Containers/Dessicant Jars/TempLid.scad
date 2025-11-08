include<BOSL2/std.scad>

$fn = 144;

diff() {
    cyl(h = 2, d = 90, anchor = BOT){
        tag("remove") cyl(h = 2.1, d = 41.5);
        position(BOT) tube(id = 88, h = 15, wall = 2, anchor = BOT);
    }
}