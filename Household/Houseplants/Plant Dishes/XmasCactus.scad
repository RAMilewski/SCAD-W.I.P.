include<BOSL2/std.scad>

debug_bez = false;  //[true,false]
r_base = 60;
r_top = 70;
height = 50;
wall = 1.5;  //[0.5:0.25:4]
cp1 = 10;
cp2 = 0;
n_ribs = 0;

$fn = 288;

bez = [[r_base,0], [r_base+cp1,height/2], [r_top+cp2,height/2], [r_top,height]];
if (debug_bez) {
    debug_bezier(bez);
} else {
    path = offset_stroke(bezier_curve(bez, splinesteps = 32), [0,wall]);
    rotate_sweep(path,360);
    line = [[0,2], [30,2]];
    u = bezier_line_intersection(bez,line).x;
    r2 = bezier_points(bez,u).x;
    cyl(h = wall, r1 = bez[0].x, r2 = r2, anchor = BOT)
            zrot_copies(n = n_ribs) position(TOP) right(5) xcyl(l = r_base - 5, d = wall*2, rounding1 = wall, anchor = LEFT);
}