include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

part = "";  //[body, wheels, driver]

debug = false;  //[true,false]
stats = true;   //[true,false]
box   = false;  //[true,false]
voxel_size = 1.25; //[0.75:0.25:2]


/* [Hidden] */
wheelbase = [50,17];
wheelwell = [16,6];
wheel = [12,3]; 
axle = 1;
axle_hole = 1.3;


$fn = 144;

spec = [
    rot([0,91,-3]) * back(5), mb_capsule(r = 3, h = 70, influence = 1.3),
    rot([0,91,3]) * fwd(5), mb_capsule(r = 3, h = 70, influence = 1.3), 
    up(8) * left(22) * yrot(95), mb_cyl(r1 = 2, r2 = 0.5, h = 25),
    left(40) * fwd(15), mb_cyl(h = 20, r = 2, negative = true),
    left(40) * back(15), mb_cyl(h = 20, r = 2, negative = true),
];

if (part == "body")   body();
if (part == "wheels")  wheels();
if (part == "driver") driver();

 


module body() {
    bbox = [[-35,-11, -4], [36, 11, 13]];
    diff() {
        metaballs(spec,bbox, voxel_size, debug = debug, show_box = box, show_stats=true) {
          tag("remove") down(1) yflip_copy() fwd(wheelbase[1]/2) 
                xcopies(n=2, spacing = wheelbase[0]) ycyl(d = wheelwell[0], l = wheelwell[1], rounding2 = 2);
          tag("remove") down(1) xcopies(spacing = wheelbase[0]) ycyl(h = wheelbase[1], d = axle);
          tag("remove") up(4) left(17) conv_hull() {
                left(4) cuboid([10,10,10], rounding = 4, except = BOT, anchor = BOT);
                left(1) yrot(10) cuboid([10,10,10], rounding = 1, anchor = BOT);
          }
          tag("keep") left(20) up(3.8) cyl(h = 3, d1 = 3, d2 = 2, rounding1 = -1.5, rounding2 = 1, anchor = BOT);
          tag("remove") position(RIGHT) right(0.1) yscale(1.5) 
            xcyl(h = 2, d = 6, rounding2 = -1.5, anchor = RIGHT);
        }
    }
}
    
module wheels() fwd(30) {
   xcopies (n = 4, spacing = 18) 
        diff() {
            cyl(h = wheel[1], d = wheel[0] - 0.9, rounding = 1, teardrop = true, anchor = BOT)
               position(TOP) cyl(h = 2, d = 4, rounding2 = 2, anchor = BOT);
                tag("remove") cyl(h = wheel[1]*2, d = axle_hole, circum = true, anchor = BOT);
                tag("remove") cyl(h = wheel[1]/3, d1 = axle_hole * 2, d2 = 0, anchor = BOT);
                tag("remove") up(wheel[1]/2) torus(od = 12, id = 9);
        }
}

module driver() {
    diff() {
        cuboid([6,9,4], rounding = 2.5, except = BOT) {
            position(TOP) down(0.75) zscale(1.1) spheroid(3, anchor =BOT);
            tag("remove") position(BOT) cyl(h = 3, d1 = 3.1, d2 = 2.1, rounding1 = -1.5, rounding2 = 1, anchor = BOT);
        }
    }
}


/* */