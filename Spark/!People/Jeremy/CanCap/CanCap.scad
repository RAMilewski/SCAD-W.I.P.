include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>

$fn = 72;

/* [Body] */
dia = 56;
r = dia/2 + 1;
h = 6;
wall = 1;
floor = 1.5;

/* [Grip Lip]) */
d1 = dia - 2;
d2 = 1.5;

/* [Tab] */
magnet_dia = 6;
magnet_h = 3.5;
offset = magnet_dia;


data = [[-r,0],[0,r + offset],[r,0],[0,-r]];

path = nurbs_curve(nurbs_interp(data,3, closed = true, extra_pts = 3));



diff() {
    linear_sweep(path,h)  fwd((offset)/2) {
        position(BOT) up(floor) tag("remove") cyl(h = h , d = dia - wall * 2, anchor = BOT);
        position(TOP) down(d2) tag("keep")torus(d_maj = d1, d_min = d2, anchor = BOT);  //Grip lip
        position([TOP+BACK]) fwd(magnet_dia/4) tag("remove") cyl(magnet_h, d1 = magnet_dia, d2 = magnet_dia + 0.5, anchor = TOP);      // Hole for 6 x 1.75 magnets
    }
}