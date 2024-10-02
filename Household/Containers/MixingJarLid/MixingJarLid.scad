include <BOSL2/std.scad>

$fn = 72;
//move([40,40]) color("grey", 0.2) import ("Mixing Jar Lid (TkC).stl");
//up(25) ruler();

myjar = 1; //[0:SpiceWorld, 1:Artichoke, 2:Small Mason]

jars = [ // [id, sidewall, height, floor, thread_starts, grip_dia]
    [62, 2, 10, 4, 4, 3],
    [62, 2, 10, 4, 4, 3],
    [undef, undef, undef, undef],
];

jar = jars[myjar];

id = jar[0];
wall = jar[1];
h = jar[2];
od = id + 2 * wall;
floor = jar[3];
gasket = [3, undef, floor * .75];
grip = jar[5];

//#gasket();
//back_half()
lid();



module lid () {
    diff() {
        tube(h = h, id = id, wall = wall, anchor = BOT){
            //thread grip
            tag("keep") attach(TOP,TOP, inside = true) zrot_copies(n = jar[4], d = id) 
                yscale(3) cyl(h = 1.5, d = grip, rounding = 0.75, teardrop = true);
            position(TOP) torus(d_maj = id + wall, d_min = wall);
            //top
            attach(BOT,TOP) cyl(h = floor, d = od, rounding1 = 2, teardrop = true)
            //gasket ditch
            tag("remove") attach(TOP,TOP, inside = true)
                tube(h = gasket.z, od = id, wall = gasket.x, anchor = BOT);
        }
    }
}

module gasket() {
        tube(h = gasket.z, od = id, wall = gasket.x, anchor = TOP);
}