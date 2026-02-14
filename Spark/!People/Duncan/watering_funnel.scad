include<BOSL2/std.scad>

$fn = 72;

d1 = 40;
z1 = 5;
z2 = 20;
d_stem = 20;
z_stem = 70;
d2_end = 5;
z_end = 25;
offset = 5;
band = 5;

wall = 1;


tube(od = d1, h = z1, wall = wall)

        position(TOP) tube(od1 = d1, h = z2, od2 = d_stem, wall = wall, anchor = BOT)
            diff() {
                position(TOP) tube(od = d_stem, h = z_stem, wall = wall, anchor = BOT) {
                    position(TOP) tag("keep") tube(od1 = d_stem, id2 = d2_end, h = z_end, wall = wall, anchor = BOT);
                    position(TOP) down(offset) zrot_copies(n = 3) tag("remove") #xcyl(h = d_stem + 10, d = 4);
                    position(TOP) down(offset+band) zrot(360/12) zrot_copies(n = 3) tag("remove") #xcyl(h = d_stem + 10, d = 4);
                    position(TOP) down(offset+band*2) zrot_copies(n = 3) tag("remove") #xcyl(h = d_stem + 10, d = 4);
                }
            }