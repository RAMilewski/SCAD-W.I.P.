include<BOSL2/std.scad>

$fn = 64;
box = [160,15,50];
base = [180,40,3];
wall = 2;

diff(){
    cuboid(base,rounding = 3, edges = [TOP,"Z"], anchor = BOT)
        position(TOP) cuboid([box.x + 4, box.y + 4, 4], rounding = -wall, edges = BOT, anchor = BOT)
            position(TOP) rect_tube(h = box.z, wall = wall, isize = [box.x,box.y], 
                rounding2 = wall, anchor = BOT);

    up(box.z/2 + base.z + 4) xrot(90)
    grid_copies(n = [16,4], size = [box.x * .9, box.z * .7], stagger = false)
        tag("remove") yscale(2) zrot(30) cyl(l = box.y * 2, d = 5, $fn = 6);
}