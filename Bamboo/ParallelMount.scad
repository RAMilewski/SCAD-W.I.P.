include<BOSL2/std.scad>


/* [Shaft Params] */
type = 1; // [1:2]
shafts = 4; // [2:8]

/* [Bamboo Sizes] */

// Nominal Diameter of Bamboo  
core = 11;
h = 10;
wall = 2;
gap = 2;
span = 85;
d_back = 25;

screw_hole = false;
ties = true;
gaps = true; 

/* [Hidden] */

dia = core + 2 * wall;
$fn = 72;

td_ang = 50;

// MAIN

if (type == 1) {
    mount1(core, dia, h, wall, gap, span, d_back);
} else if (type == 2) {
    mount2(core, dia, h, wall, gap, span, d_back);
} 



// Module Definitions

    
module mount1(core, dia, h, wall, gap, span, d_back) {
    diff() {
        cuboid([span, wall * 1.5, dia], rounding = dia/2, edges = "Y", anchor = BOT){
            xcopies(l = span - dia, n = 4){
                position(FWD) ycyl(d = dia, h = h, anchor = BACK){
                    tag("remove") ycyl(d1 = core, d2 = core+1, h = h + 1);
                    position(FWD) tag("remove") #cuboid([gap, h-1, dia], anchor = FWD);
                }
            }
            position(FWD) tag("remove") align(BACK) xcyl(d = d_back, h = span, anchor = FWD);
        }
                     
    }
}

module mount2(core, dia, h, wall, gap, span, d_back) {
    diff() {
        span = 85;
        cuboid([span, wall/2, h/2], edges = "Y", anchor = BOT){
            xcopies(l = span - dia, n = 4){
                cyl(d = dia, h = h){
                    tag("remove") cyl(d = core, h = h + 1);
                    position(TOP+FWD) tag("remove") #cuboid([gap, wall+ 1, h], anchor = FWD+TOP);
                }

            }
        }
    }
}

module hole4screw(where) {
     if (screw_hole) {
        attach(where) tag("remove") screw_hole("#6,3/8", head = "round", counterbore = wall/2, anchor = TOP);
    }
}

module ties (where) {
    if (ties) {
        attach(where) down(2) tag("remove") cuboid([dia_prime, 5, 1.5], rounding = 0.5);
    }
}