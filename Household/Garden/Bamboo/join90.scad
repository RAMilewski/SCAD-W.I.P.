include<BOSL2/std.scad>
include<BOSL2/screws.scad>

/* [Connector] */
type = 8; // [0, 1, 2, 3, 4, 5, 6, 7, 8]

/* [Bamboo Sizes] */

// Diameter of Primary Bamboo  
core_prime = 23;
// Diameter of 2nd Bamboo
core_2nd = 22;

wall = 3;
gap = 4;
gap2 = 3;           // Only applies if screw_hole == false
screw_hole = false;
ties = true;

ruler = true;

/* [Hidden] */

dia_prime = core_prime + 2 * wall;
dia_2nd = core_2nd + 2 * wall;

h_prime = dia_2nd;
h_2nd = min(max(core_prime, core_2nd), 30);

$fn = 72;
gap3 = screw_hole ? 0 : gap2;
$align_msg = false;


td_ang = 50;
shape = teardrop2d(d = dia_prime, ang = td_ang, cap_h = core_prime/2 + wall, spin = 180);
path =  [[0,h_prime/2], [0,-h_prime/2]];
path2 = [[0,h_prime + 10],   [0,-h_prime - 10]];
path4 = [[0,h_prime/4], [0,-h_prime/4]];
// Main


if (type == 0) { type0();
} else if (type == 1) { type1();
} else if (type == 2) { type2();
} else if (type == 3) { type3();
} else if (type == 4) { type4();
} else if (type == 5) { type5();
} else if (type == 6) { type6();
} else if (type == 7) { type7();
} else if (type == 8) { type8();
}


// Module Definitions

module type0() {
    diff() {
        span = 85;
        wall = 1;
        cuboid([span, wall*2, dia_2nd], rounding = dia_2nd/2, edges = "Y", anchor = BOT){
            xcopies(l = span - dia_2nd, n = 4)
                position(FWD) ycyl(d = dia_2nd, h = h_2nd, anchor = BACK)
                    tag("remove") ycyl(d1 = core_2nd, d2 = core_2nd +1, h = h_2nd + 1, anchor = BACK);
            tag("remove") align(BACK, overlap = wall *1.5) xcyl(d = dia_prime, h = span, anchor = FWD);
        }
                     
    }
}

module type1() {
    diff() {
        path_sweep(shape, path){
            tag("remove") {
                position(BOT) up(1) cuboid([gap, h_prime + 2, wall * 2]); //gap
                ycyl(d = core_prime, h = h_prime + 1);  
                hole4screw(RIGHT);
                ties(BOT);
            }
            align(TOP, overlap = 1.5* wall) xcyl(d = dia_2nd, h = h_2nd) {
                tag("remove") xcyl(d = core_2nd, h = h_2nd + 1)
                    tag("remove") attach(TOP,TOP, overlap = 2) cuboid([h_2nd + 1, gap/2, core_2nd]);
                hole4screw(FRONT);
            }
        }
    }
}

module type2() {
 
    diff() {
          path_sweep(shape, path){
            tag("remove") {
                position(BOT) up(1) cuboid([gap, h_prime + 2, wall * 2]); //gap
                ycyl(d = core_prime, h = h_prime + 1);  
                hole4screw(RIGHT);
                ties(BOT);
            }
            attach(TOP,BOT, overlap= wall * 2.5) cyl(d = dia_2nd, rounding1 = 4, teardrop = 50, h = h_2nd) {  
                attach(TOP,BOT) down(wall) torus(d_maj = dia_2nd - wall/2, d_min = wall);
                tag("remove") up(1) cyl(d1 = core_2nd, d2 = core_2nd + 1, h = h_2nd + 1);
                position(TOP) rounding_hole_mask(d = core_2nd, rounding = wall);
                if (gap2) tag("remove") prismoid([0, dia_2nd], [gap2, dia_2nd + 2 * wall], h = h_2nd/2);
                hole4screw(RIGHT);
                //position(TOP) ruler(anchor = BOT+BACK);
            }
        }
    }
}

module type3() {
    diff() {
        path_sweep(shape, path){
            tag("remove") {
                position(BOT) up(1) cuboid([gap, h_prime/2, wall * 2]); //gap
                ycyl(d = core_prime, h = h_prime/2+1);  
                hole4screw(RIGHT);
                down(2.5) zscale(0.666) ties(BOT);
            }
            align(TOP, overlap = 1.5* wall) xcyl(d = dia_2nd, h = h_2nd/2) {
                tag("remove") xcyl(d = core_2nd, h = h_2nd/2+1)
                    tag("remove") attach(TOP,TOP, overlap = 2) down(1) cuboid([h_2nd + 1, gap/2, core_2nd]);
                hole4screw(FRONT);
            }
        }
    }
}

module type4() {
 
    diff() {
          top_half() path_sweep(shape, path){
            tag("remove") {
                position(BOT) up(1) cuboid([gap, h_prime + 2, wall * 2]); //gap
                ycyl(d = core_prime, h = h_prime + 1);  
                hole4screw(RIGHT);
                ties(BOT);
            }
            attach(TOP,BOT, overlap= wall * 2.5) cyl(d = dia_2nd, rounding1 = 4, teardrop = 50, h = h_2nd) {  
                tag("remove") up(2) cyl(d1 = core_2nd, d2 = core_2nd + 1, h = h_2nd + 1);
                position(TOP) rounding_hole_mask(d = core_2nd, rounding = wall);
                if (gap2) tag("remove") prismoid([0, dia_2nd], [gap2, dia_2nd], h = h_2nd/2);
                hole4screw(RIGHT);
                //position(TOP) ruler(anchor = BOT+BACK);
            }
        }
    }
    diff(){
        cuboid([dia_prime, h_prime, dia_prime/2], rounding = wall, edges = BOT, teardrop = true, anchor = TOP)
        ties(BOT);
        tag("remove") cuboid([dia_prime - 2* wall, h_prime + 1, dia_prime/2+1], anchor = TOP);
    }
}

module type5() {
    cyl(d = dia_prime, h = wall * 2, rounding1 = wall, anchor = BOT)
        position(TOP) tube(od = dia_prime, wall = wall, h = 45, anchor = BOT);
}

module type6() {
    diff(){
        cuboid([dia_prime+3, dia_prime+3, wall], rounding = wall, edges = "Z") {
            attach(TOP,BOT) tube(id = core_prime, wall = wall, h = h_prime) {  
                attach(TOP,BOT) down(wall) torus(d_maj = dia_prime - wall/2, d_min = wall);
                tag("remove") prismoid([0, dia_prime + wall], [gap2, dia_prime + wall], h = h_prime/2);
                hole4screw(RIGHT);
                if($preview && ruler) position(TOP) ruler(anchor = BOT+BACK);
            }
            grid_copies(n = [2,2], spacing = core_prime + 1)
                tag("remove") cyl(d = 3.5, h = wall *3);
        }
    }
}

module type7() {  //Post Mount
    diff(){
        cuboid([dia_prime+15, dia_prime+15, wall], rounding = wall, edges = "Z") {
            attach(TOP,BOT) tube(od1 = core_prime + 7 * wall, od2 = core_prime + 2* wall, id = core_prime, h = h_prime * 1.2) {  
                attach(TOP,BOT) down(wall) torus(d_maj = dia_prime - wall/2, d_min = wall);
                tag("remove") position(TOP) #prismoid([0, dia_prime + 4 * wall], [gap2, dia_prime + 4 * wall], h = h_prime/1.5, anchor = TOP);
                hole4screw(RIGHT);
                if($preview && ruler) position(TOP) ruler(anchor = BOT+BACK);
            }
            grid_copies(n = [2,2], spacing = core_prime + 10)
                tag("remove") cyl(d = 3.5, h = wall *3);
        }
    }
}


module type8() {  //Post Mount Washer
    diff(){
        cuboid([dia_prime+15, dia_prime+15, wall], rounding = wall, edges = "Z") {
            position(BOT) tag("remove") 
                cyl(d1 = core_prime + 7 * wall, h = h_prime * 1.2, rounding1 = -1, teardrop = true, anchor = BOT);
            grid_copies(n = [2,2], spacing = core_prime + 10)
                tag("remove") cyl(d = 3.5, h = wall *3);

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
        attach(where) down(2) tag("remove") cuboid([dia_prime + wall , 5, 1.5], rounding = 0.5);
    }
}