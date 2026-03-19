include<BOSL2/std.scad>

$fn = 64;
dmax = 55;
wall = 2;
win= 5;

//back_half()

diff(){
    cyl(d=dmax, h = 3, rounding1 = 1, anchor = BOT) {
        position(BOT) tag("remove") pie_slice(ang = 360/win, d=dmax-5, h = 5, anchor = BOT);
        position(TOP) tube(od = dmax, wall = wall, h=5, irounding2 = 1, rounding2 = 1, anchor = BOT);
        position(BOT) tag("keep") cyl(d = 6, h = 8, anchor = BOT)
            position(TOP) torus(d_maj = 6, d_min = 1, anchor = TOP);
    }
}


right(75)
//back_half()
    diff(){
        cyl(d=dmax - 2 * wall, h = 3, anchor=BOT) {
            position(TOP) tube(id = 6.5, h = 4, anchor = BOT){
                position(TOP) torus(d_maj = 6, d_min = 1, anchor = TOP);
                tag("remove") rot_copies(n=4) position(TOP) cuboid([1,10,5], anchor = TOP);    
            }
        }
    }