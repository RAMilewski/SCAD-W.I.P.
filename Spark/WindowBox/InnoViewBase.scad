include<BOSL2/std.scad>

$fn = 72;

bar =[210,25];
slot = [bar.x, 4.25, 6];
standgap = 15;
dia = 20;
theta = 14;
 




diff() {
    prismoid(size1 = bar, size2 = [bar.x, bar.y/2], shift = [0,-bar.y/4], h = bar.y, rounding = 5, anchor = BOT)
        tag("remove") {
            position(TOP) xrot(theta) up(1) cuboid(slot, anchor = TOP);
            position(TOP+FWD) right(15)  cuboid([standgap,2*slot.y,slot.z+1], anchor = TOP+FWD);
        }
}