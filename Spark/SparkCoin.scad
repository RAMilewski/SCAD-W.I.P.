include <BOSL2/std.scad>

$fn = 64;

ctr_hole = 16.5;
mnt_hole = 5;
span = 55;

corner = 4;

dia = 75;  //coin diameter

logoZ = 5;

cyl(h = 5, d = dia, rounding2 = corner, anchor = BOT)
zrot(45) zrot_copies(r = 5.75, n = 4)
    position(TOP) color("blue") zrot(-90) text3d("M", size = 18, h = 3, font="arial black", anchor = BOT);

//zrot(90) up(4) ruler();