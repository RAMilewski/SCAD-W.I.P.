
include<BOSL2/std.scad>

$fn = 144;

id = 62;
wall = 2;
h = 13 - wall;
od = id + 2 * wall;
gasket = [5, undef, wall/2];
grip = 3;

//back_half()
//gasket();
lid();


module lid () {
    diff() {
        tube(h = h, id = id, wall = wall, anchor = BOT){
            //thread grip
            tag("keep") attach(TOP,TOP, inside = true) zrot_copies(n = 4, d = id) 
                yscale(2) cyl(h = 2, d = grip, rounding = 0.5, teardrop = true);
            position(TOP) torus(d_maj = id + wall, d_min = wall);
            //top
            attach(BOT,TOP) cyl(h = wall, d = od)
            //gasket ditch
            tag("remove") attach(TOP,TOP, inside = true)
                tube(h = gasket.z, od = id, wall = wall, anchor = BOT);
        }
    }
}

module gasket() {
        tube(h = gasket.z, od = id, wall = wall);
}