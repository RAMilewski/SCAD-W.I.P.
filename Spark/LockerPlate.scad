include <BOSL2/std.scad>

$fn = 64;

ctr_hole = 16.5;
mnt_hole = 5;
span = 55.2;

corner = 5;

plate = [47,72,3];
logoZ = plate.z + 0.75;

echo(plate.y/plate.x);

diff() {
    yscale(plate.y/plate.x) zrot(45) cuboid([plate.x, plate.x, plate.z], 
        rounding = corner, edges = "Z", anchor = BOT);
    ycopies(n=2, l = span) tag("remove") cyl(h = plate.z+.1, d = mnt_hole , anchor = BOT);
}
zrot(45) zrot_copies(r = 5, n = 4)
    color("blue") zrot(-90) text3d("M", size = 15, h = logoZ, font="arial black", anchor = BOT);

//color("crimson") cyl(h = logoZ, d = ctr_hole, anchor = BOT);


//right(50)  cuboid(30, rounding = 5, edges = "Z");