include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

debug = false;  //[true,false]
stats = true;   //[true,false]
box   = false;  //[true,false]

inf = 1.3;
wheelbase = [50,22];
wheel = [14,5];

$fn = 144;

func = [
    yrot(90) * back(5), mb_capsule(r = 3, h = 70, influence = inf),
    yrot(90) * fwd(5), mb_capsule(r = 3, h = 70, influence = inf), 
    up(8) * left(25) * yrot(95), mb_cyl(r1 = 3, r2 = 0.5, h = 30),
    right(40) * down(2), mb_cyl(r1 = 2, r2 = 0.1, h = 5),
];

bbox = [[-60,-15, -4], [45, 15, 15]];

    diff() {
        metaballs(func,bbox, 1.5, debug = debug, show_box = false, show_stats=true);
          tag("remove") down(1) grid_copies([2,2], spacing = wheelbase) ycyl(d = wheel[0], l = wheel[1], rounding2 = 2);
          tag("remove") down(1) xcopies(spacing = wheelbase[0]) ycyl(h = wheelbase[1], d = 2.5);
          tag("remove") up(4) left(17) cockpit();
    }
   

module cockpit() {
    conv_hull() {
        left(6) cyl(h = 20, d = 10, rounding1 = 2, anchor = BOT);
        yrot(10) cuboid([10,10,20], rounding = 2, anchor = BOT);
    }
}

module wheels() {
    grid_copies([2,2], spacing = wheelbase) color("black") ycyl(h = 5, d = 14, rounding = 1);
}