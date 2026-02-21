include<BOSL2/std.scad>

box = [103,63,10];

wall = 1.25;
fudge = 2.1 * wall;
corner = 5;


$fn = 72;

box(); fwd(box.y+15) lid();

module box() {
    cuboid([box.x,box.y,wall], rounding = corner-wall, edges = "Z", anchor = BOT)
        position(BOT) rect_tube(isize = [box.x,box.y], l = box.z, wall = wall, rounding = corner, anchor = BOT);
}

module lid() {
    cuboid([box.x,box.y,wall] + [fudge,fudge,0], rounding = corner-wall, edges = "Z", anchor = BOT){
        diff() {
            position(BOT) rect_tube(isize = [box.x,box.y] + [fudge,fudge], l = box.z * .75, wall = wall, rounding = corner, anchor = BOT)
                position(TOP) tag("remove") xscale(2) up(2 * wall) ycyl(l = box.y + 2 * fudge, d = box.x/6);
        }
    }
}