include<BOSL2/std.scad>

$fn = 144;
dmax = 55;
zmax = 4;
dsnap = 6;
dsnap2 = dsnap + 1;
zbase = 2;
wall = 1.5;
post = [6,zmax-wall];
win = 5;

//back_half()

diff(){
    cyl(d=dmax, h = wall, rounding1 = 1, anchor = BOT) {
        position(BOT) tag("remove") pie_slice(ang = 360/win, d=dmax-5, h = zmax+.1, anchor = BOT);
        position(TOP) tube(od = dmax, wall = wall, h= zmax-1, irounding2 = 1, rounding2 = 1, 
            texture = "trunc_ribs", tex_depth = 0.5, tex_reps = [1,20], anchor = BOT);
        position(BOT) tag("keep") cyl(d = dsnap, h = zmax-1, anchor = BOT)
            position(TOP) zscale(.75) torus(d_maj = 6, d_min = 1, anchor = TOP);
    }
}


right(75)
    //back_half()
    diff(){
        cyl(d=dmax - 2.5 * wall, h = wall, anchor=BOT) {
            position(TOP) tube(od = dmax- 2.5 * wall, h = zmax - wall - .5, anchor = BOT);
            position(TOP) tube(id = dsnap2, h = 2, orounding1 =  -1, anchor = BOT){
                position(TOP) torus(d_maj = dsnap2, d_min = .75, anchor = TOP);
                tag("remove") rot_copies(n=9) position(TOP) #cuboid([0.5,15,2], anchor = TOP);    
            }
        }
    }