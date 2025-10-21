include<BOSL2/std.scad>

cq = [91,49,15];

wall = 1.5;
fudge = 2.1 * wall;
corner = 8;


$fn = 72;

box(); fwd(cq.y+15) lid();

module box() {
    cuboid([cq.x,cq.y,wall], rounding = corner-wall, edges = "Z", anchor = BOT)
        position(BOT) rect_tube(isize = [cq.x,cq.y], l = cq.z, wall = wall, rounding = corner, anchor = BOT);
}

module lid() {
    cuboid([cq.x,cq.y,wall] + [fudge,fudge,0], rounding = corner-wall, edges = "Z", anchor = BOT){
        diff() {
            position(BOT) rect_tube(isize = [cq.x,cq.y] + [fudge,fudge], l = cq.z * .75, wall = wall, rounding = corner, anchor = BOT)
                position(TOP) tag("remove") xscale(2) up(1) ycyl(l = cq.y + 2 * fudge, d = cq.x/6);
        }
    }
}