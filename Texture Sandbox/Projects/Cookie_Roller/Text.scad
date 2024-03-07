include<BOSL2/std.scad>
include<data.scad>

$fn = 72;

d1=90/PI;
d2=90/6;
hc = 50;
hd = 10;
z = 20;

dd1 = ((z+hd/2)/hc) * (d1-d2) + d2;
dd2 = ((z-hd/2)/hc) * (d1-d2) + d2;
echo(dd1);

*cuboid([90,10,0.25], anchor = BOT)
    attach(TOP)
        heightfield(data, size = [90,10], bottom = -1e-12, maxz = 1);

*back(25) left(30)
    linear_sweep(circle(d = 90/PI), h = 10, texture = data, tex_reps = [1,1]);

//back(25) right(30)
   up(z) cylindrical_heightfield(d1 = dd1, d2 = dd2, aspect = .7, h = 10, data = data, anchor = BOT);
   cyl(d1 = d1, d2 = d2, h = 50, anchor = BOT);

