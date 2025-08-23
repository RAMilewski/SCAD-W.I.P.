include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn = 72;
wall = 3;
block = [59,28,90];
hole = [22,12,wall*2];
diff() {
    cuboid([block.x, block.y, 2] + [2 * wall, 2 * wall, 0], rounding = 3, edges = "Z", anchor = BOT){
        position(TOP) rect_tube(h = 90, isize = [block.x,block.y], wall = wall, rounding = 3, irounding = 2)
            attach(BACK) back(20) xrot(180) #screw_hole("#6",l = wall, head="flat sharp", counterbore=0, anchor=BOT);
        position(TOP+FWD) tag("remove") cuboid([block.x/3, wall*2, block.z], rounding = -block.x/4, edges = [TOP+LEFT,TOP+RIGHT], anchor = BOT);
        position(CENTER) tag("remove") cuboid(hole, rounding = 3, edges = "Z", anchor = CENTER);
    }

}