include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

debug = false;  //[true,false]
stats = true;   //[true,false]
box   = false;  //[true,false]

inf = 1.3;
$fn = 144;

func = [
    yrot(90) * back(5), mb_capsule(r = 3, h = 80, influence = inf),
    yrot(90) * fwd(5), mb_capsule(r = 3, h = 80, influence = inf), 
    up(6) * left(25) * yrot(95), mb_cyl(r1 = 3, r2 = 0.5, h = 30),
];

bbox = [[-60,-15, -4], [40, 15, 15]];

    diff() {
        metaballs(func,bbox, 1.5, debug = debug, show_box = false, show_stats=true);
          tag("remove") xcopies(n = 2, spacing = 50) yflip_copy() fwd(10) ycyl(h = 5, d = 15, rounding2 = 2);
          tag("remove") xcopies(n = 2, spacing = 50) ycyl(h = 20, d = 1);
          tag("remove") up(4) left(15) cockpit();
    }
    wheels();

module cockpit() {
    conv_hull() {
        left(10) cyl(h = 20, d = 10, anchor = BOT);
        cyl(h = 20, d= 10, anchor = BOT);
    }
}

module wheels() {
    grid_copies([2,2], spacing = [50,22]) color("black") ycyl(h = 5, d = 14, rounding = 1);
}