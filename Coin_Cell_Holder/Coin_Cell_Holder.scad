include<BOSL2/std.scad>

part = "body"; // [all,body,top,plungers,assembly]

/* [Hidden] */
$fn = 72;

// Batteries  [xdim, undef, zdim, spring]
CR2477 = [24.5, undef, 7.7, 0];  
CR2032 = [20.5, undef, 3.2, 0];
CR2016 = [20.5, undef, 1.6, 0];
LR44   = [11.6, undef, 5.5, 1];

// Springs  [od, id, length, compressed, McMaster's part#]
springs = [ 
    [0.688 * INCH, 0.529 * INCH, 3 * INCH, 1.129 * INCH, "9657K124"],
    [0.360 * INCH, 0.258 * INCH, 3 * INCH, 1.132 * INCH, "9657K427"],
];

// Dimensions
batt = [CR2477,CR2032,CR2016,LR44, CR2032];  //Define number and type of battery columns here
columns = len(batt);
body = [75, undef, 3 * INCH];
top = [body.x, undef, 6];
floor = 3;
bevel = 2;
key = [20, undef, 4];
key_slop = 1;
batt_slop = 0.5;
spring_slop = 1; 

if (part == "top")  { top(); } 
if (part == "body") { body(); } 
if (part == "plungers") { plungers(false); }
if (part == "all")  { left(50) body(); right(50) top(); fwd(80) plungers(); }
if (part == "assembly") {
        body(); 
        up(10) color("blue") springs(); 
        up(body.z - 15) color("green") plungers(true);
        up(body.z) color("skyblue") top();
}

module top() {
    diff(){
        rev_batt = reverse(batt);  //because this part prints upside down.
        cyl(h = top.z, d = top.x, rounding2 = 5, anchor = BOT) {
            zrot_copies(n = columns, r = body.x/2) {
                left(0) {
                    tag("remove") position(BOT) xscale(1.5) cyl(h = top.z+0.01, d = batt[$idx].x - 3, rounding2 = -4, teardrop = true, anchor = BOT);
                }
            }
            tag("remove") position(BOT) cyl(h = key.z, d = key.x + key_slop, $fn = 6, anchor = BOT);
            tag("remove") position(BOT) cyl(h = 10, d = 4, anchor = BOT); // clearance hole for screw
        }
    }
}

module body() {
    diff() {
        cyl(h = body.z, d = body.x, anchor = BOT) {
            zrot_copies(n = columns, r = body.x/2) {
                tag("remove")  position(TOP) {
                    // batt compartments
                    left(batt[$idx].x*0.45) cyl(h = body.z - floor, d = batt[$idx].x + batt_slop, anchor = TOP);
                    // slide-out space
                    cuboid([1.9 * batt[$idx].x, batt[$idx].x+batt_slop, batt[$idx].z + batt_slop], rounding = batt[$idx].x/2, edges = "Z", anchor = TOP);
                }
                spring = springs[batt[$idx][3]];
                tag("keep") position(BOT) up(floor)  //spring posts
                left(batt[$idx].x*0.45) cyl(h = spring[3]/4, d1 = spring.y - spring_slop, d2 = spring.y*0.7, rounding2 = 2, anchor = BOT);
            }
            position(TOP) cyl(h = key.z, d = key.x, $fn = 6, chamfer2 = 1, anchor = BOT)
                tag("remove") position(TOP) cyl(h = 10, d = 3, anchor = TOP);  //screw hole
        }
    }
}

module plungers(flip) {
    zrot_copies(n = columns, r = body.x/2){
        spring = springs[batt[$idx][3]];
        if (!flip) {
            diff()
                left(batt[$idx].x*0.45) cyl(h = 15, d = batt[$idx].x, chamfer1 = bevel, anchor = BOT)
                    position(TOP) up(floor) tag("remove") cyl(h = 15, d = spring.y + spring_slop);
        } else { 
            diff()
                left(batt[$idx].x*0.45) cyl(h = 15, d = batt[$idx].x, chamfer2 = bevel, anchor = BOT)
                    position(BOT) tag("remove") cyl(h = 15 - floor, d = spring.y + spring_slop);
        }
    }
}

module springs() {
    zrot_copies(n = columns, r = body.x/2) {
        spring = springs[batt[$idx][3]];
        left(batt[$idx].x*0.45) down(spring[3]/4) 
            spiral_sweep(circle(.5), h=body.z-10, d=spring[1]-2, turns=9, $fn=36, anchor = BOT);
    }
}
