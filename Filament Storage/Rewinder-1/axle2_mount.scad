include<BOSL2/std.scad>

$export_name="axle2_mount_v2";

$fn = 72;

block = [30,18,5];
groove = [3,2.3,18];
hole = 7.9;
ring = 3;


//back_half()
diff() {
    cuboid(block, rounding = 4, teardrop = true, edges = ["Z",BOT+RIGHT]){
        tag("remove")  position(BOT+RIGHT) yrot(90) cuboid(groove, rounding = -4, 
            edges = TOP, except = [LEFT,RIGHT], anchor = TOP+RIGHT);
        tag("remove") up(.5) cyl(h = block.z, d = hole, $fn = 36);
        //tag("keep") position(BOT) left_half(x = -3) cyl(h = ring - 0, d = hole, anchor = BOT); 
        tag("keep") position(TOP) tube(h = ring, wall = 2, rounding2 = 1, id = hole, anchor = BOT);
    }
}
