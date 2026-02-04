include<BOSL2/std.scad>

$fn = 64;
dia = 45;
wall = 3;
height = 50;

back_half(y = -6) {
    tube(id = 45, wall = wall, h = height, rounding2 = wall/2, irounding2 = wall/2) {
        attach(BOT,TOP) cyl(h = wall, d = 51);
    }
}
        fwd(6+wall/2) down(wall/2) cuboid([50,wall,height+wall], rounding = wall/2, except = [BACK,BOT]);

//fwd(6) xrot(90) ruler();