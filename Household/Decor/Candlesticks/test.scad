include <BOSL2/std.scad>

$fn=72;

depth = 4;
l1 = 42;
l2 = 46;
r1 = 7.4;
r2 = 5;
theta1 = 168;
theta2 = 156;

tool = union([circle(2.5), left(2.5, square(5))]);
       
path = turtle(["move",l1, "arcright", r1, theta1, "move", l2,
    "arcleft", r2, theta2, "move", l2, "arcright", r1, theta1, 
    "move", l1, "arcleft", r1, 90], repeat=4);

path2 = list_remove(path, len(path)-1);  //Remove path overlap.


    move([15.5,12]) {
        difference() {
            SparkLogo(depth*1.5);
            down(depth) path_sweep(tool, path2, closed = true, anchor = BOT);
        }
    }


module SparkLogo(z_size) {
    zrot_copies(n=4, r=56.5, subrot = true)
    zrot(-90)
    text3d("M", h=z_size, font="Arial Black", size=70, atype = "ycenter", center=true, anchor=CENTER+TOP);
}