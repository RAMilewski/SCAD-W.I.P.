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

top = false;    // [true,false]
bottom = false; // [true,false]


if (top) {
    left(dmax/1.8)
    diff(){
        cyl(d=dmax, h = wall + zmax -1, rounding1 = 1, texture = "wave_ribs", tex_depth = -0.6, tex_reps = [20,1], anchor = BOT) {
            position(BOT) down(1) tag("remove") pie_slice(ang = 360/win, d=dmax-5, h = zmax+wall, anchor = BOT);
            position(TOP) tag("remove") cyl(d = dmax - 2 * wall, h = zmax-1, anchor = TOP );
            position(BOT) tag("keep") cyl(d = dsnap, h = zmax-0.5, anchor = BOT)
                position(TOP) zscale(.75) torus(d_maj = 6, d_min = 1, anchor = TOP);
        }
    }
}


if (bottom){
    right(dmax/1.8)
    diff(){
        cyl(d=dmax - 2.5 * wall, h = wall, anchor=BOT) {
            position(TOP) tube(od = dmax- 2.5 * wall, h = zmax - wall - .5, 
                irounding2 = wall/2, orounding2 = wall/2, anchor = BOT);
            position(TOP) tube(id = dsnap2, h = 2, orounding1 =  -1, anchor = BOT){
                position(TOP) torus(d_maj = dsnap2, d_min = .75, anchor = TOP);
                tag("remove") rot_copies(n=9) position(TOP) cuboid([0.5,15,2], anchor = TOP);    
            }
        }
    }
}
    //zrot(360/40) 
    //up(5) ruler();