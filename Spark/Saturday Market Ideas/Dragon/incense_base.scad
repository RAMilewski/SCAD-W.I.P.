include<BOSL2/std.scad>

//move([-100,-98]) import("dragon_base.3mf");

$fn = 72;


diff(){
    xscale(1.2) cyl(h = 8, d = 48, rounding2 = 5);
    tag("remove") cyl(h = 4.1, d = 40, anchor = BOT);
}