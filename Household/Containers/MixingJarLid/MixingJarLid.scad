include <BOSL2/std.scad>
include <BOSL2/beziers.scad>


$fn = 72;
part = "lid";   //[lid, gasket]
jar_type = 0;   //[0:SpiceWorld, 1:Artichoke]
mix = true;     //[true, false]
isNylon = true; //[true, false]


jars = [ // [id, sidewall, height, floor, thread_starts, grip_dia]
    [62, 3, 10, 4, 4, 3.5],
    [62, 3, 10, 4, 4, 3.5],
    [undef, undef, undef, undef],
];

jar = jars[jar_type];

nylon = isNylon ? 1 : 0 ;
id = jar[0] + nylon;
wall = jar[1];
h = jar[2];
od = id + 2 * wall;
floor = jar[3];
gasket = [id - 10, id - 11, floor * .75];  // [id1, id2, z]
grip = jar[5];


if (part == "lid") lid(); else gasket();

bez =[[gasket.x/2,0],[gasket.x/8,0],[gasket.x/6,12],[0,12]];
closed = bezpath_close_to_axis(bez,"Y");
path = bezpath_curve(closed,360);



module lid() {
    diff() {
        tube(h = h, id = id, wall = wall, anchor = BOT){
            //thread grip
            tag("keep") attach(TOP,TOP, inside = true) zrot_copies(n = jar[4], d = id) 
                yscale(3) cyl(h = 1.5, d = grip, rounding = 0.75, teardrop = true);
            position(TOP) torus(d_maj = id + wall, d_min = wall);
            //top
            attach(BOT,TOP) cyl(h = floor, d = od, rounding1 = 2, teardrop = true){
            //gasket ditch
                tag("remove") attach(TOP,TOP, inside = true) gasket();
                if (mix) { attach(TOP,BOT) #rotate_sweep(path); }
            }
        }
    }
}

module gasket() {
    fudge = part=="gasket" ? 0.5 : 0;
    tube(h = gasket.z, od = id - fudge, id1 = gasket.x + fudge, id2 = gasket.x + 2 * fudge, anchor = BOT);
 }