include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn = 72;
wall = 3;
zdim = 8;
d1 = 9.6;
d2 = 19.9;
bridge = [50-d1/2-d2/2-2*wall+2, 1.5 * wall, zdim];

holder();

module holder() {
    diff() {
        tube(id = d1, wall = wall, h = zdim, anchor = BOT){
            position(LEFT) right(1) cuboid([2*wall,2*wall+2,zdim], rounding=zdim/2, edges="Y", except=RIGHT, anchor=RIGHT){
                position(FWD) tag("remove") screw_hole("M3", l = wall, head = "none", anchor = TOP, orient=FWD);
                position(BACK) tag("remove") ycyl(d = 4, l=wall, anchor = BACK);
            }
            position(LEFT) tag("remove") cuboid([4*wall, 2, zdim]);
            position(RIGHT) left(1) cuboid(bridge, anchor = LEFT)
                position(RIGHT) left(1) tube(id = d2, wall = wall, h = zdim, anchor = LEFT){
                    position(RIGHT) tag("remove") cuboid([4*wall+3,15,zdim+1]);
                    position(RIGHT) left(2*wall) cuboid([3*wall,15+2*wall,zdim], rounding= zdim/2, edges="Y", except=LEFT, anchor=LEFT){
                        position(FWD) tag("remove") screw_hole("M3", l = 12, head = "none", anchor = TOP, orient=FWD);
                        position(BACK)tag("remove") ycyl(d = 4, l=wall, anchor = BACK);
                    }
                }

        }
    }


}