include <BOSL2/std.scad>

cuboid([47,2,15], anchor = BACK) {
    position(LEFT+BACK) cuboid([2,15,15], anchor = BACK);
    position(RIGHT+BACK) cuboid([2,25,15], anchor = BACK)
        position(LEFT+FWD) cuboid([10,2,15], anchor = LEFT+BACK)
            position(RIGHT+BACK) cuboid([2,2,15], anchor = FWD+RIGHT);
}
