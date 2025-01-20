include<BOSL2/std.scad>
include <BOSL2/rounding.scad>

$fn = 64;

wall = 5;
base = [75,wall,30];
arm = [wall,51,30];
notch = [42,10,wall+.1];
mnt_hole = 4;

diff() {
    cuboid(base, rounding = wall/2, teardrop = true) {
        xcopies(n=2, l = base.x * .4) move([4,0,7]) tag("remove") ycyl(h = base.y+.1, d = mnt_hole);
        position(LEFT+BOT) right(wall/2) cuboid(arm, rounding = wall/2, except = [BACK,FWD], teardrop = true, anchor = BOT+BACK)
            position(FWD+LEFT+BOT) cuboid(base, rounding = wall/2, teardrop = true, anchor = LEFT+BOT);
    }
      tag("remove") move([5,-51,10]) xrot(90) rounded_prism(rect([notch.x, notch.y]), height=notch.z, 
            joint_top = -wall/2, joint_bot = -wall/2, 
            joint_sides = [8,8,0,0], k = 0.5);

}