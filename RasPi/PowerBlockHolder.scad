include <BOSL2/std.scad>

$fn = 72;
wall = 2;
block = [59,28,90];
hole = [22,12,wall*2];
diff() {
    cuboid([block.x, block.y, 2] + [2 * wall, 2 * wall, 0], rounding = 3, edges = "Z", anchor = BOT){
        position(TOP) rect_tube(h = 90, isize = [block.x,block.y], wall = wall, rounding = 3, irounding = 2);
        position(TOP+FWD) tag("remove") cuboid([block.x/3, wall*2, block.z], rounding = -block.x/4, edges = [TOP+LEFT,TOP+RIGHT], anchor = BOT);
        position(CENTER) tag("remove") cuboid(hole, rounding = 3, edges = "Z", anchor = CENTER);
    }

}