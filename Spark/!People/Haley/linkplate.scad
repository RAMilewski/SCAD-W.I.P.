include<BOSL2/std.scad>

$fn = 72;
size = [8,27];
shift = 2;
tilt = 40;
stagger = true;

diff() {
    prismoid(size1 = size, size2 = size, h = 2, shift = [0,shift], rounding = size.x/2)
        tag("remove") grid_copies(n = [2,6], size = [9,18], stagger = stagger) back(shift/2) xrot(90-tilt) #torus(d_maj = 13, d_min = 3);
}