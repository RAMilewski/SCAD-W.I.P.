include <BOSL2/std.scad>

part = "shell";  //[shell,cap,base]
$fn = 288;      //[10:288]

/* [Mason Jar Ring] */
top_id = 67;    //id of mason jar ring
top_od = 71;    //od of mason jar ring
top_hole = 55;  //dia of hole in jar ring
top_h = 13;     //height

/* [Shell] */
equator_r = 60; //[30:60]
height = 150;   //[40:200] 
shaper = 30;    //[5:60]
shaper1 = 10;   //[1:20]

/* [Hidden] */
r1 = top_id/2;
h1 = top_h;
h2 = height;

if (part == "shell") {
    bez = flatten([
        bez_begin([0,0], 0, 10),
        bez_joint([r1,0], 180,90, 30,30),
        bez_joint([r1,h1], -90,45, 10,shaper1),
        bez_tang([equator_r,(h1+h2)/2], 90,shaper),
        bez_joint([r1,h2], -45,90, shaper1,10),
        bez_joint([r1,h1+h2], -90,180, 10,10),
        bez_end([0,h1+h2], 0, 10),
    ]);
    path = bezpath_curve(bez, splinesteps = 64); 
    rotate_sweep(path,360);
}

if (part == "cap" || part ==  "base") {
    fit = (part == "cap") ? 2 : 1;
    diff() {
        cyl(d = top_od + fit, h = 1, anchor = BOT){
            position(TOP) tube(od = top_od + fit, wall = 1, h = top_h, anchor = BOT);
            position(BOT) tag("remove") cyl(d = top_hole, anchor = BOT);
        }
    }
}