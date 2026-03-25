include<BOSL2/std.scad>

/* [Body] */
dmax = 55;
zmax = 4;
wall = 1.5;
segments = 5;

/* [Snap] */
dsnap = 6;
snapgap = 1;

/* [Texture] */
texture = true; // [true,false]
toptex  = true; // [true,false]
depth = -0.6;

/* [[Show Part] */
top = false;    // [true,false]
bottom = false; // [true,false]

/* [Hidden] */
$fn = 144;
shift = top && bottom ? dmax/1.8 : 0;

if (top) {
    if (toptex) { top(); } else { top_half(s = 200) top(); }
}

if (bottom) {
    if (!toptex) { bottom(); } else { down(abs(depth)) bottom(); }
}


module top() {
    left(shift)
    //zrot(360/40)
    diff(){
        cyl(d=dmax, h = wall + zmax -1, rounding1 = 0, texture = "", tex_depth = depth, tex_reps = [20,1], anchor = BOT) {
            position(BOT) down(1) tag("remove") pie_slice(ang = 360/segments, d=dmax-5, h = zmax+wall, anchor = BOT);
            position(TOP) up(0.1) tag("remove") cyl(d = dmax - 2 * wall, h = zmax-1.1, anchor = TOP );
            position(BOT) tag("keep") cyl(d = dsnap, h = zmax-0.5, anchor = BOT)
                position(TOP) zscale(.75) torus(d_maj = 6, d_min = 1, anchor = TOP);
        }
    }
}


module bottom() {
    right(shift)  
    diff(){
        cyl(d=dmax - 2.5 * wall, h = wall, anchor=BOT) {
            position(TOP) tube(od = dmax - 2.5 * wall, h = zmax - wall - .5, 
                irounding2 = wall/2, orounding2 = wall/2, anchor = BOT);
            position(TOP) tube(id = dsnap+snapgap, h = 2, orounding1 =  -1, anchor = BOT){
                position(TOP) torus(d_maj = dsnap+snapgap, d_min = .75, anchor = TOP);
                tag("remove") rot_copies(n=9) position(TOP) cuboid([0.5,15,2], anchor = TOP);    
            }
        }
    }
}
    //zrot(360/40) 
    //up(5) ruler();