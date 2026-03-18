include<BOSL2/std.scad>

$fn = 144;
dmax = 55;
zmax = 6;
zbase = 2;
wall = 1.5;
post = [6,zmax-wall];
win = 5;

//back_half()

diff(){
    cyl(d=dmax, h = wall, rounding1 = 1, anchor = BOT) {
        position(BOT) tag("remove") pie_slice(ang = 360/win, d=dmax-5, h = zmax+.1, anchor = BOT);
        position(TOP) tube(od = dmax, wall = wall, h=zmax-1, irounding2 = 1, rounding2 = 1, anchor = BOT);
        position(BOT) tag("keep") cyl(d = 6, h = zmax-wall, anchor = BOT)
            position(TOP) torus(d_maj = 6, d_min = 1, anchor = TOP);
    }
}


right(75)
back_half()
    diff(){
        cyl(d=dmax - 2 * wall, h = wall, anchor=BOT) {
            position(TOP) tube(id = 6.5, h = 3, orounding1 =  -3, anchor = BOT){
                position(TOP) torus(d_maj = 6, d_min = 1, anchor = TOP);
                tag("remove") up(wall) rot_copies(n=4) position(TOP) cuboid([1,10,3], anchor = TOP);    
            }
        }
    }