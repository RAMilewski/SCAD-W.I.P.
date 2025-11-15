include<BOSL2/std.scad>

mouth = 80;
spout = 20;
wall = 2;
height = 40;
$fn = 72;

tube (id1 = mouth, id2 = spout, wall = wall,  h = height) {
    attach(TOP,BOT) tube(id = spout, wall = wall, height = spout)
        torus(d_maj = spout + 2 * wall, d_min = 2 * wall);
}