include<BOSL2/std.scad>

$fn = 72;
r1 = 36;
r2 = 6;
offset = -4;

wall = 2;
h = 10;

outer = hull_region([circle(r1+wall), right(r1+wall+offset, circle(r2))]);
inner = hull_region([circle(r1), right(r1+offset, circle(r2))]);
reg = difference(outer, inner);

linear_sweep(reg,h);