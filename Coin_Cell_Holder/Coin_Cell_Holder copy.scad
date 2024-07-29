include<BOSL2/std.scad>

part = "body"; // [all,body,top,plungers]

/* [Hidden] */
$fn = 72;

// Batteries
CR2477 = [24.5, undef, 7.7];
CR2032 = [20.5, undef, 3.2];
CR2016 = [20.5, undef, 1.6];
LR44   = [11.6, undef, 5.5];

// Springs
9657K124 = [0.688 * INCH, 0.529 * INCH, 3 * INCH, 1.129 * INCH]; //[od,id,length,compressed]  McMasters part#

// Dimensions
batt = [CR2477,CR2032,CR2016,LR44];
batt_slop = 0.5;
columns = len(batt);
spring = 9657K124;
spring_slop = 0.5; 
body = [75, undef, 3 * INCH];
floor = 3;
bevel = 2;
key = [20, undef, 4];
key_slop = 0.5;

if (part == "top")  { top(); } 
if (part == "body") { body(); } 
if (part == "plungers") { plungers(); }
if (part == "all")  { left(50) body(); right(50) top(); fwd(80) plungers(); }

module top() {
    diff(){
        cyl(h = 6, d = body.x, rounding1 = 5, teardrop = true, anchor = BOT) {
            zrot_copies(n = columns, r = body.x/2 - batt[0].x * .35) {
                tag("remove") position(BOT) cyl(h = 10.1, d = batt[$idx].x - 3, rounding1 = -4, teardrop = true, anchor = BOT);
            }
                tag("remove") position(TOP) cyl(h = key.z, d = key.x + key_slop, $fn = 6, anchor = TOP);
                tag("remove") position(BOT) cyl(h = 10, d = 4, anchor = BOT); // clearance hole for screw
        }
    }
}


module body() {
    diff() {
        cyl(h = body.z, d = body.x, anchor = BOT) {
            zrot_copies(n = columns, r = body.x/2 - batt[0].x * .35) {
                tag("remove")  position(TOP) {
                    // batt compartments
                    cyl(h = body.z - floor, d = batt[$idx].x + batt_slop, anchor = TOP);
                    // slide-out space
                    right(batt[$idx].x/2) cuboid([2 * batt[$idx].x, batt[$idx].x+batt_slop, batt[$idx].z + batt_slop], rounding = batt[$idx].x/2, edges = "Z", anchor = TOP);
                    }
                
                tag("keep") position(BOT) up(floor)  //spring posts
                    cyl(h = spring[3]/4, d1 = spring.y - spring_slop, d2 = spring.y/2, rounding2 = 2, anchor = BOT);
                
            }
            position(TOP) cyl(h = key.z, d = key.x, $fn = 6, chamfer2 = 1, anchor = BOT)
                tag("remove") position(TOP) cyl(h = 10, d = 3, anchor = TOP);  //screw hole
        }
    }
}


module plungers() {
    zrot_copies(n = columns, r = body.x/3)
        diff()
            cyl(h = 15, d = batt[$idx].x, chamfer1 = bevel, anchor = BOT)
            up(floor) tag("remove") cyl(h = 15, d = spring.y + spring_slop); 
}



