include <BOSL2/std.scad>

$fn=72;

depth = 4;
l1 = 42;
l2 = 46;
r1 = 7.4;
r2 = 8;
theta1 = 168;
theta2 = 156;

cw = 5; //Channel width
wall = 2;

       
path = turtle(["move",l1, "arcright", r1, theta1, "move", l2,
    "arcleft", r2, theta2, "move", l2, "arcright", r1, theta1, 
    "move", l1, "arcleft", r1, 90], repeat=4);

path2 = list_remove(path, len(path)-1);  //Remove path overlap.

tool = turtle(["left", "move",4, "arcright",wall/2,180, "arcleft",cw/2,180,
     "arcright",wall/2,180, "move",4, "right", "move",9]);

path_sweep(tool, path2, closed = true, anchor = BOT);


/*
module SparkLogo(z_size) {
    zrot_copies(n=4, r=56.5, subrot = true)
    zrot(-90)
    text3d("M", h=z_size, font="Arial Black", size=70, atype = "ycenter", center=true, anchor=TOP);
}
/* */