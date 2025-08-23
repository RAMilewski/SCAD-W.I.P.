include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>
include<interpolator2.scad>


// Example (2D): cubic B-spline (p=3), uniform clamped knots.
ctrl = [ [0,0], [20,30], [60,30], [80,0], [100,40], [140,0]];
p = 3;
n = len(ctrl);
knots = concat( [for (i=[0:p]) 0],           // p+1 zeros
                [for (i=[1:n-p-1]) i],       // uniform interior
                [for (i=[0:p]) n-p-1] );     // p+1 repeats at end
weights = [ for (i=[0:n-1]) 1 ];             // all weights = 1

// Draw with adaptive tolerance:
draw_nurbs(ctrl, p, knots, w=weights, tol=0.25, max_depth=12, width=0.7);
