include<BOSL2/std.scad>

/* [Body] */
dmax = 55;
zmax = 4;
wall = 1.5;
segments = 5;       //[2:1:18]
topcorner = 1;      //[0:0.25:3.5]

/* [Snap] */
dsnap = 6;
snapgap = 1;
teeth = 18;         // [3:1:18]
toothgap = 0.5;     // [0.5:0.1:1.5]  
fillet = 1;         // [0.25:0.25:2]

/* [Edge Fluting] */
edgeflute = true;   // [true,false]
depth = 0.6;        // [0:0.1:3]
count = 36;         // [4:1:100]

/* [[Show Part] */
top = true;        // [true,false]
bottom = true;     // [true,false]

/* [Hidden] */
$fn = 144;
firstview=$vpr==[55,0,25];
$vpt = firstview ? [0,0,0]  : $vpt;
$vpr = firstview ? [30,0,0] : $vpr;
$vpd = firstview ? 200      : $vpd;
fudge = edgeflute ? depth : 0 ;
shift = top && bottom ? dmax/2 + fudge : 0;


if (top) {
    if (!edgeflute) { top(); } else { top_half(s = 200) top(); }
}

if (bottom) {bottom(); }
   


module top() {
    left(shift + wall)
    diff(){
        shell() {
            position(BOT) down(1) tag("remove") pie_slice(ang = 360/segments, d=dmax-5, h = zmax+wall, anchor = BOT);
            position(BOT) up(wall) tag("remove") cyl(d = dmax - 2 * wall, h = zmax-.99, anchor = BOT );
            position(BOT) tag("keep") cyl(d = dsnap, h = zmax-0.5, anchor = BOT)
                position(TOP) zscale(.75) torus(d_maj = 6, d_min = 1, anchor = TOP);
        }
    }
}

module shell(l = wall + zmax-1, d = dmax, orient = DOWN, spin = 0, anchor = TOP) {
    attachable(orient,spin,anchor){
        if (edgeflute) { cyl(d=dmax, l = wall + zmax -1, texture = "wave_ribs", tex_depth = depth, tex_reps = [count,1], anchor = BOT); }
        else { cyl(d=dmax, l = wall + zmax -1, rounding1 = topcorner, teardrop = true, anchor = BOT); } 
        children();
    }
}


module bottom() {
    right(shift)  
    diff(){
        cyl(d=dmax - 2.5 * wall, h = wall, anchor=BOT) {
            position(TOP) tube(od = dmax - 2.5 * wall, h = zmax - wall - .5, 
                irounding2 = wall/2, orounding2 = wall/2, anchor = BOT);
            position(TOP) tube(id = dsnap+snapgap, h = 2, orounding1 =  -fillet, anchor = BOT){
                position(TOP) torus(d_maj = dsnap+snapgap, d_min = .75, anchor = TOP);
                tag("remove") zrot_copies(n=teeth, r = dsnap-2) position(TOP) cuboid([dsnap/2,toothgap,2], anchor = TOP);    
            }
        }
    }
}
