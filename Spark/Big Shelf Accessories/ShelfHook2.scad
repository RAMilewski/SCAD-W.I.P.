include <BOSL2/std.scad>
$fn = 72;
A = 12;
B = 6;
C = 2.5;
D = 5;
fudge = 1;
base = [35, 35, D];
loop = 30;

//hook();
post();
module hook(){
    xscale(0.5) cyl(d = base.y, h = base.z, anchor = BOT);
    post();
    cuboid(base, anchor = LEFT+BOT);
    right(base.x) loop();
    right(base.x) up(loop - D) left_half() xscale(0.5) cyl(d = base.y, h = base.z, anchor = BOT);
}


module loop() {
    right_half(s=200)
    xrot(90) tube(od = loop, h = base.y, wall = base.z, anchor = FWD);
}



module post() {
    cyl(d = B, h = C, anchor = TOP)
    position(BOT) cyl(d = A, h = C, rounding1 = 0.5, rounding2 = 0.5, anchor = TOP);
}